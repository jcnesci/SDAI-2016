//TODO:
// - PART 1: 
//  - add triggering of glitch mode after 25% of orig movie; start at 0 opacity and ramp up to 100. 
//    - (Maybe add variable framerate for glitch too, ramping it up.)
//  - add triggering of color in orig movie at 75% of orig movie; start at 0 color and ramp up to 100.
// - add more glitch modes from Kim's original sketch (black, white, brightness modes).
// - randomize either R,G,or B in tint()

import processing.video.*;

String mode = "vashti";                               // is 'vashti' or 'kuno'. 
int appFrameRate = 200;
float startingOrigMovieFrameRate = 200; 
float origMovieFrameRate = startingOrigMovieFrameRate;
Movie origMovie;                                      // The original movie, without glitching/effects.
boolean showOrigMovie = true;
boolean isFirstLoop = true;
PImage glitchImage;
PImage errorImg;
int glitchMode = 0;
int loops = 20;
int blackValue = -16000000;
int row = 0;
int lastOrigMovieTime = 0;
float colorThreshold = 0;
float glitchAlpha = 0;
PImage[] errorImages = new PImage[6];
int longErrorImageIndex = 0;
boolean showLongError = false;
float longErrorEndTime = 0;
float longErrorX = 0;
float longErrorY = 0;

void setup() {
  
  frameRate(appFrameRate);                                //[OPTION]
  size(1, 1);
  noStroke();
  background(0);
  surface.setResizable(true);
  
  if (mode == "vashti") {
    //origMovie = new Movie(this, "yosemite.mp4");
    origMovie = new Movie(this, "yosemite-10sec.mp4");
    //errorImg = loadImage("error-mac-red-1.png");
    for (int i = 0; i < errorImages.length; i++) {
      errorImages[i] = loadImage("error-mac-"+ (i + 1) +".png" );
    }
  } else if (mode == "kuno") {
    origMovie = new Movie(this, "linux.mp4");
    errorImg = loadImage("error-mac-red-1.png");
  }
  
  origMovie.loop();                                      //DEV
  //origMovie.play();                                      //DEV
  origMovie.volume(0);
  
}

void draw() {
  
  surface.setTitle(int(frameRate) + " fps");
  background(0);
  
  // Image(s) captured from movie not ready yet; return.
  if (isFirstLoop) {
    return;
  }
  
  float origMovieProgressNorm = origMovie.time()/origMovie.duration();
  float startGlitchThresholdNorm = 0.5;
  
  // Draw original movie's image.
  // Change origMovie framerate.
  if (origMovieProgressNorm < 0.4) {
    origMovieFrameRate = map(origMovieProgressNorm, 0.0, 0.4, 200, 30);
  } else if (origMovieProgressNorm >= 0.4 && origMovieProgressNorm < 0.6) { 
    showOrigMovie = false;
  } else if (origMovieProgressNorm >= 0.6) {
    showOrigMovie = true;
    origMovieFrameRate = map(origMovieProgressNorm, 0.6, 1.0, 30, 200);
  }
  if (showOrigMovie) {
    // Draw frame at specified framerate by origMovieFrameRate.
    if ((millis()-lastOrigMovieTime) >= (1000/origMovieFrameRate)) {
      tint(255, 255, 255 , 255);                                        // ie. tint(R,G,B,A) : [0-255]
      image(origMovie, 0, 0);
      lastOrigMovieTime = millis();
    }
  }
  
  // The glitched movie image. Show it based on progress of the original movie.
  if (origMovieProgressNorm >= 0.2 && origMovieProgressNorm < 0.8) {
   if (origMovieProgressNorm < 0.4) {
     glitchAlpha = map(origMovieProgressNorm, 0.2, 0.4, 0, 255);
   } else if (origMovieProgressNorm >= 0.6) {
     glitchAlpha = map(origMovieProgressNorm, 0.6, 1.0, 255, 0);
   }
   tint(255, 255, 255 , glitchAlpha);
   image(glitchImage, 0, 0);
  }
  
  // Change coloring VS grayness of global result.
  if (origMovieProgressNorm < 0.5) {
    colorThreshold = map(origMovieProgressNorm, 0.0, 0.5, 0.0, 1.0);
  } else {
    colorThreshold = map(origMovieProgressNorm, 0.5, 1.0, 1.0, 0.0);
  }
  if (random(1) > colorThreshold) {
    filter(GRAY);
  }
  
  // Error dialog boxes.
  if ((origMovieProgressNorm >= 0.2 && origMovieProgressNorm < 0.4) || (origMovieProgressNorm >= 0.6 && origMovieProgressNorm < 0.8)) {
    if (random(1) >= 0.8) {
      //image(errorImg, random(width), random(height));
      int index = int(random(errorImages.length));
      image(errorImages[index], random(width), random(height));
    }
    if (showLongError && millis() < longErrorEndTime) {
      image(errorImages[longErrorImageIndex], longErrorX, longErrorY);
    } else {
      showLongError = false;
      if (random(1) >= 0.4) {
        showLongError = true;
        longErrorEndTime = millis() + 2000;
        longErrorImageIndex = int(random(errorImages.length));
        longErrorX = random(width);
        longErrorY = random(height);
      }
    }
  }
  
  // DEV PRINTS
  //println("origMovieFrameRate: "+ origMovieFrameRate +" | colorThreshold: "+ colorThreshold);
  //println("- glitch alpha: "+ glitchAlpha);
  
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
    switch(glitchMode) {
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