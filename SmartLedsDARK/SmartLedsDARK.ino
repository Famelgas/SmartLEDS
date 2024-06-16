#include <FastLED.h>

// ---------------------- PINS ----------------------
#define LED_DATA_IN_PIN 3 // led strip data in

// ---------------------- LEDS ----------------------
#define NUM_LEDS 228
#define MATRIX_WIDTH 20 
#define MATRIX_HEIGHT 10
#define LAST_VISIBLE_LED 199

CRGB led_strip[ NUM_LEDS ];

// ---------------------- GLOBAL ----------------------
bool ledsOn;
int brightness;
int mode;
int pickedColor[3];


// -------------------------------------------------------------------------------
// ------------------------------------ SETUP ------------------------------------
void setup() {
  Serial.begin(115200);

  ledsOn = true;
  mode=0;
  brightness = 200;
  pickedColor[0] = 255;
  pickedColor[1] = 138;
  pickedColor[2] = 18;

  FastLED.addLeds<WS2812B, LED_DATA_IN_PIN, GRB>(led_strip, NUM_LEDS).setCorrection(TypicalSMD5050);
  FastLED.setBrightness(brightness);
  FastLED.clear();
}


// ------------------------------------------------------------------------------
// ------------------------------------ LOOP ------------------------------------
void loop() {
  FastLED.clear();

  String readSerial = "";

  while (Serial.available() > 0) {
    char receivedChar = (char)Serial.read();
  
    readSerial += receivedChar;
    if (receivedChar == '\n') {
      readSerial.trim();

      if (readSerial == "power_on") {
        ledsOn = true;
      } else if (readSerial.startsWith("picked_color:")) {
        parsePickedColor(readSerial);
      } else if (readSerial == "mode_solid") {
        mode = 0;
      } else if (readSerial == "mode_proximity") {
        mode = 1;
      } else if (readSerial == "mode_brightness") {
        mode = 2;
      } else if (readSerial == "mode_rainbow") {
        mode = 3;
      }
      Serial.flush(); // Clear the buffer after processing
      readSerial = "";
      break;
    }
  }

  Serial.flush();
  
  if (ledsOn) {
    switch (mode) {
      case 0: // solid color
        solid(CRGB(pickedColor[0], pickedColor[1], pickedColor[2]));
        break;      
      case -1: // error
        fill_solid(led_strip, NUM_LEDS, CRGB(CRGB::Orange));
        break;
    }
    FastLED.setBrightness(brightness);
  }
  else {
    FastLED.clear();
    FastLED.setBrightness(0);
  }
  
  FastLED.show(); // Display the updated LEDs
}


// ------------------------------------------------------------------------------
// ------------------------------------ LEDS ------------------------------------
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
void parsePickedColor(String pckColor) {
  int rgb_tk2 = pckColor.indexOf(",");
  int color_tk = pckColor.lastIndexOf(",");
  pickedColor[0] = pckColor.substring(pckColor.indexOf(":") + 1, rgb_tk2).toInt();
  pickedColor[1] = pckColor.substring(rgb_tk2 + 1, color_tk).toInt();
  pickedColor[2] = pckColor.substring(color_tk + 1).toInt();
}

void solid(const struct CRGB & color) {
  for (uint8_t y = 0; y < MATRIX_HEIGHT; y++) {
    for (uint8_t x = 0; x < MATRIX_WIDTH; x++) {
      led_strip[mapLeds(XY(x, y), y)] = color;
    }
  }
  FastLED.setBrightness(brightness);
  delay(25);
}





