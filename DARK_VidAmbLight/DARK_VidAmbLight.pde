import processing.video.*;
import processing.serial.*;


final int MATRIX_WIDTH = 20;
final int MATRIX_HEIGHT = 10;
final int VIDEO_WIDTH = 640;
final int VIDEO_HEIGHT = 360;
final int COLOR_PALETTE_SIZE = 10;

color[] colorPalette = {#F6F6F9, #FFF6C8, #FEF580, #F9DF4A, #F8A20F, #9A5F20, #B73E09, #BC0F0A, #640000, #2C0004};
int[][] colorMatrix;

int CELL_WIDTH = VIDEO_WIDTH / MATRIX_WIDTH;
int CELL_HEIGHT = VIDEO_HEIGHT / MATRIX_HEIGHT;
  


Serial arduino;
Movie generic;
PImage frame;




void setup() {
  size(1080, 810);
  
  initUI();
  drawUI();
  
  
  // printArray(Serial.list());
  String portName = Serial.list()[4];
  arduino = new Serial(this, portName, 115200);
  arduino.clear();
  
  generic = new Movie(this, "gow3.mp4");
  
  
  CELL_WIDTH = (width/MATRIX_WIDTH);
  CELL_HEIGHT = (height/MATRIX_HEIGHT);

  colorMatrix = new color[MATRIX_WIDTH][MATRIX_HEIGHT];
  
  colorMode(RGB, 255, 255, 255, 100);
  rectMode(CENTER);
  background(BACKGROUND_COLOR);
  
  
  
  //generic.loop();
}

void draw() {
  background(BACKGROUND_COLOR);
  noStroke();
  drawUI();
  
  if (generic.available() == true) {
    generic.read();
    
    frame = generic.copy();
    frame.loadPixels();

    calculateMatrixColors();
    
    //updateMatrix();
    
    sendMatrix();
  }
}




void sendMatrix() {
  String sendMatrix = "fr:";  
  for (int x = 0; x < MATRIX_WIDTH; x++) {
    for (int y = 0; y < MATRIX_HEIGHT; y++) {
      if (colorMatrix[x][y] != -1) {
        sendMatrix += x + ":" + y + ":" + colorMatrix[x][y] + "\n";
        arduino.write(sendMatrix);
        delay(25);
      }
    }
  }
  arduino.clear();
}

void updateMatrix() {
  for (int i = 0; i < MATRIX_WIDTH; i++) {
    for (int j = 0; j < MATRIX_HEIGHT; j++) {
      int x = i * CELL_WIDTH + CELL_WIDTH / 2;
      int y = j * CELL_HEIGHT + CELL_HEIGHT / 2;
      if (colorMatrix[i][j] != -1)
        fill(colorPalette[colorMatrix[i][j]]);
      else 
        fill(#000000);
      pushMatrix();
      translate(x, y);
      noStroke();
      //rotate((2*PI*saturation(closestColor)/255.0f));
      float side_x = CELL_WIDTH; // ((brightness(colorMatrix[i][j]) / 255.0f) * CELL_WIDTH);
      float side_y = CELL_HEIGHT; // ((brightness(colorMatrix[i][j]) / 255.0f) * CELL_HEIGHT);
      rect(0, 0, side_x, side_y);
      popMatrix();
    }
  }
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
      int closestColor = findClosestColor(c, colorPalette);
      
      // If the closest color distance is above a threshold, set it to black
      if (colorDistance(c, colorPalette[closestColor]) > 50) { // Adjust the threshold as needed
        colorMatrix[i][j] = -1; // Black
      } else {
        colorMatrix[i][j] = closestColor;
      }
    }
  }
}

int findClosestColor(color c, color[] palette) {
  float minDistance = Float.MAX_VALUE;
  int closestColor = -1;
  
  int cl = 0;
  for (color paletteColor : palette) {
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
