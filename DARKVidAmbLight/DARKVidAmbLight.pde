import processing.video.Movie;
import processing.serial.*;
import controlP5.*;


final int VIDEO_WIDTH = 1280;
final int VIDEO_HEIGHT = 720;
final int COLOR_PALETTE_SIZE = 10;
final int FRAME_RATE_INTERVAL = 1500;

color[] colorPalette = {#F6F6F9, #FFF6C8, #FEF580, #F9DF4A, #F8A20F, #9A5F20, #B73E09, #BC0F0A, #640000, #2C0004};
boolean[] selectedColors;

final int NUM_LEDS = 228;
final int LAST_VISIBLE_LED = 227;

final int ORIGINAL_MATRIX_WIDTH = 20;
final int ORIGINAL_MATRIX_HEIGHT = 10;
final int MATRIX_WIDTH = ORIGINAL_MATRIX_WIDTH / 2;
final int MATRIX_HEIGHT = ORIGINAL_MATRIX_HEIGHT / 2;


final int CELL_WIDTH = VIDEO_WIDTH / MATRIX_WIDTH;
final int CELL_HEIGHT = VIDEO_HEIGHT / MATRIX_HEIGHT;

color[][] ledMatrix;

Serial arduino;
Movie video;

PImage frame;
boolean play;

int lastFrameTime = 0;

boolean readFrame = true;


void setup() {
  size(1080, 810);
  frameRate(30);
  
  play = false;
  
  initUI();
  drawUI();

  //printArray(Serial.list());
  String portName = Serial.list()[4];
  arduino = new Serial(this, portName, 115200);
  arduino.clear();


  ledMatrix = new color[MATRIX_WIDTH][MATRIX_HEIGHT];
  
  
  
  colorMode(RGB, 255, 255, 255, 100);
  rectMode(CENTER);
  background(BACKGROUND_COLOR);
  
  
  video = new Movie(this, "gow3.mp4");
  
  
  video.loop();
  video.jump(16.0);
  video.pause();
  
   

}

void draw() {
  background(BACKGROUND_COLOR);
  noStroke();
  drawUI();
  
  if (play) {
    video.loop();
  }
  
  
  
  
}


void movieEvent(Movie title) {
  if (millis() - lastFrameTime >= FRAME_RATE_INTERVAL) {
    //readFrame = false;
    lastFrameTime = millis();
    
    title.read();
    frame = title.copy();
    frame.loadPixels();
  
    calculateMatrixColors();
    //updateMatrix();
    sendMatrixFrame();
  }
}
