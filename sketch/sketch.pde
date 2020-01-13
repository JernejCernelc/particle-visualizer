import processing.video.*;
import java.util.concurrent.*;

//parameters
boolean clear = true;         //true, false
boolean inverse = false;      //true, false
int numberOfParticles = 20000;  //20000 , 200
boolean debug = true;

Capture video;
float threshhold = 0.5;
int captureSizeX = 320;
int captureSizeY = 240;
int pixelStep = 1;
float scaleFactor;
float pixelSize;

PixelGrid pixelGrid;

void setup() {
  size(1280, 960);
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
  }    
  
  float scaleFactorX = width/captureSizeX;
  float scaleFactorY = height/captureSizeY;
  scaleFactor = Math.min(scaleFactorX, scaleFactorY);

  pixelSize = pixelStep*scaleFactor;
  ellipseMode(CORNER);
  background(0);
  video = new Capture(this, captureSizeX, captureSizeY);
  video.start();
  video.loadPixels();
  
  pixelGrid = new PixelGrid(captureSizeX/pixelStep, captureSizeY/pixelStep, numberOfParticles);
  
  //Reading input every 100 seconds
  ScheduledExecutorService executor = Executors.newSingleThreadScheduledExecutor();
  Runnable readVideo = new Runnable() {
    public void run() {
      if (!video.available())  return;
      video.read();
      video.filter(THRESHOLD, threshhold);
      
      for (int x = 0, xGrid = 0; x < captureSizeX; x+=pixelStep, xGrid++) {
        for (int y = 0, yGrid = 0; y < captureSizeY; y+=pixelStep, yGrid++) {
          int loc = x + y * captureSizeX;
          if(video.pixels[loc] == color(0)) {
            if(inverse) {
              pixelGrid.updatePlayerPixelType(xGrid, yGrid, true);
            } else {
              pixelGrid.updatePlayerPixelType(xGrid, yGrid, false);
            }
          } else {
            if(inverse) {
              pixelGrid.updatePlayerPixelType(xGrid, yGrid, false);
            } else {
              pixelGrid.updatePlayerPixelType(xGrid, yGrid, true);
            }
          }
          //pixelGrid.resetParticlesPixelType(xGrid, yGrid);
        }
      }
    }
  };
  executor.scheduleAtFixedRate(readVideo, 0, 50, TimeUnit.MILLISECONDS);
}

void draw() {
    pixelGrid.calculateParticles();

    if(clear) {
        clear();
    }
    //background(255);
    noStroke();
    
    //DEBUG draw grid
    for (int x = 0; x < pixelGrid.w; x++) {
      for (int y = 0; y < pixelGrid.h; y++) {
        if(pixelGrid.getPixelType(x, y).isPlayer()) {
            //fill(255);
            //float pixelSizeTmp = random(pixelSize-(pixelSize*0.05),pixelSize);
            //rect((width-pixelSize) - x*scaleFactor*pixelStep, y*scaleFactor*pixelStep, pixelSize, pixelSize);            
        } else if(pixelGrid.getPixelType(x, y).isBorder()) {
            //fill(255, 0, 0);
            //rect((width-pixelSize) - x*scaleFactor*pixelStep, y*scaleFactor*pixelStep, pixelSize, pixelSize);            
        }
      }
    }
    
    
    for(Particle particle : pixelGrid.particles) {
      fill(color(particle.mapSpeedToColor(),30,30));
      float newPixelSize = particle.mapSpeedToSize(pixelSize);
      ellipse((width-pixelSize) - particle.x*scaleFactor*pixelStep, particle.y*scaleFactor*pixelStep, newPixelSize, newPixelSize);
    }
    
    if(debug) {
      image(video, 0 ,0);
    }
}

void mouseClicked() {
  saveFrame(); 
}
