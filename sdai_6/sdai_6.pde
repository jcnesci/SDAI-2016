//TODO:
// - add more glitch modes from Kim's original sketch (black, white, brightness modes)
// - randomize either R,G,or B in tint()
// - clean unused vars
// - record movies:
//  - vashti movie
//  - kuno movie
//  - vashti, then kuno movie

import processing.video.*;

String mainCharacter = "kuno";                               // is 'vashti' or 'kuno'. 
int appFrameRate = 200;
float origMovieFrameRate = 60;
Movie origMovie;                                      // The original movie, without glitching/effects.
boolean showOrigMovie = true;
boolean isFirstLoop = true;
PImage glitchImage;
int glitchMode = 0;
int loops = 20;
int blackValue = -16000000;
int row = 0;
int column = 0;
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
  
  if (mainCharacter == "vashti") {
    origMovieFrameRate = 200;
    //origMovie = new Movie(this, "yosemite.mp4");
    origMovie = new Movie(this, "yosemite-10sec.mp4");
    for (int i = 0; i < errorImages.length; i++) {
      errorImages[i] = loadImage("error-mac-"+ (i + 1) +".png" );
    }
  } else if (mainCharacter == "kuno") {
    origMovieFrameRate = 30;
    //origMovie = new Movie(this, "linux.mp4");
    origMovie = new Movie(this, "linux-10sec.mp4");
    for (int i = 0; i < errorImages.length; i++) {
      errorImages[i] = loadImage("error-linux-"+ (i + 1) +".png" );
    }
    blendMode(SCREEN);
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
  
  if (mainCharacter == "vashti") {
      
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
        int index = int(random(errorImages.length));
        image(errorImages[index], random(width), random(height));
      }
      if (showLongError && millis() < longErrorEndTime) {
        image(errorImages[longErrorImageIndex], longErrorX, longErrorY);
      } else {
        showLongError = false;
        if (random(1) >= 0.4) {
          showLongError = true;
          longErrorEndTime = millis() + (random(10000) + 2000);
          longErrorImageIndex = int(random(errorImages.length));
          longErrorX = random(width);
          longErrorY = random(height);
        }
      }
    }
    
  }// END - vashti
  
  if (mainCharacter == "kuno") {
      
    // Draw original movie's image.
    // Change origMovie framerate.
    showOrigMovie = false;
    if (origMovieProgressNorm >= 0.35 && origMovieProgressNorm < 0.65) {
     showOrigMovie = true;
     if (origMovieProgressNorm < 0.5) {
       origMovieFrameRate = map(origMovieProgressNorm, 0.4, 0.5, 30, 200);
     } else {
       origMovieFrameRate = map(origMovieProgressNorm, 0.5, 0.6, 200, 30);
     }
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
    if (origMovieProgressNorm < 0.45) {
      glitchAlpha = map(origMovieProgressNorm, 0.0, 0.45, 255, 100);
    } else if (origMovieProgressNorm >= 0.55) {
      glitchAlpha = map(origMovieProgressNorm, 0.55, 1.0, 100, 255);
    }
    tint(255, 255, 255 , glitchAlpha);
    image(glitchImage, 0, 0);
    
    // Change coloring VS grayness of global result.
    if (origMovieProgressNorm < 0.5) {
      colorThreshold = map(origMovieProgressNorm, 0.0, 0.5, 1.0, 0.0);
    } else {
      colorThreshold = map(origMovieProgressNorm, 0.5, 1.0, 0.0, 1.0);
    }
    if (random(1) > colorThreshold) {
      filter(GRAY);
    }
    
    // Error dialog boxes.
    if ((origMovieProgressNorm >= 0.0 && origMovieProgressNorm < 0.2) || (origMovieProgressNorm >= 0.8 && origMovieProgressNorm < 1.0)) {
     if (random(1) >= 0.8) {
       int index = int(random(errorImages.length));
       image(errorImages[index], random(width), random(height));
     }
     if (showLongError && millis() < longErrorEndTime) {
       image(errorImages[longErrorImageIndex], longErrorX, longErrorY);
     } else {
       showLongError = false;
       if (random(1) >= 0.4) {
         showLongError = true;
         longErrorEndTime = millis() + (random(10000) + 2000);
         longErrorImageIndex = int(random(errorImages.length));
         longErrorX = random(width);
         longErrorY = random(height);
       }
     }
    }
    
  }// END - kuno
  
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
  
  // Reset column & row counter if necessary.
  if (row >= glitchImage.height-1) {
   row = 0;
  }
  if (column >= glitchImage.width-1) {
   column = 0;
  }
  
  // Loop through rows, glitching each.
  while(column < glitchImage.width-1) {
    //println("Sorting Column " + column);
    glitchImage.loadPixels(); 
    sortColumn();
    column++;
    glitchImage.updatePixels();
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

void sortColumn() {
  // current column
  int x = column;
  
  // where to start sorting
  int y = 0;
  
  // where to stop sorting
  int yend = 0;
  
  while(yend < glitchImage.height-1) {
    switch(glitchMode) {
      case 0:
        y = getFirstNotBlackY(x, y);
        yend = getNextBlackY(x, y);
        break;
      case 1:
        //y = getFirstBrightY(x, y);
        //yend = getNextDarkY(x, y);
        break;
      case 2:
        //y = getFirstNotWhiteY(x, y);
        //yend = getNextWhiteY(x, y);
        break;
      default:
        break;
    }
    
    if(y < 0) break;
    
    int sortLength = yend-y;
    
    color[] unsorted = new color[sortLength];
    color[] sorted = new color[sortLength];
    
    for(int i=0; i<sortLength; i++) {
      unsorted[i] = glitchImage.pixels[x + (y+i) * glitchImage.width];
    }
    
    sorted = sort(unsorted);
    
    for(int i=0; i<sortLength; i++) {
      glitchImage.pixels[x + (y+i) * glitchImage.width] = sorted[i];
    }
    
    y = yend+1;
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

// black y
int getFirstNotBlackY(int x, int y) {

  if(y < glitchImage.height) {
    while(glitchImage.pixels[x + y * glitchImage.width] < blackValue) {
      y++;
      if(y >= glitchImage.height)
        return -1;
    }
  }
  
  return y;
}

int getNextBlackY(int x, int y) {
  y++;

  if(y < glitchImage.height) {
    while(glitchImage.pixels[x + y * glitchImage.width] > blackValue) {
      y++;
      if(y >= glitchImage.height)
        return glitchImage.height-1;
    }
  }
  
  return y-1;
}