import controlP5.*;
import processing.serial.*;
import processing.video.*;




// --------------------------------------------------------- //
// ----------------------- CONSTANTS ----------------------- //
// --------------------------------------------------------- //


// ----------------------- COLORS ----------------------- //

final color NO_COLOR = color(0, 0, 0, 0);
final color UI_WHITE = color(240, 240, 240);
final color WARM_WHITE = color(255, 138, 18);
final color BACKGROUND_COLOR = color(28, 28, 30);
final color WRAP_BOX_COLOR = color(46, 41, 46);
final color TOGGLE_OFF_COLOR = color(68, 66, 70);
final color TOGGLE_ON_COLOR = color(255, 42, 131);


// reds
color HEX_CA1421 = color(202, 20, 30);
color HEX_F0000E = color(240, 0, 14);
color HEX_C13C00 = color(193, 60, 0);
color HEX_FF6C3D = color(255, 108, 61);
color HEX_FFCF73 = color(255, 207, 115);
color HEX_FFF5A5 = color(255, 245, 165);

color[] colorPalette = {HEX_CA1421, HEX_F0000E, HEX_C13C00, HEX_FF6C3D, HEX_FFCF73, HEX_FFF5A5};


// blues
color HEX_001220 = color(0, 18, 32);
color HEX_063356 = color(6, 51, 86);
color HEX_078FEF = color(7, 143, 239);
color HEX_1491AE = color(20, 145, 174);
color HEX_399FD7 = color(57, 159, 215);
color HEX_54F5F5 = color(84, 245, 245);

// color[] colorPalette = {HEX_001220, HEX_063356, HEX_078FEF, HEX_1491AE, HEX_399FD7, HEX_54F5F5};

// reds and blues
//color[] colorPalette = {HEX_001220, HEX_063356, HEX_078FEF, HEX_1491AE, HEX_399FD7, HEX_54F5F5, HEX_CA1421, HEX_F0000E, HEX_C13C00, HEX_FF6C3D, HEX_FFCF73, HEX_FFF5A5};




// ----------------------- SIZES ----------------------- //

final int MARGIN_H = 20;
final int MARGIN_V = 30;
final int PADDING_V = 10;
final int PADDING_H = 20;
final int COLOR_WHEEL_PADDING_V = 14;
final int SPACING_V = 30;
final int CORNER_RADIUS = 21;

final int TOGGLE_WIDTH = 80;
final int TOGGLE_HEIGHT = 45;

final int ROUND_BUTTON_SIZE = 45;

final int COLOR_WHEEL_OUT_SIZE = 230;
final int COLOR_WHEEL_INNER_SIZE = 109;
final int COLOR_WHEEL_STROKE_WEIGHT = 4;
final int COLOR_WHEEL_NUM_SEGM = 300;

final int PICKED_COLOR_SIZE = COLOR_WHEEL_INNER_SIZE - 30;

final int SLIDER_WIDTH = 320;
final int SLIDER_HEIGHT = 32;
final int SLIDER_CR_WIDTH = 16;
final int SLIDER_CR_HEIGHT = 32;

final int SELECTOR_SIZE = 25;
final int LABEL_OFFSET = 3;


final int MATRIX_WIDTH = 20;
final int MATRIX_HEIGHT = 10;
int CELL_WIDTH;
int CELL_HEIGHT;
String[][] ledMatrix = new String[MATRIX_WIDTH][MATRIX_HEIGHT];
String stringLedMatrix;


// --------------------------------------------------------- //
// ----------------------- VARIABLES ----------------------- //
// --------------------------------------------------------- //

Serial arduino;

Capture webcam;
boolean webcamOn;
PImage frame;
int lastFrameMillis;



ControlP5 ui_comps;
Toggle[] mainMenuToggles;
Label[] mainMenuLables;
Button powerButton;
Button minusBrightButton;
Button plusBrightButton;





PImage[] images = new PImage[11];

String[] uiComponents = new String[4];
String[] modes = new String[4];
String[] label_names = new String[4];
String brightnessSlider = "brightness";



boolean power;
int brightness;
color pickedColor;
int mode;

int cwX;
int cwY;


// ------------------------------------------------------//
// ----------------------- SETUP ----------------------- //
// ----------------------------------------------------- //


void setup() {
  // ----------------------- SERIAL ARDUINO ----------------------- //
  
  printArray(Serial.list());
  String portName = Serial.list()[4];
  arduino = new Serial(this, portName, 9600);
  arduino.clear();
  
  // ----------------------- WEB CAM ----------------------- //
  
  webcamOn = false;
  String[] cameras = Capture.list();
  String camera = cameras[0];
  for (String c : cameras) {
    if (c == "Full HD webcam") camera = c;
  }
  
  webcam = new Capture(this, 640, 480, camera);
  
  println(camera);
  
  CELL_WIDTH = (width/MATRIX_WIDTH);
  CELL_HEIGHT = (height/MATRIX_HEIGHT);
  
  ledMatrix = new String[MATRIX_WIDTH][MATRIX_HEIGHT];
  stringLedMatrix = "mode_moveReact:";
    
   
  // ----------------------- WINDOW ----------------------- //

  size(400, 800);
  colorMode(RGB, 255, 255, 255, 100);

  // ----------------------- VARIABLES ----------------------- //

  PFont pfont = createFont("Inter-Regular", 17, true);
  ControlFont font = new ControlFont(pfont, 17);

  ui_comps = new ControlP5(this);
  mainMenuToggles = new Toggle[modes.length];
  
  
  power = true ;
  brightness = 6;
  pickedColor = WARM_WHITE;
  mode = 0;

  cwX = width/2 - COLOR_WHEEL_OUT_SIZE / 2;  
  cwY = MARGIN_V + 2 * PADDING_V + 4 * TOGGLE_HEIGHT + 4 * SPACING_V + COLOR_WHEEL_PADDING_V;
  

  uiComponents[0] = "button_";
  uiComponents[1] = "slider_";
  uiComponents[2] = "toggle_";
  uiComponents[3] = "label_";

  modes[0] = "mode_solid";
  modes[1] = "mode_soundReact";
  modes[2] = "mode_moveReact";
  modes[3] = "mode_rainbow";

  label_names[0] = "Solid Color";
  label_names[1] = "Sound Reaction";
  label_names[2] = "Movement Reaction";
  label_names[3] = "Rainbow";

  images[0] = loadImage("toggle-off.png");
  images[1] = loadImage("toggle-on.png");
  images[2] = loadImage("power-off.png");
  images[3] = loadImage("power-on.png");
  images[4] = loadImage("color-wheel-230px.png");
  images[5] = loadImage("slider-corner-radius-left.png");
  images[6] = loadImage("slider-corner-radius-right.png");
  images[7] = loadImage("bright-minus.png");
  images[8] = loadImage("bright-minus-pressed.png");
  images[9] = loadImage("bright-plus.png");
  images[10] = loadImage("bright-plus-pressed.png");
  
  
  // ----------------------- MAIN MENU ----------------------- //

  // 30px margin from the right edge
  int toggleX = width - 120;
  int toggleY = MARGIN_V + PADDING_V;
  // 30px margin from the left edge
  int labelX = MARGIN_V + PADDING_V;;


  for (int i = 0; i < modes.length; i++) {
    mainMenuToggles[i] = ui_comps.addToggle(uiComponents[2] + modes[i])
      .setPosition(toggleX, toggleY)
      .setSize(TOGGLE_WIDTH, TOGGLE_HEIGHT)
      .setImages(images[0], images[1])
      .setId(i)
      .setValue(false);
      
    ui_comps.addTextlabel(uiComponents[3] + modes[i])
      .setPosition(labelX, toggleY + 16)
      .setColorValue(UI_WHITE)
      .setText(label_names[i]) 
      .setFont(font);
    
    toggleY += TOGGLE_HEIGHT + SPACING_V;
  }
  
  mainMenuToggles[0].setState(true);
  
  
  // ----------------------- UI ----------------------- //
  
  // brightness
  int brightX = MARGIN_H + 4*PADDING_H;
  int brightY = height - MARGIN_V - PADDING_V - 2 * ROUND_BUTTON_SIZE - SPACING_V;
  
  // brightnessMinus
  minusBrightButton = ui_comps.addButton(uiComponents[0] + "brightness_minus")
    .setPosition(brightX, brightY)
    .setSize(ROUND_BUTTON_SIZE, ROUND_BUTTON_SIZE)
    .setImages(images[7], images[7], images[8]);
  
  // brightnessPlus
  brightX = width - MARGIN_H - 4*PADDING_H - ROUND_BUTTON_SIZE;
  plusBrightButton = ui_comps.addButton(uiComponents[0] + "brightness_plus")
    .setPosition(brightX, brightY)
    .setSize(ROUND_BUTTON_SIZE, ROUND_BUTTON_SIZE)
    .setImages(images[9], images[9], images[10]); 
    

  // power button
  int powerX = width/2 - 45/2;
  int powerY = height - MARGIN_V - PADDING_V - ROUND_BUTTON_SIZE;

  powerButton = ui_comps.addButton(uiComponents[0] + "power")
    .setPosition(powerX, powerY)
    .setSize(ROUND_BUTTON_SIZE, ROUND_BUTTON_SIZE)
    .setImages(images[2], images[2], images[3]);
    
  
  // ----------------------- EVENT CONTROLLERS ----------------------- //
  
  
  for(Toggle toggle : mainMenuToggles) {
    
    toggle.addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_PRESS) {
          if (toggle.getState()) {
            if (toggle.equals(mainMenuToggles[2])) {
              webcamOn = true;
              webcam.start();
            }
            
            for(Toggle off_toggle : mainMenuToggles) {
              if (!off_toggle.equals(toggle)) {
                if (off_toggle.equals(mainMenuToggles[2])) {
                  webcamOn = false;
                  webcam.stop();
                }
                off_toggle.setState(false);
              }
            }
            
          }
          else {
            if (toggle.equals(mainMenuToggles[2])) {
              webcamOn = false;
              webcam.stop();
            }
          }
          mode = toggle.getId();
          println("m: "+mode);
          sendMode();
        }
      }
    });
      
  }
  
  // brightnessMinus
  minusBrightButton.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (theEvent.getAction() == ControlP5.ACTION_PRESS) {
        if (brightness > 10) {
          brightness--;
        }
        sendBrightness("down");
      }  
    }
  });
  
  
  // brightnessPlus  
  plusBrightButton.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (theEvent.getAction() == ControlP5.ACTION_PRESS) {
        if (brightness < 10) {
          brightness++;
        }
        sendBrightness("up");
      };
    }
  });
  
  // power button
  powerButton.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (theEvent.getAction() == ControlP5.ACTION_PRESS) {
        power = !power;
        println("p: "+power);
        sendPower();
        for(Toggle toggle : mainMenuToggles) {
          toggle.setState(false);
        }
      }
    }    
  });

  
}




// ---------------------------------------------------- //
// ----------------------- DRAW ----------------------- //
// ---------------------------------------------------- //


void draw() {
  background(BACKGROUND_COLOR);
  noStroke();
  
  drawApp();
  
  //  == true && (millis() - lastFrameMillis) > 750
  if (webcamOn) {
    sendMovMatrix();
    //delay(200);
  }
  
  //delay(200);

}






// ------------------------------------------------------- //
// ----------------------- METHODS ----------------------- //
// ------------------------------------------------------- //


// ----------------------- APP ----------------------- //

void drawApp() {
  // ----------------------- MAIN MENU ----------------------- //
  
  // main menu wrap
  int toggleRows_mainMenu = modes.length;
  int wrapBoxX_mainMenu = MARGIN_H;
  int wrapBoxY_mainMenu = MARGIN_V;
  int wrapBoxWidth_mainMenu = width - 2 * MARGIN_H;
  int wrapBoxHeight_mainMenu = 2 * PADDING_V + 4 * TOGGLE_HEIGHT + 3 * SPACING_V;
  
  wrapBox(toggleRows_mainMenu, wrapBoxX_mainMenu, wrapBoxY_mainMenu, wrapBoxWidth_mainMenu, wrapBoxHeight_mainMenu, true);
  
  
  // ----------------------- COLOR WHEEL ----------------------- //
  
  // color wheel wrap
  int wrapBoxX_colorWheel = MARGIN_H;
  int wrapBoxY_colorWheel = MARGIN_V + SPACING_V + wrapBoxHeight_mainMenu;
  // w = 360
  int wrapBoxWidth_colorWheel = width - 2 * MARGIN_H;
  int wrapBoxHeight_colorWheel = 2 * COLOR_WHEEL_PADDING_V + COLOR_WHEEL_OUT_SIZE;
  
  // Draw wrap for the color wheel
  wrapBox(0, wrapBoxX_colorWheel, wrapBoxY_colorWheel, wrapBoxWidth_colorWheel, wrapBoxHeight_colorWheel, false);
  
  
  // load color wheel
  
  image(images[4], cwX, cwY, COLOR_WHEEL_OUT_SIZE, COLOR_WHEEL_OUT_SIZE);
  
  
  int pckColorX = cwX + COLOR_WHEEL_OUT_SIZE / 2;
  int pckColorY = cwY + COLOR_WHEEL_OUT_SIZE / 2;
  
  noStroke();
  fill(pickedColor);
  ellipse(pckColorX, pckColorY, PICKED_COLOR_SIZE, PICKED_COLOR_SIZE);

  
  // ----------------------- UI ----------------------- //
  
  // ui buttons wrap
  // 2 linhas - bright+ e bright- estao na mesma linha
  int uiButtonsRows = 2;
  int wrapBoxX_uiButtons = MARGIN_H;
  
  int wrapBoxWidth_uiButtons = width - 2 * MARGIN_H;
  int wrapBoxHeight_uiButtons = 2 * PADDING_V + 2 * ROUND_BUTTON_SIZE + SPACING_V;
  
  int wrapBoxY_uiButtons = height - MARGIN_V - wrapBoxHeight_uiButtons;
  
  wrapBox(uiButtonsRows, wrapBoxX_uiButtons, wrapBoxY_uiButtons, wrapBoxWidth_uiButtons, wrapBoxHeight_uiButtons, true);
  
}




// ----------------------- WRAP BOX ----------------------- //

void wrapBox(int nRows, int rectX, int rectY, int rectWidth, int rectHeight, boolean lines) {
  fill(WRAP_BOX_COLOR);
  noStroke();
  rect(rectX, rectY, rectWidth, rectHeight, CORNER_RADIUS);

  int lineX1 = rectX + PADDING_H + LABEL_OFFSET;
  int lineX2 = rectX + rectWidth - PADDING_H - LABEL_OFFSET;

  if (lines) {
    for (int i = 0; i < nRows - 1; i++) {
      int lineY = rectY + 70 + i * 75;      
      stroke(TOGGLE_OFF_COLOR);
      strokeWeight(1);
      line(lineX1, lineY, lineX2, lineY);
    }
  }
}

int getWrapBoxHeight(int nRows) {
  // wrap box vazia - altura de um botao
  if (nRows == 0) nRows = 1;
  int heightButtons = nRows * TOGGLE_HEIGHT + (nRows - 1) * SPACING_V;

  return 2 * PADDING_V + heightButtons;
}


// ----------------------- COLOR WHEEL ----------------------- //

boolean isInsideColorWheel() {
  // Calculate the center of the color wheel
  int centerX = cwX + COLOR_WHEEL_OUT_SIZE / 2;
  int centerY = cwY + COLOR_WHEEL_OUT_SIZE / 2;

  // Calculate the distance between the mouse position and the center of the color wheel
  float distance = dist(mouseX, mouseY, centerX, centerY);

  // Check if the distance is within the range of the inner and outer diameters of the color wheel
  if (distance >= (COLOR_WHEEL_INNER_SIZE / 2) && distance <= (COLOR_WHEEL_OUT_SIZE / 2)) {
    return true;
  } else {
    return false;
  }
}


// ----------------------- MOUSE ----------------------- //

void mousePressed() {
  if (isInsideColorWheel()) {
    pickedColor();
  }
}


// ----------------------- PICK COLOR ----------------------- //

void pickedColor() {
  pickedColor = get(mouseX, mouseY);
  if (mode == 0)
    arduino.write("picked_color:"+red(pickedColor)+","+green(pickedColor)+","+blue(pickedColor)+"\n");
}


// ----------------------- ARDUINO COMMUNICATION ----------------------- //

/*
void sendModeOff() {
  arduino.write("mode_off\n");
}
*/

void sendMode() {
  switch (mode) {
    case 2:
      sendMovMatrix();
      //delay(200);
      break;
    default:
      arduino.write(modes[mode]+"\n");
      break;
  }
}

void sendPower() {
  if (power) {
    arduino.write("power_on\n");
  }
  else {
    arduino.write("power_off\n");
  }
}

void sendBrightness(String up_down) {
  arduino.write("brightness_"+up_down+"\n");
}


void sendMovMatrix() {
  if (webcam.available()) {
    webcam.read();
    frame = webcam.copy();
    frame.loadPixels();
  
    calculateMatrixColors();
    updateLedMatrixString();
    
    int chunkSize = 64; // Adjust based on Arduino's buffer size
    int dataLength = stringLedMatrix.length();
    
    for (int i = 0; i < dataLength; i += chunkSize) {
      int end = min(i + chunkSize, dataLength);
      String chunk = stringLedMatrix.substring(i, end);
      arduino.write(chunk + '\n'); // Send chunk with newline
      delay(50); // Adjust delay as needed
    }
    
    arduino.write('\r'); // Send carriage return to indicate end of transmission
    lastFrameMillis = millis();
    println(stringLedMatrix);
    
    delay(500); // Adjust delay to control the sending rate
  }
}





// ----------------------- WEBCAM ----------------------- //

void updateLedMatrixString() {
  stringLedMatrix = "mode_moveReact:";
  for (int i = 0; i < MATRIX_WIDTH; i++) {
    for (int j = 0; j < MATRIX_HEIGHT; j++) {
      stringLedMatrix += "0x" + ledMatrix[i][j] + ";";
    }
  }
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
        ledMatrix[invert_x][j] = "000000"; // Black in hex
      } else {
        ledMatrix[invert_x][j] = hex(closestColor, 6); // Closest color in hex
        println(closestColor);
      }
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
