
// ------------------------------------------------------------------------------------------------------- LEDS

int  XY (int x, int y) {
  // any out of bounds address maps to the first hidden pixel
  if ( (x >= MATRIX_WIDTH) || (y >= MATRIX_HEIGHT) ) {
    return (LAST_VISIBLE_LED + 1);
  }

  int XYTable[] = {
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
  
  int i = (y * MATRIX_WIDTH) + x;
  int j = XYTable[i];
  return j;
}



void sendMatrixFrame() {
  int ms = millis();
  int dl = 0;
  
  for (int x = 0; x < MATRIX_WIDTH; x++) {
    for (int y = 0; y < MATRIX_HEIGHT; y++) {
      int index = XY(x, y);
      int colorIndex = led_strip[XY(x, y)];
          
      arduino.write(":" + index + ":" + colorIndex + "\n");
      
      delay(5);
    }
  }
  
  dl = millis() - ms;
  println("delay: " + dl);
  arduino.clear();
}



void calculateMatrixColors() {
  for (int i = 0; i < MATRIX_WIDTH; i++) {
    for (int j = 0; j < MATRIX_HEIGHT; j++) {
      // int invert_x = MATRIX_WIDTH - 1 - i;

      int x = i * CELL_WIDTH + CELL_WIDTH / 2;
      int y = j * CELL_HEIGHT + CELL_HEIGHT / 2;
      int loc = x + y * frame.width;
      loc = constrain(loc, 0, frame.pixels.length - 1);

      color c = color(red(frame.pixels[loc]), green(frame.pixels[loc]), blue(frame.pixels[loc]));

      // Find the closest color in the palette
      int closestColor = findClosestColor(c);

      // If the closest color distance is above a threshold, set it to black
      if (colorDistance(c, colorPalette[closestColor]) > 50) { // Adjust the threshold as needed
        led_strip[XY(i, j)] = 10; // Black
      } else {
        led_strip[XY(i, j)] = closestColor;
      }
    }
  }
}

int findClosestColor(color c) {
  float minDistance = Float.MAX_VALUE;
  int closestColor = -1;

  int cl = 0;
  for (color paletteColor : colorPalette) {
    float distance = colorDistance(c, paletteColor);

    if (distance < minDistance) {
      minDistance = distance;
      closestColor = cl;
    }

    cl++;
  }

  return closestColor;
}

float colorDistance(color c1, color c2) {
  float r1 = red(c1);
  float g1 = green(c1);
  float b1 = blue(c1);

  float r2 = red(c2);
  float g2 = green(c2);
  float b2 = blue(c2);

  return dist(r1, g1, b1, r2, g2, b2);
}
