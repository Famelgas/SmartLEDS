

// ------------------------------------------------------------------------------------------------------- LEDS


int XY (int x, int y) {
  // any out of bounds address maps to the first hidden pixel
  if ( (x >= MATRIX_WIDTH) || (y >= MATRIX_HEIGHT) ) {
    return (LAST_VISIBLE_LED + 1);
  }

  int XYTable[] = {
     0,   1,   2,   3,   4,   5,   6,   7,   8,   9,
    19,  18,  17,  16,  15,  14,  13,  12,  11,  10,
    20,  21,  22,  23,  24,  25,  26,  27,  28,  29,
    39,  38,  37,  36,  35,  34,  33,  32,  31,  30,
    40,  41,  42,  43,  44,  45,  46,  47,  48,  49
  };

  int i = (y * MATRIX_WIDTH) + x;
  int j = XYTable[i];
  return j;
}



// ------------------------------------------------------------------------------------------------------- LEDS


void sendMatrixFrame() {

  
  for (int x = 0; x < MATRIX_WIDTH; x++) {
    for (int y = 0; y < MATRIX_HEIGHT; y++) {
      int index = XY(x, y);
      int colorIndex = led_strip[XY(x, y)];
          
      arduino.write(":" + index + ":" + colorIndex + "\n");
      delay(5);
    }
  }

  arduino.clear();
  delay(25);
}



void calculateMatrixColors() {
  for (int i = 0; i < MATRIX_WIDTH; i++) {
    for (int j = 0; j < MATRIX_HEIGHT; j++) {
       //int invert_y = MATRIX_HEIGHT - 1 - j;

      int x = i * CELL_WIDTH + CELL_WIDTH / 2;
      int y = j * CELL_HEIGHT + CELL_HEIGHT / 2;
      int loc = x + y * frame.width;
      loc = constrain(loc, 0, frame.pixels.length - 1);

      color c = color(red(frame.pixels[loc]), green(frame.pixels[loc]), blue(frame.pixels[loc]));

      // Find the closest color in the palette
      int closestColor = findClosestColor(c);

      // If the closest color distance is above a threshold, set it to black
      if (colorDistance(c, colorPalette[closestColor]) > 100) { // Adjust the threshold as needed
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
