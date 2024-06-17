import controlP5.*;

final color BACKGROUND_COLOR = #282828;
final color WRAP_BOX_COLOR = #3C3C3C;

final int WRAP_BOX_WIDTH = 920;
final int WRAP_BOX_HEIGHT = 430;
final int WRAP_BOX_X = 80 + WRAP_BOX_WIDTH / 2;
final int WRAP_BOX_Y = 70 + WRAP_BOX_HEIGHT / 2;

final int COLOR_SELECTOR_WIDTH = 160;
final int COLOR_SELECTOR_HEIGHT = 170;
final int COLOR_WIDTH = 150;
final int COLOR_HEIGHT = 160;
final int COLOR_MARGIN = 5;


final int HORIZONTAL_SPACE = 20;
final int APP_VERTICAL_SPACE = 50;
final int CP_VERTICAL_SPACE = 30;

final int SQUARE_BUTTON_SIZE = 70;
final int ON_OFF_BUTTON_WIDTH = 340;


ControlP5 ui_comps;
ControlP5 cl_palette;
Toggle[] colorPaletteToggles;
Label[] mainMenuLables;
Toggle onOffToggle, playPauseToggle;
Button brightDownButton, brightUpButton, replayButton;
PImage[] images = new PImage[12];


// --------------------------------------------------------------------------------------------------------------- INIT UI
void initUI() {
  images[0] = loadImage("color_default.png");
  images[1] = loadImage("color_selected.png");
  images[2] = loadImage("brightDown_default.png");
  images[3] = loadImage("brightDown_pressed.png");
  images[4] = loadImage("brightUp_default.png");
  images[5] = loadImage("brightUp_pressed.png");    
  images[6] = loadImage("OnOff_Off.png");
  images[7] = loadImage("OnOff_On.png");
  images[8] = loadImage("play_off.png");
  images[9] = loadImage("play_on.png");
  images[10] = loadImage("replay_default.png");
  images[11] = loadImage("replay_pressed.png");
  
  
  ui_comps = new ControlP5(this);
  cl_palette = new ControlP5(this);
  colorPaletteToggles = new Toggle[COLOR_PALETTE_SIZE];
  
  
  // -------------------------------------------------------------------------- COLOR PALETTE TOGGLES
  int index = 0;
  for (int row = 1; row <= 2; row++) {
    for (int col = 1; col <= COLOR_PALETTE_SIZE / 2; col++) {
      int x = 80 + (col * HORIZONTAL_SPACE) + ((col - 1) * COLOR_SELECTOR_WIDTH);
      int y = 70 + (row * CP_VERTICAL_SPACE) + ((row - 1) * COLOR_SELECTOR_HEIGHT);
      colorPaletteToggles[index] = cl_palette.addToggle("colorToggle" + index)
        .setPosition(x, y)
        .setSize(COLOR_SELECTOR_WIDTH, COLOR_SELECTOR_HEIGHT)
        .setImages(images[0], images[1])
        .setId(index)
        .setState(false);
        
      index++;
    }
  }
  
  // callbacks
  for(Toggle colorToggle : colorPaletteToggles) {
    
    colorToggle.addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_PRESS) {
          updateSelectedColors(colorToggle.getId(), colorToggle.getState());
        }
      }
    });
      
  }
  
  cl_palette.setAutoDraw(false); 
  
  // -------------------------------------------------------------------------- BRIGHT DOWN
  int x = 370;
  int y = 550;
  brightDownButton = ui_comps.addButton("brightDownButton")
    .setPosition(x, y)
    .setSize(SQUARE_BUTTON_SIZE, SQUARE_BUTTON_SIZE)
    .setImages(images[2], images[2], images[3]);
    
  // callback
  brightDownButton.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (theEvent.getAction() == ControlP5.ACTION_PRESS) {
        sendBrightness("Down");
      }  
    }
  });
    
  // -------------------------------------------------------------------------- REPLAY
  x += SQUARE_BUTTON_SIZE + HORIZONTAL_SPACE;
  replayButton = ui_comps.addButton("replayButton")
    .setPosition(x, y)
    .setSize(SQUARE_BUTTON_SIZE, SQUARE_BUTTON_SIZE)
    .setImages(images[10], images[10], images[11]);
    
  // callback
  replayButton.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (theEvent.getAction() == ControlP5.ACTION_PRESS) {
        sendReplay();
        title.jump(0.0);
      };
    }
  });
    
    
  // -------------------------------------------------------------------------- PLAY/PAUSE
  x += SQUARE_BUTTON_SIZE + HORIZONTAL_SPACE;
  playPauseToggle = ui_comps.addToggle("playPauseToggle")
    .setPosition(x, y)
    .setSize(SQUARE_BUTTON_SIZE, SQUARE_BUTTON_SIZE)
    .setImages(images[8], images[8], images[9])
    .setState(false);
    
  // callback
  playPauseToggle.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (theEvent.getAction() == ControlP5.ACTION_PRESS) {
        play = playPauseToggle.getState();
        println("play: "+play);
        sendPlayPause();
        if (play)
          title.play();
        else 
          title.pause();
      }
    }    
  });
    
    
  // -------------------------------------------------------------------------- BRIGHT UP
  x += SQUARE_BUTTON_SIZE + HORIZONTAL_SPACE;
  brightUpButton = ui_comps.addButton("brightUpButton")
    .setPosition(x, y)
    .setSize(SQUARE_BUTTON_SIZE, SQUARE_BUTTON_SIZE)
    .setImages(images[4], images[4], images[5]);
    
  // callback
  brightUpButton.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (theEvent.getAction() == ControlP5.ACTION_PRESS) {
        sendBrightness("Up");
      };
    }
  });
  
    
  // -------------------------------------------------------------------------- ON/OFF
  x = 370;
  y += SQUARE_BUTTON_SIZE + APP_VERTICAL_SPACE;
  onOffToggle = ui_comps.addToggle("onOffToggle")
    .setPosition(x, y)
    .setSize(ON_OFF_BUTTON_WIDTH, SQUARE_BUTTON_SIZE)
    .setImages(images[6], images[6], images[7])
    .setState(false);
    
  // callback
  onOffToggle.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (theEvent.getAction() == ControlP5.ACTION_PRESS) {
        ledsOn = onOffToggle.getState();
        println("ledsOn: "+ledsOn);
        
        sendLedsOnOff();
      }
    }    
  });
  
}

 
// --------------------------------------------------------------------------------------------------------------- SEND COLOR SELECT
void updateSelectedColors(int toggle, boolean selected) {
  arduino.write("sc:" + toggle + ":" + int(selected) + "\n");
  
  delay(10);
}

void sendColorPaletteColor(int cpColor) {
  arduino.write("cp:" + cpColor + ":0x" + hex(colorPalette[cpColor]) + "\n");
  delay(10);
}

// --------------------------------------------------------------------------------------------------------------- SEND BRIGHTNESS
void sendBrightness(String up_down) {
  arduino.write("bright" + up_down + "\n");
  delay(10);
}


// --------------------------------------------------------------------------------------------------------------- SEND ON / OFF
void sendLedsOnOff() {
  if (ledsOn)
    arduino.write("ledsOn");
  else
    arduino.write("ledsOff");
  
  delay(10);
}


// --------------------------------------------------------------------------------------------------------------- SEND REPLAY
void sendReplay() {
  arduino.write("replay");
  delay(10);
}


// --------------------------------------------------------------------------------------------------------------- SEND PLAY / PAUSE
void sendPlayPause() {
  if (play)
    arduino.write("play");
  else
    arduino.write("pause");
    
  delay(10);
}


// --------------------------------------------------------------------------------------------------------------- DRAW UI
void drawUI() {
  // COLOR PALETTE WRAP BOX
  fill(WRAP_BOX_COLOR);
  rect(WRAP_BOX_X, WRAP_BOX_Y, WRAP_BOX_WIDTH, WRAP_BOX_HEIGHT, 18.5);
  
  cl_palette.draw();
  
  //final int COLOR_WIDTH = 150;
  //final int COLOR_HEIGHT = 160;
  //final int HORIZONTAL_SPACE = 20;
  //final int CP_VERTICAL_SPACE = 30;
    // COLOR PALETTE COLORS
  int index = 0;
  for (int row = 1; row <= 2; row++) {
    for (int col = 1; col <= COLOR_PALETTE_SIZE / 2; col++) {
      int x = 80 + (col * HORIZONTAL_SPACE) + ((col - 1) * COLOR_SELECTOR_WIDTH) + COLOR_MARGIN + COLOR_WIDTH / 2;
      int y = 70 + (row * CP_VERTICAL_SPACE) + ((row - 1) * COLOR_SELECTOR_HEIGHT) + COLOR_MARGIN + COLOR_HEIGHT / 2;
      fill(colorPalette[index]);
      rect(x, y, COLOR_WIDTH, COLOR_HEIGHT, 18.5);
      index++;
    }
  }
  
} 
 
