import processing.video.*;

PImage i1;
PImage i2;

void setup() {
  
  size(1280, 720);
  noStroke();
  background(0);
  i1 = loadImage("bouv-jo.jpg");
  i2 = loadImage("convergence.jpg");
  
}

void draw() {
  background(0);
  image(i1, 0, 0);
  image(i2, 50, 50);
}