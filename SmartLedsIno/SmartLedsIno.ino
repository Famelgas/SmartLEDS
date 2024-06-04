// ----------------------------------------------------------------------------------
// ------------------------------------ INCLUDES ------------------------------------
// ----------------------------------------------------------------------------------

#include <FastLED.h>



// -----------------------------------------------------------------------------------
// ------------------------------------ VARIABLES ------------------------------------
// -----------------------------------------------------------------------------------


// --------------------------------------------------
// ---------------------- PINS ----------------------

#define LED_DATA_IN_PIN 3 // led strip data in
#define TRIGGER_PIN 4 // trigger
#define ECHO_PIN 5 // echo
#define MICROPHONE_PIN A0


// -----------------------------------------------------
// ---------------------- SENSORS ----------------------

// Duration used to calculate distance
int echo_time;
float distance;

// entre 0.5m e 2.5m
int min_distance = 50; // cm
int high_reaction_dist = 100; // cm
int medium_reaction_dist = 150; // cm
int low_reaction_dist = 200; // cm
int max_distance = 250; // cm


// ----------------------------------------------------
// ---------------------- MATRIX ----------------------

#define NUM_LEDS 30
CRGB led_strip[ NUM_LEDS ];

#define MATRIX_WIDTH 6 // matrix width
#define MATRIX_HEIGHT 3 // matrix height

const uint8_t kMatrixWidth = MATRIX_WIDTH;
const uint8_t kMatrixHeight = MATRIX_HEIGHT;

#define NUM_LEDS_MATRIX (kMatrixWidth * kMatrixHeight)
#define LAST_VISIBLE_LED 17

uint16_t XY (uint8_t x, uint8_t y) {
  // any out of bounds address maps to the first hidden pixel
  if ( (x >= kMatrixWidth) || (y >= kMatrixHeight) ) {
    return (LAST_VISIBLE_LED + 1);
  }

  const uint8_t XYTable[] = {               //                     LED_MATRIX                     
     0,   1,   2,   3,   4,   5,            // ⎡   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  ⎤
    11,  10,   9,   8,   7,   6,            // ⎪  19,  18,  17,  16,  15,  14,  13,  12,  11,  10,  ⎪
    12,  13,  14,  15,  16,  17             // ⎣  20,  21,  22,  23,  24,  25,  26,  27,  28,  29   ⎦
  };                                        //

  uint8_t i = (y * kMatrixWidth) + x;
  uint8_t j = XYTable[i];
  return j;
}

CRGB colorMatrix[MATRIX_WIDTH][MATRIX_HEIGHT];


int ROW1_COL1 = 1, ROW1_COL6 = 5;
int ROW2_COL1 = 17, ROW2_COL6 = 13;
int ROW3_COL1 = 23, ROW3_COL6 = 29;


// ---------------------------------------------------------
// ---------------------- SOUND REACT ----------------------

#define BRIGHTNESS      100 // Min: 0, Max: 255
#define SATURATION      150 // Min: 0, Max: 255
#define MIN_VAL          10 // Min: 0, Max: 75
#define MAX_VAL         500 // Min: 75, Max: 750
#define HUE_INIT         10 // < 255
#define HUE_CHANGE        2 // < 255

byte dynamicHue = HUE_INIT;
int analogVal = 0;

int mic=0;



// --------------------------------------------------------
// ---------------------- PROCESSING ----------------------

String readSerial;
int mode;
bool power;
int brightness;
int pickedColor[3];



// ---------------------------------------------------------------------------------
// ------------------------------------ ARDUINO ------------------------------------
// ---------------------------------------------------------------------------------

void setup() {
  Serial.begin(9600);

  pinMode(TRIGGER_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  pinMode(MICROPHONE_PIN, INPUT);


  FastLED.addLeds<WS2812B, LED_DATA_IN_PIN, GRB>(led_strip, NUM_LEDS).setCorrection(TypicalSMD5050);
  FastLED.setBrightness(BRIGHTNESS);
  FastLED.clear();

  power = true;
  mode=0;
  brightness = BRIGHTNESS;
  pickedColor[0] = 255;
  pickedColor[1] = 138;
  pickedColor[2] = 18;
}

void loop() {
  FastLED.clear();

  recieveInfo();

  if (power) {
    switch (mode) {
      case 0: // solid color
        solid(CRGB(pickedColor[0], pickedColor[1], pickedColor[2]));
        break;

      case 1: // sound reaction
        //soundReact();
        //LinearReactive();
        solid(CRGB(200, 0, 200));
        break;

      case 2: // movement reaction
        movReact();
        //solid(CRGB(CRGB::Green));
        break;

      case 3: // rainbow
        rainbow();
        break;
      
      case -1: // error
        fill_solid(led_strip, NUM_LEDS, CRGB(CRGB::Orange));
        break;
    }
  }
    
  FastLED.show(); // Display the updated LEDs
}



// ------------------------------------------------------------------------------
// ------------------------------------ LEDS ------------------------------------
// ------------------------------------------------------------------------------

int mapLeds(uint8_t index, uint8_t y) {
  if (y == 0)
    return map(index, 0, 5, 1, 6);
  if (y ==1)
    return map(index, 6, 11, 12, 17);
  if (y == 2)
    return map(index, 12, 17, 23, 28);
}

int mapLedsSerpentine(uint8_t index, uint8_t y) {
  if (y == 0)
    return map(index, 0, 5, 1, 6);
  if (y ==1)
    return map(index, 6, 11, 12, 17);
  if (y == 2)
    return map(index, 12, 17, 23, 28);
}



// -------------------------------------------------------------------------------
// ------------------------------------ MODES ------------------------------------
// -------------------------------------------------------------------------------

void solid(const struct CRGB & color) {
  FastLED.clear();
  for( uint8_t y = 0; y < kMatrixHeight; y++) {   
    for( uint8_t x = 0; x < kMatrixWidth; x++) {
      led_strip[mapLeds(XY(x, y), y)] = color;
    }
  }
  FastLED.setBrightness(brightness);
  delay(10);
}

void solid(const struct CHSV & color) {
  FastLED.clear();
  for( uint8_t y = 0; y < kMatrixHeight; y++) {   
    for( uint8_t x = 0; x < kMatrixWidth; x++) {
      led_strip[mapLeds(XY(x, y), y)] = color;
    }
  }
  FastLED.setBrightness(brightness);
  delay(10);
}


void rainbow() {
  FastLED.clear();
  uint32_t ms = millis();
  int32_t yHueDelta32 = ((int32_t)cos16( ms * (27/1) ) * (350 / kMatrixWidth));
  int32_t xHueDelta32 = ((int32_t)cos16( ms * (39/1) ) * (310 / kMatrixHeight));
  DrawOneFrame( ms / 65536, yHueDelta32 / 32768, xHueDelta32 / 32768);
  if( ms < 5000 ) {
    FastLED.setBrightness( scale8( BRIGHTNESS, (ms * 256) / 5000));
  } else {
    FastLED.setBrightness(BRIGHTNESS);
  }
}

void DrawOneFrame( uint8_t startHue8, int8_t yHueDelta8, int8_t xHueDelta8) {
  uint8_t lineStartHue = startHue8;
  for( uint8_t y = 0; y < kMatrixHeight; y++) {
    lineStartHue += yHueDelta8;
    uint8_t pixelHue = lineStartHue;      
    for( uint8_t x = 0; x < kMatrixWidth; x++) {
      pixelHue += xHueDelta8;
      led_strip[mapLeds(XY(x, y), y)]  = CHSV( pixelHue, 255, 255);
    }
  }
}


// ---------------------------------------------------------
// ---------------------- SOUND REACT ----------------------



// ------------------------------------------------------------
// ---------------------- MOVEMENT REACT ----------------------

void movReact() {
  FastLED.clear();
  for( uint8_t y = 0; y < kMatrixHeight; y++) {   
    for( uint8_t x = 0; x < kMatrixWidth; x++) {
      led_strip[mapLeds(XY(x, y), y)]  = colorMatrix[x][y];
    }
  }
  FastLED.setBrightness(brightness);
  delay(25);
}


void modeMovReact() {
  // Trigger the ultrasonic sensor to measure distance
  digitalWrite(TRIGGER_PIN, LOW); 
  delayMicroseconds(2);
  digitalWrite(TRIGGER_PIN, HIGH); 
  delayMicroseconds(10);
  digitalWrite(TRIGGER_PIN, LOW);
  echo_time = pulseIn(ECHO_PIN, HIGH, 30000);
  distance = (echo_time * 0.034) / 2;

  FastLED.clear();
  

  if (distance >= min_distance && distance <= max_distance) {
    if (distance >= low_reaction_dist) {
      int row = 3;
      for (int i = ROW3_COL1; i <= ROW3_COL6 && row > 0; i++) {
        led_strip[i] = CRGB(CRGB::White);
        row--;
      }
    }

    if (distance <= medium_reaction_dist) {
      int row = 2;
      for (int i = ROW2_COL1; i >= ROW2_COL6 && row > 0; i--) {
        led_strip[i] = CRGB(CRGB::White);
        row--; 
      }
    }

    if (distance <= high_reaction_dist) {
      int row = 1;
      for (int i = ROW1_COL1; i <= ROW1_COL6 && row > 0; i++) {
        led_strip[i] = CRGB(CRGB::White);
        row--; 
      }
    }
  }

  delay(10);
}


// ---------------------------------------------------------------------------------------
// ------------------------------------ COMMUNICATION ------------------------------------
// ---------------------------------------------------------------------------------------

void parseLedMatrix() {
  int color[3];

  int start_tk;
  int rg_tk;
  int gb_tk;
  int end_tk;

  for (int x = 0; x < MATRIX_WIDTH; x++) {
    for (int y = 0; y < MATRIX_HEIGHT; y++) {
      if (x == 0 && y == 0) {
        start_tk = readSerial.indexOf(":");
        rg_tk = readSerial.indexOf(",");
        gb_tk = readSerial.indexOf(",", rg_tk + 1);
        end_tk = readSerial.indexOf(";");
      }
      else {
        start_tk = end_tk;
        rg_tk = readSerial.indexOf(",", gb_tk + 1);
        gb_tk = readSerial.indexOf(",", rg_tk + 1);
        end_tk = readSerial.indexOf(";", start_tk + 1);
      }

      color[0] = readSerial.substring(start_tk + 1, rg_tk).toInt();
      color[1] = readSerial.substring(rg_tk + 1, gb_tk).toInt();
      color[2] = readSerial.substring(gb_tk + 1, end_tk).toInt();
      
      
      colorMatrix[x][y] = CRGB(color[0], color[1], color[2]);
    }
  }
  delay(50);
}


void parsePickedColor() {
  int rgb_tk2 = readSerial.indexOf(",");
  int color_tk = readSerial.lastIndexOf(",");
  pickedColor[0] = readSerial.substring(readSerial.indexOf(":") + 1, rgb_tk2).toInt();
  pickedColor[1] = readSerial.substring(rgb_tk2 + 1, color_tk).toInt();
  pickedColor[2] = readSerial.substring(color_tk + 1).toInt();
}


void recieveInfo() {
  if (Serial.available() > 0) {  // Check if data is available
    readSerial = Serial.readStringUntil('\n');
    readSerial.trim();

    if (readSerial == "power_on") {
      power = true;
      FastLED.clear();
    }
    if (readSerial == "power_off") {
      power = false;
      FastLED.clear();
    }
    if (readSerial == "brightness_down") {
      if (brightness > 10) {
        brightness -= 10;
      }
      FastLED.clear();
    }
    if (readSerial == "brightness_up") {
      if (brightness < 100) {
        brightness += 10;
      }
      FastLED.clear();
    }
    if (readSerial.startsWith("picked_color:")) {
      parsePickedColor();
      FastLED.clear();
    }
    if (readSerial.startsWith("mode_solid:")) {
      mode = 0;
      parsePickedColor();
      FastLED.clear();
    }
    if (readSerial == "mode_soundReact") {
      mode = 1;
      FastLED.clear();
    }
    if (readSerial == "mode_moveReact") {
      mode = 2;
      FastLED.clear();
    }
    if (readSerial.startsWith("mode_moveReact:")) {
      mode = 2;
      parseLedMatrix();
      FastLED.clear();
    }
    if (readSerial == "mode_rainbow") {
      mode = 3;
      FastLED.clear();
    }
  }
}


void readAnalog() {
  analogVal = analogRead(MICROPHONE_PIN);

  if(analogVal > MAX_VAL)
    analogVal = MAX_VAL;

  if(analogVal < MIN_VAL)
    analogVal = MIN_VAL;
}
