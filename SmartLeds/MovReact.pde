import processing.video.*;


class MovReact {
  int CELL_WIDTH;
  int CELL_HEIGHT;

  
  MovReact() {

    CELL_WIDTH = (width/MATRIX_WIDTH);
    CELL_HEIGHT = (height/MATRIX_HEIGHT);
    
    
  
  }
  
  
  void calculateMatrixColors() {
    for (int i = 0; i < MATRIX_WIDTH; i++) {
      for (int j = 0; j < MATRIX_HEIGHT; j++) {
        int invert_x = MATRIX_WIDTH - 1 - i;
        
        int x = i * CELL_WIDTH + CELL_WIDTH / 2;
        int y = j * CELL_HEIGHT + CELL_HEIGHT / 2;
        int loc = x + y * frame.width;
        loc = constrain(loc, 0, frame.pixels.length - 1);
  
        color c = color(red(frame.pixels[loc]), green(frame.pixels[loc]), blue(frame.pixels[loc]));
  
        // Find the closest color in the palette
        color closestColor = findClosestColor(c, colorPalette);
        
        // If the closest color distance is above a threshold, set it to black
        if (colorDistance(c, closestColor) > 100) { // Adjust the threshold as needed
          ledMatrix[invert_x][j] = color(0, 0, 0); // Black
        } else {
          ledMatrix[invert_x][j] = closestColor;
        }
      }
    }
  }
  
  
  void updateMatrix() {
    rectMode(CENTER);
    
    for (int i = 0; i < MATRIX_WIDTH; i++) {
      for (int j = 0; j < MATRIX_HEIGHT; j++) {
        int x = i * CELL_WIDTH + CELL_WIDTH / 2;
        int y = j * CELL_HEIGHT + CELL_HEIGHT / 2;
        fill(ledMatrix[i][j]);
        pushMatrix();
        translate(x, y);
        noStroke();
        //rotate((2*PI*saturation(closestColor)/255.0f));
        float side_x = ((brightness(ledMatrix[i][j]) / 255.0f) * CELL_WIDTH);
        float side_y = ((brightness(ledMatrix[i][j]) / 255.0f) * CELL_HEIGHT);
        rect(0, 0, side_x, side_y);
        popMatrix();
      }
    }
  }
  
  
  color findClosestColor(color c, color[] palette) {
    float minDistance = Float.MAX_VALUE;
    color closestColor = color(0, 0, 0);
    
    for (color paletteColor : palette) {
      float distance = colorDistance(c, paletteColor);
      
      if (distance < minDistance) {
        minDistance = distance;
        closestColor = paletteColor;
      }
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
    
  
  
  
  
  
  
}
