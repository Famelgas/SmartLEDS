#include <FastLED.h>

// ---------------------- PINS ----------------------
#define LED_DATA_IN_PIN 3 // led strip data in
#define TRIGGER_PIN 4 // trigger
#define ECHO_PIN 5 // echo
#define MICROPHONE_PIN A0

// ---------------------- SENSORS ----------------------
int echo_time;
float distance;

// entre 0.5m e 2.5m
int min_distance = 50;
int high_reaction_dist = 100;
int medium_reaction_dist = 150;
int low_reaction_dist = 200;
int max_distance = 250;

// ---------------------- MATRIX ----------------------
#define NUM_LEDS 228
#define MATRIX_WIDTH 20 
#define MATRIX_HEIGHT 10
#define LAST_VISIBLE_LED 199

uint16_t XY (uint8_t x, uint8_t y) {
  // any out of bounds address maps to the first hidden pixel
  if ( (x >= MATRIX_WIDTH) || (y >= MATRIX_HEIGHT) ) {
    return (LAST_VISIBLE_LED + 1);
  }

  const uint8_t XYTable[] = {
     0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,  14,  15,  16,  17,  18,  19,
    39,  38,  37,  36,  35,  34,  33,  32,  31,  30,  29,  28,  27,  26,  25,  24,  23,  22,  21,  20,
    40,  41,  42,  43,  44,  45,  46,  47,  48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,
    79,  78,  77,  76,  75,  74,  73,  72,  71,  70,  69,  68,  67,  66,  65,  64,  63,  62,  61,  60,
    80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,  91,  92,  93,  94,  95,  96,  97,  98,  99,
   119, 118, 117, 116, 115, 114, 113, 112, 111, 110, 109, 108, 107, 106, 105, 104, 103, 102, 101, 100,
   120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139,
   159, 158, 157, 156, 155, 154, 153, 152, 151, 150, 149, 148, 147, 146, 145, 144, 143, 142, 141, 140,
   160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179,
   199, 198, 197, 196, 195, 194, 193, 192, 191, 190, 189, 188, 187, 186, 185, 184, 183, 182, 181, 180
  };

  uint8_t i = (y * MATRIX_WIDTH) + x;
  uint8_t j = XYTable[i];
  return j;
}

/*
                                                      MATRIX
0,               1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,  14,  15,  16,  17,  18,  19,  20,          21,  22,
45,  44,        43,  42,  41,  40,  39,  38,  37,  36,  35,  34,  33,  32,  31,  30,  29,  28,  27,  26,  25,  24,               23,
46,             47,  48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  62,  63,  64,  65,  66,          67,  68,
91,  90,        89,  88,  87,  86,  85,  84,  83,  82,  81,  80,  79,  78,  77,  76,  75,  74,  73,  72,  71,  70,               69,
92,             93,  94,  95,  96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112,         113, 114,
137, 136,      135, 134, 133, 132, 131, 130, 129, 128, 127, 126, 125, 124, 123, 122, 121, 120, 119, 118, 117, 116,              115,
138,           139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158,         159, 160,
183, 182,      181, 180, 179, 178, 177, 176, 175, 174, 173, 172, 171, 170, 169, 168, 167, 166, 165, 164, 163, 162,              161,
184,           185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204,         205, 206,
229, 228,      227, 226, 225, 224, 223, 222, 221, 220, 219, 218, 217, 216, 215, 214, 213, 212, 211, 210, 209, 208,              207

*/



CRGB led_strip[ NUM_LEDS ];
String colorMatrix[MATRIX_WIDTH][MATRIX_HEIGHT];


int ROW1_COL1 = 1, ROW1_COL6 = 5;
int ROW2_COL1 = 17, ROW2_COL6 = 13;
int ROW3_COL1 = 23, ROW3_COL6 = 29;


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

String readSerial = "";
String ledMatrixData = "";
bool receivingMatrixData = false;

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
  recieveInfo();
  FastLED.clear();
  
  if (power) {
    switch (mode) {
      case 0: // solid color
        solid(CRGB(pickedColor[0], pickedColor[1], pickedColor[2]));
        break;

      case 1: // sound reaction
        // soundReact();
        solid(CRGB(200, 0, 200));
        break;

      case 2: // movement reaction
        movReact();
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
  if (y == 0) return map(index, 0, 19, 1, 20);
  if (y == 1) return map(index, 20, 39, 24, 43);
  if (y == 2) return map(index, 40, 59, 47, 66);
  if (y == 3) return map(index, 60, 79, 70, 89);
  if (y == 4) return map(index, 80, 99, 93, 112);
  if (y == 5) return map(index, 100, 119, 116, 135);
  if (y == 6) return map(index, 120, 139, 139, 158);
  if (y == 7) return map(index, 140, 159, 162, 181);
  if (y == 8) return map(index, 160, 179, 185, 204);
  if (y == 9) return map(index, 180, 199, 208, 227);
  return -1; // Invalid index
}


// -------------------------------------------------------------------------------
// ------------------------------------ MODES ------------------------------------
// -------------------------------------------------------------------------------

void solid(const struct CRGB & color) {
  for (uint8_t y = 0; y < MATRIX_HEIGHT; y++) {
    for (uint8_t x = 0; x < MATRIX_WIDTH; x++) {
      led_strip[mapLeds(XY(x, y), y)] = color;
    }
  }
  FastLED.setBrightness(brightness);
  delay(25);
}

void solid(const struct CHSV & color) {
  for( uint8_t y = 0; y < MATRIX_HEIGHT; y++) {   
    for( uint8_t x = 0; x < MATRIX_WIDTH; x++) {
      led_strip[mapLeds(XY(x, y), y)] = color;
    }
  }
  FastLED.setBrightness(brightness);
  delay(25);
}


void rainbow() {
  uint32_t ms = millis();
  int32_t yHueDelta32 = ((int32_t)cos16( ms * (27/1) ) * (350 / MATRIX_WIDTH));
  int32_t xHueDelta32 = ((int32_t)cos16( ms * (39/1) ) * (310 / MATRIX_HEIGHT));
  DrawOneFrame( ms / 65536, yHueDelta32 / 32768, xHueDelta32 / 32768);
  if( ms < 5000 ) {
    FastLED.setBrightness( scale8( BRIGHTNESS, (ms * 256) / 5000));
  } else {
    FastLED.setBrightness(BRIGHTNESS);
  }
}

void DrawOneFrame( uint8_t startHue8, int8_t yHueDelta8, int8_t xHueDelta8) {
  uint8_t lineStartHue = startHue8;
  for( uint8_t y = 0; y < MATRIX_HEIGHT; y++) {
    lineStartHue += yHueDelta8;
    uint8_t pixelHue = lineStartHue;      
    for( uint8_t x = 0; x < MATRIX_WIDTH; x++) {
      pixelHue += xHueDelta8;
      led_strip[mapLeds(XY(x, y), y)]  = CHSV( pixelHue, 255, 255);
    }
  }
}


// ---------------------------------------------------------
// ---------------------- SOUND REACT ----------------------



// ------------------------------------------------------------
// ---------------------- MOVEMENT REACT ----------------------

/*
void modeMovReact() {
  // Trigger the ultrasonic sensor to measure distance
  digitalWrite(TRIGGER_PIN, LOW); 
  delayMicroseconds(2);
  digitalWrite(TRIGGER_PIN, HIGH); 
  delayMicroseconds(10);
  digitalWrite(TRIGGER_PIN, LOW);
  echo_time = pulseIn(ECHO_PIN, HIGH, 30000);
  distance = (echo_time * 0.034) / 2;
  

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

*/




void movReact() {
  // Use the parsed colorMatrix
  FastLED.clear();
  for (uint8_t y = 0; y < MATRIX_HEIGHT; y++) {
    for (uint8_t x = 0; x < MATRIX_WIDTH; x++) {
      String colorStr = colorMatrix[x][y];
      int firstComma = colorStr.indexOf(',');
      int secondComma = colorStr.indexOf(',', firstComma + 1);
      
      int r = colorStr.substring(0, firstComma).toInt();
      int g = colorStr.substring(firstComma + 1, secondComma).toInt();
      int b = colorStr.substring(secondComma + 1).toInt();
      
      led_strip[mapLeds(XY(x, y), y)] = CRGB(r, g, b);
    }
  }
  FastLED.setBrightness(brightness);
  FastLED.show();
  delay(25);
}


// ---------------------------------------------------------------------------------------
// ------------------------------------ COMMUNICATION ------------------------------------
// ---------------------------------------------------------------------------------------

void recieveInfo() {
  while (Serial.available() > 0) {
    char receivedChar = (char)Serial.read();
    
    if (receivingMatrixData) {
      if (receivedChar == '\r') { // End of full data transmission
        receivingMatrixData = false;
        ledMatrixData += readSerial;
        readSerial = "";
        
        // Process the accumulated data
        parseLedMatrix(ledMatrixData);
        ledMatrixData = "";
      } else if (receivedChar == '\n') { // End of a chunk
        ledMatrixData += readSerial;
        readSerial = "";
      } else {
        readSerial += receivedChar;
      }
    } else {
      readSerial += receivedChar;
      if (receivedChar == '\n') {
        readSerial.trim();
        
        if (readSerial.startsWith("mode_moveReact:")) {
          receivingMatrixData = true;
          ledMatrixData = readSerial;
          readSerial = "";
          mode = 2;
        } else {
          processCommand(readSerial);
          readSerial = "";
        }
      }
    }
  }
}

void processCommand(String command) {
  if (command == "power_on") {
    power = true;
  } else if (command == "power_off") {
    power = false;
  } else if (command == "brightness_down") {
    if (brightness > 10) {
      brightness -= 10;
    }
  } else if (command == "brightness_up") {
    if (brightness < 100) {
      brightness += 10;
    }
  } else if (command.startsWith("picked_color:")) {
    parsePickedColor();
  } else if (command == "mode_solid") {
    mode = 0;
  } else if (command == "mode_soundReact") {
    mode = 1;
  } else if (command == "mode_rainbow") {
    mode = 3;
  }
  Serial.flush(); // Clear the buffer after processing
}

void parsePickedColor() {
  int rgb_tk2 = readSerial.indexOf(",");
  int color_tk = readSerial.lastIndexOf(",");
  pickedColor[0] = readSerial.substring(readSerial.indexOf(":") + 1, rgb_tk2).toInt();
  pickedColor[1] = readSerial.substring(rgb_tk2 + 1, color_tk).toInt();
  pickedColor[2] = readSerial.substring(color_tk + 1).toInt();
}


void parseLedMatrix(String data) {
  int start_tk = data.indexOf(":") + 1; // Start after the "mode_moveReact:" prefix
  String ledMatrixData = data.substring(start_tk);
  
  int colorIndex = 0; // To keep track of the color sets

  for (int x = 0; x < MATRIX_WIDTH; x++) {
    for (int y = 0; y < MATRIX_HEIGHT; y++) {
      int nextSemicolon = ledMatrixData.indexOf(';', colorIndex);
      colorMatrix[x][y] = ledMatrixData.substring(colorIndex, nextSemicolon);
      colorIndex = nextSemicolon + 1;
    }
  }
}
