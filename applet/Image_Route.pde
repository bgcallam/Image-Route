import imageadjuster.*;
import processing.pdf.*;
import processing.dxf.*;


/**
 * Based on Explode by Daniel Shiffman. 
 * Requires the imageadjuster library which can be found on process.org
 * Modifications by Benjamin Callam June 2008:
   > NOTE: Images should reside in a directory called "data" in the same directory as the application
   > Also, unfortunately, the ouput is always triangulated, so it will require some cleanup. One way is to use the background
     rather than the squares for machining.
 */

PImage originalImg,img;       // The source image
ImageAdjuster adjust;
int cellsize = 10; // Maximum dimension of hole
int cols, rows;   // Number of columns and rows in our system
float minBrighgtness = .5;   // Smallest size to draw a box
boolean record;

void setup()
{
  adjust = new ImageAdjuster(this);
  adjustImage();

  originalImg = loadImage("trees.jpg");     // Load the image
  float aspRatio;
  if(originalImg.height>originalImg.width){
    aspRatio = originalImg.height/originalImg.width;
  } 
  else {     
    aspRatio = originalImg.width/originalImg.height;
  }
  
  println(aspRatio);
  img = new PImage(int(800*aspRatio),int(800*aspRatio));
  img.copy(originalImg, 0, 0, originalImg.width, originalImg.height, 0, 0, img.width, img.height);
  size(img.width, img.height, P3D); 
  cols = width/cellsize;            // Calculate # of columns
  rows = height/cellsize;           // Calculate # of rows
  colorMode(RGB,255,255,255,100);   // Setting the colormode
  noLoop();
}

void draw()
{
  beginRaw(PDF, "output.pdf");
  // beginRaw(DXF, "output.dxf");  // DXF output is also possible, uncomment this line and comment out the previous line
  background(0);

  // Begin loop for columns
  for ( int i = 0; i < cols;i++) {
    // Begin loop for rows
    for ( int j = 0; j < rows;j++) {

      // Where are we, pixel-wise?
      int x = i*cellsize;
      int y = j*cellsize;
      //int loc = (originalImg.width - x - 1) + y*originalImg.width; // Reversing x to mirror the image
      int loc = x + (y*img.width);           // Pixel array location

      // draw circles based on brightness
      color c = img.pixels[loc];
      float sz = ((brightness(c)/255.0f)*cellsize+3)-cellsize;
      //ellipseMode(CENTER);
      fill(255);
      noStroke();

      // Don't draw really really tiny rectangles
      if(abs(sz) > minBrighgtness){
        rect(x+cellsize/2,y+cellsize/2,sz,sz);
      }
    }
  }

  // Close the file
  endRaw();

}

void adjustImage(){
  // define the threshold
  int threshold = 96;

  // create a custom lookup table
  float [] mylut = new float[256];

  // populate the lookup table with thresholded values
  for (int i=0; i<256; i++)
    mylut[i] = (i < threshold) ? 0f : 255f;

  // tell the adjuster to use custom lookup table
  adjust.setLUT(mylut);

  // perform the adjustment
  adjust.apply(g);
}


