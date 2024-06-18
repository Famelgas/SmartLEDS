#include <FastLED.h>

// ---------------------- PINS ----------------------
#define LED_DATA_IN_PIN 3  // led strip data in

// ---------------------- LEDS ----------------------
#define NUM_LEDS 228
#define ORIGINAL_MATRIX_WIDTH 20
#define ORIGINAL_MATRIX_HEIGHT 10
#define MATRIX_WIDTH (ORIGINAL_MATRIX_WIDTH / 2)
#define MATRIX_HEIGHT (ORIGINAL_MATRIX_HEIGHT / 2)
#define LAST_VISIBLE_LED 227

CRGB led_strip[NUM_LEDS];

// ---------------------- GLOBAL ----------------------
bool play;
int brightness;
uint32_t colorPalette[10] = {0xF6F6F9, 0xFFF6C8, 0xFEF580, 0xF9DF4A, 0xF8A20F, 0x9A5F20, 0xB73E09, 0xBC0F0A, 0x640000, 0x2C0004};
boolean selectedColors[10];


// -------------------------------------------------------------------------------
// ------------------------------------ SETUP ------------------------------------
void setup() {
  Serial.begin(115200);
  
  play = false;
  brightness = 100;

  for (int i = 0; i < 10; i++) {
    selectedColors[i] = true;
  }
  
  //delay(3000); // power-up safety delay
  FastLED.addLeds<WS2812B, LED_DATA_IN_PIN, GRB>(led_strip, NUM_LEDS).setCorrection(TypicalSMD5050);
  FastLED.setMaxRefreshRate(0);
  FastLED.clear();
  FastLED.setBrightness(brightness);
}


// ------------------------------------------------------------------------------
// ------------------------------------ LOOP ------------------------------------
void loop() {
  String readSerial = "";
  // while there's any serial available, read it:
  while (Serial.available() > 0) {
    readSerial = Serial.readStringUntil('\n');
    Serial.println(readSerial);

    if (!play) {
      while (readSerial != "play") {
        ;
      }
      play = true;
    }
    else {
      if (readSerial == "brightDown") {
        if (brightness > 10) {
          brightness -= 10;
        }
      } 
      else if (readSerial == "brightUp") {
        if (brightness < 200) {
          brightness += 10;
        }
      } 

      else if (readSerial == "pause") {
        play = false;
        break;
      } 
      else if (readSerial == "replay") {
        FastLED.clear(true);
        break;
      } 
      else if (readSerial.startsWith("sc:")) {
        updateSelectedColors(readSerial);
      } 
      else if (readSerial.startsWith(":")) {
        updateMatrix(readSerial);
      } 

      FastLED.setBrightness(brightness);
      FastLED.show();
    }
    
    
  }

  
  Serial.flush();
  FastLED.clear();
  delay(100);
}

// ------------------------------------------------------------------------------
// ------------------------------------ LEDS ------------------------------------

uint16_t XY (uint8_t x, uint8_t y) {
  // Adjust for the new reduced resolution
  x *= 2;
  y *= 2;
  // any out of bounds address maps to the first hidden pixel
  if ( (x >= ORIGINAL_MATRIX_WIDTH) || (y >= ORIGINAL_MATRIX_HEIGHT) ) {
    return (LAST_VISIBLE_LED + 1);
  }

  const uint8_t XYTable[] = {
      1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,  14,  15,  16,  17,  18,  19,  20,
     43,  42,  41,  40,  39,  38,  37,  36,  35,  34,  33,  32,  31,  30,  29,  28,  27,  26,  25,  24,
     47,  48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  62,  63,  64,  65,  66,
     89,  88,  87,  86,  85,  84,  83,  82,  81,  80,  79,  78,  77,  76,  75,  74,  73,  72,  71,  70,
     93,  94,  95,  96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112,
    135, 134, 133, 132, 131, 130, 129, 128, 127, 126, 125, 124, 123, 122, 121, 120, 119, 118, 117, 116,
    139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158,
    181, 180, 179, 178, 177, 176, 175, 174, 173, 172, 171, 170, 169, 168, 167, 166, 165, 164, 163, 162,
    185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204,
    227, 226, 225, 224, 223, 222, 221, 220, 219, 218, 217, 216, 215, 214, 213, 212, 211, 210, 209, 208
  };
  
  uint8_t i = (y * ORIGINAL_MATRIX_WIDTH) + x;
  return XYTable[i];
}

// -------------------------------------------------------------------------------
// ------------------------------------ MODES ------------------------------------

void solid(const struct CRGB& color) {
  for (uint8_t y = 0; y < MATRIX_HEIGHT; y++) {
    for (uint8_t x = 0; x < MATRIX_WIDTH; x++) {
      uint16_t baseIndex = XY(x, y);
      led_strip[baseIndex] = color;
      led_strip[baseIndex + 1] = color;
      led_strip[baseIndex + ORIGINAL_MATRIX_WIDTH] = color;
      led_strip[baseIndex + ORIGINAL_MATRIX_WIDTH + 1] = color;
    }
  }
  FastLED.setBrightness(brightness);
  //delay(25);
}


void updateSelectedColors(String readSerial) {
  String prsColor = readSerial.substring(readSerial.indexOf(":") + 1);
  int tk = prsColor.indexOf(":");
  int i = prsColor.substring(0, tk).toInt();
  int state = prsColor.substring(tk + 1).toInt();
  if (state == 1)
    selectedColors[i] = true;
  else
    selectedColors[i] = false;
}


void updateMatrix(String readSerial) {
  String ledColor = readSerial.substring(readSerial.indexOf(":") + 1);
  int tk = ledColor.indexOf(":");
  int index = ledColor.substring(0, tk).toInt();
  int color = ledColor.substring(tk + 1).toInt();

  //  if (selectedColors[color])
  if (color == 10)
    led_strip[index] = CRGB(0x000000);
  else
    led_strip[index] = colorPalette[color];


}

void updateMatrix(String readSerial) {
  String ledColor = readSerial.substring(readSerial.indexOf(":") + 1);
  int tk = ledColor.indexOf(":");
  int index = ledColor.substring(0, tk).toInt();
  int color = ledColor.substring(tk + 1).toInt();

  if (color == 10)
    color = 0x000000;
  else
    color = colorPalette[color];

  // Update the group of 4 LEDs
  led_strip[index] = color;
  led_strip[index + 1] = color;
  led_strip[index + ORIGINAL_MATRIX_WIDTH] = color;
  led_strip[index + ORIGINAL_MATRIX_WIDTH + 1] = color;
}



