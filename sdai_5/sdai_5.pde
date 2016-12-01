//TODO:
// - PART 1: 
//  - add triggering of glitch mode after 25% of orig movie; start at 0 opacity and ramp up to 100. 
//    - (Maybe add variable framerate for glitch too, ramping it up.)
//  - add triggering of color in orig movie at 75% of orig movie; start at 0 color and ramp up to 100.
// - add more glitch modes from Kim's original sketch (black, white, brightness modes).

import processing.video.*;

int appFrameRate = 200;
int origMovieFrameRate = 10;
Movie origMovie;                                      // The original movie, without glitching/effects.
boolean showOrigMovie = true;
boolean isFirstLoop = true;
PImage glitchImage;
int mode = 0;
int loops = 20;
int blackValue = -16000000;
int row = 0;
int lastOrigMovieTime = 0;

void setup() {
  
  frameRate(appFrameRate);                                //[OPTION]
  size(1, 1);
  noStroke();
  background(0);
  origMovie = new Movie(this, "yosemite-10sec.mp4");
  //origMovie.loop();                                      //DEV
  origMovie.play();                                      //DEV
  origMovie.volume(0);
  surface.setResizable(true);
  
}

void draw() {
  
  surface.setTitle(int(frameRate) + " fps");
  background(0);
  
  // Image(s) captured from movie not ready yet; return.
  if (isFirstLoop) {
    return;
  }
    
  //////////////////////////////////////////////////////////////
  //////////////////// PART 1 : The Airship ////////////////////
  //////////////////////////////////////////////////////////////
  
  // The original movie's image.
  if (showOrigMovie) {
    if ((millis()-lastOrigMovieTime) >= (1000/origMovieFrameRate)) {
      tint(255, 255, 255 , 255);                                        // ie. tint(R,G,B,A) : [0-255]
      image(origMovie, 0, 0);
      lastOrigMovieTime = millis();
    }
  }
  
  // The glitched movie image. Show it based on progress of the original movie.
  float origMovieProgressNorm = origMovie.time()/origMovie.duration();
  float startGlitchThresholdNorm = 0.5;
  if (origMovieProgressNorm >= startGlitchThresholdNorm) {
    float glitchAlpha = map(origMovieProgressNorm, startGlitchThresholdNorm, 1.0, 0, 255);
    println("Running glitch | Alpha: "+ glitchAlpha);
    tint(255, 255, 255 , glitchAlpha);
    image(glitchImage, 0, 0);
  }
  
  // Ramp from global grayscale to color: starts @ startGlitchThresholdNorm - stop @ end of movie.
  float colorThreshold = map(origMovieProgressNorm, startGlitchThresholdNorm, 1.0, 0.0, 1.0);
  if (random(1) > colorThreshold) {
    filter(GRAY);
  }
  
}

// Called every time a new movie frame is available to read.
void movieEvent(Movie m) {
  
  m.read();
  
  if (isFirstLoop) {
    surface.setSize(origMovie.width, origMovie.height);
    glitchImage = origMovie.get();
    isFirstLoop = false;
  }
  
  arrayCopy(m.pixels, glitchImage.pixels);
  
  modifyGlitch();
  
}

void modifyGlitch() {
  
  // Reset row counter if necessary.
  if (row >= glitchImage.height-1) {
   row = 0;
  }
  
  // Loop through rows, glitching each.
  while(row < glitchImage.height-1) {
    //println("Sorting Row " + column);
    glitchImage.loadPixels(); 
    sortRow();
    row++;
    glitchImage.updatePixels();
  }
  
}

// Glitch function credited to: Kim Asendorf, kimasendorf.com, ASDF Pixel Sort.
void sortRow() {
  // current row
  int y = row;
  
  // where to start sorting
  int x = 0;
  
  // where to stop sorting
  int xend = 0;
  
  while(xend < glitchImage.width-1) {
    switch(mode) {
      case 0:
        x = getFirstNotBlackX(x, y);
        xend = getNextBlackX(x, y);
        break;
      case 1:
        //x = getFirstBrightX(x, y);
        //xend = getNextDarkX(x, y);
        break;
      case 2:
        //x = getFirstNotWhiteX(x, y);
        //xend = getNextWhiteX(x, y);
        break;
      default:
        break;
    }
    
    if(x < 0) break;
    
    int sortLength = xend-x;
    
    color[] unsorted = new color[sortLength];
    color[] sorted = new color[sortLength];
    
    for(int i=0; i<sortLength; i++) {
      unsorted[i] = glitchImage.pixels[x + i + y * glitchImage.width];
    }
    
    sorted = sort(unsorted);
    
    for(int i=0; i<sortLength; i++) {
      glitchImage.pixels[x + i + y * glitchImage.width] = sorted[i];      
    }
    
    x = xend+1;
  }
}

// black x
int getFirstNotBlackX(int x, int y) {
  
  while(glitchImage.pixels[x + y * glitchImage.width] < blackValue) {
    x++;
    if(x >= glitchImage.width) 
      return -1;
  }
  
  return x;
}

int getNextBlackX(int x, int y) {
  x++;
  
  while(glitchImage.pixels[x + y * glitchImage.width] > blackValue) {
    x++;
    if(x >= glitchImage.width) 
      return glitchImage.width-1;
  }
  
  return x-1;
}