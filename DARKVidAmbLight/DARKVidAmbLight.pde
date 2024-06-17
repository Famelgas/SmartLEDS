import processing.video.Movie;
import processing.serial.*;
import controlP5.*;


final int VIDEO_WIDTH = 640;
final int VIDEO_HEIGHT = 360;
final int MATRIX_WIDTH = 10;
final int MATRIX_HEIGHT = 5;
final int COLOR_PALETTE_SIZE = 10;
final int FRAME_RATE_INTERVAL = 1000;

color[] colorPalette = {#F6F6F9, #FFF6C8, #FEF580, #F9DF4A, #F8A20F, #9A5F20, #B73E09, #BC0F0A, #640000, #2C0004};
int[][] colorMatrix;

int CELL_WIDTH = VIDEO_WIDTH / MATRIX_WIDTH;
int CELL_HEIGHT = VIDEO_HEIGHT / MATRIX_HEIGHT;


Serial arduino;
Movie video;

PImage frame;
boolean play;

int lastFrameTime = 0;


void setup() {
  size(1080, 810);
  frameRate(30);
  
  play = false;
  
  println("antes");
  initUI();
  drawUI();

  //printArray(Serial.list());
  String portName = Serial.list()[4];
  arduino = new Serial(this, portName, 115200);
  arduino.clear();

  
  colorMatrix = new int[MATRIX_WIDTH][MATRIX_HEIGHT];
  
  colorMode(RGB, 255, 255, 255, 100);
  rectMode(CENTER);
  background(BACKGROUND_COLOR);
  
  
  video = new Movie(this, "gow3.mp4");
  
  
  //video.loop();
  //video.jump(0.0);
  //video.pause();
  
  
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
    lastFrameTime = millis();
    
    title.read();
    frame = title.copy();
    frame.loadPixels();
  
    calculateMatrixColors();
    //updateMatrix();
    sendMatrixFrame();
  }
}
