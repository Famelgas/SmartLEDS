
// ------------------------------------------------------------------------------------------------------- LEDS

int XY(int x, int y) {
  x *= 2;
  y *= 2;
  if ((x >= ORIGINAL_MATRIX_WIDTH) || (y >= ORIGINAL_MATRIX_HEIGHT)) {
    return (LAST_VISIBLE_LED + 1);
  }

  int[] XYTable = {
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

  int i = (y * ORIGINAL_MATRIX_WIDTH) + x;
  return XYTable[i];
}


void sendMatrixFrame() {
  calculateMatrixColors();
  for (int x = 0; x < MATRIX_WIDTH; x++) {
    for (int y = 0; y < MATRIX_HEIGHT; y++) {
      int colorIndex = findClosestColor(ledMatrix[x][y]);
      int ledIndex = XY(x, y);
      arduino.write(":" + ledIndex + ":" + colorIndex + "\n");
    }
  }
}


void calculateMatrixColors() {
  for (int x = 0; x < MATRIX_WIDTH; x++) {
    for (int y = 0; y < MATRIX_HEIGHT; y++) {
      
      color avgColor = color(0, 0, 0);
      
      for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
          int px = (x * 2 + i) * (frame.width / ORIGINAL_MATRIX_WIDTH);
          int py = (y * 2 + j) * (frame.height / ORIGINAL_MATRIX_HEIGHT);
      
          avgColor = lerpColor(avgColor, get(px, py), 0.25);
        }
      }
      
      ledMatrix[x][y] = avgColor;
    }
  }
}

 //<>//
int findClosestColor(color c) {
  float minDistance = Float.MAX_VALUE;
  int closestColor = 10;
  
  for (int i = 0; i < colorPalette.length; i++) {
    if (selectedColors[i]) {
      float d = dist(red(c), green(c), blue(c), red(colorPalette[i]), green(colorPalette[i]), blue(colorPalette[i]));
      if (d < minDistance) {
        minDistance = d;
        closestColor = i;
      }
    }
  }
  return closestColor;
}
