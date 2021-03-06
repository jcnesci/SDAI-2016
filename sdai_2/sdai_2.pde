import processing.video.*;
Movie myMovie;
boolean isFirstLoop = true;
PImage glitchImage;
int mode = 0;
int loops = 20;
int blackValue = -16000000;
int row = 0;

void setup() {
  
  size(1, 1);
  myMovie = new Movie(this, "dudley.MOV");
  //myMovie = new Movie(this, "optical-waves.mp4");
  myMovie.loop();
  surface.setResizable(true);
  
}

void draw() {
  
  if (!isFirstLoop) {
    image(glitchImage, 0, 0);
    filter(GRAY);
    myMovie.volume(0);
  }
  
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  
  m.read();
  
  if (isFirstLoop) {
    isFirstLoop = false;
    surface.setSize(myMovie.width, myMovie.height);
    glitchImage = myMovie.get();
  }
  
  arrayCopy(m.pixels, glitchImage.pixels);
  
  modifyGlitch();
  
}

void modifyGlitch() {
  
  // ----------------------------------
  // V1
  // ----------------------------------
  //glitchImage.loadPixels();
  //for (int x = 0; x < glitchImage.width; x++) {
  //  for (int y = 0; y < glitchImage.height; y++) {
  //    glitchImage.pixels[y + x * glitchImage.height] = color(random(255), random(255), random(255), 255);
  //  }
  //}
  //glitchImage.updatePixels();
  
  // ----------------------------------
  // V2
  // ----------------------------------
  if (row >= glitchImage.height-1) {
   row = 0;
  }
  // loop through rows
  while(row < glitchImage.height-1) {
    //println("Sorting Row " + column);
    glitchImage.loadPixels(); 
    sortRow();
    row++;
    glitchImage.updatePixels();
  }
  
}

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