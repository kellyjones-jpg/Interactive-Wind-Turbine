// Import the Minim library
import ddf.minim.*;

// Wind turbine variables
float windIntensity = 0;  // 0.0 (no wind) to 1.0 (maximum wind)
float maxWindPowerOutput = 150;  // Max power output for the wind turbine
float currentWindPowerOutput = 0;
float bladeAngle = 0;  // Angle for rotating blades
float bladeSpeed = 0.1;  // Speed of rotation based on wind intensity
float previousMouseX = 0;  // Track previous mouse X position
boolean drawLines = false;  // Track if lines should be drawn

// Array to store turbine blade speeds for different wind intensities
float[] bladeSpeeds = new float[10];  // Store 10 different speeds
int speedIndex = 0; // Index to track current speed

// Number of clouds to draw
int numClouds = 3;
float[] cloudX = new float[numClouds]; // Array to store cloud x-positions
float[] cloudY = new float[numClouds]; // Array to store cloud y-positions

// Wind variables
float circleX = 20;
float circleY = 50;

// Minim object for sound
Minim minim;
AudioPlayer windSound;
AudioPlayer backgroundSound; // New variable for background sound

float[] cloudXOffsets = new float[numClouds]; // Offset for Perlin noise in x direction
float[] cloudYOffsets = new float[numClouds]; // Offset for Perlin noise in y direction
PImage bgImage;  // Declare a PImage variable for the background
PImage cloudImage; // Declare a PImage variable for the cloud image
PImage textBackgroundImage; // Declare PImage variable for the text background
PFont boldFont;

void setup() {
  // Background size
  size(1020, 680);
  
  // Load a bold font
  boldFont = createFont("Arial-Bold-48", 48);
  textFont(boldFont);
  
  // Load the cloud image as background for the text
  textBackgroundImage = loadImage("/cloud-background.png");

  // Load the background image
  bgImage = loadImage("/89871-flipped.jpg");
  
  // Load the cloud PNG image
  cloudImage = loadImage("/cloud.png");

  // Initialize Minim and load the wind turbine sound
  minim = new Minim(this);
  windSound = minim.loadFile("/wind-turbine.mp3"); // Load the wind turbine sound
  backgroundSound = minim.loadFile("/rural-farmland-ambience.wav"); // Load the background sound

  // Start playing the background sound in a loop
  backgroundSound.loop(); // Start or loop the background sound
  
 // Initialize cloud positions and noise offsets
  for (int i = 0; i < numClouds; i++) {
    cloudX[i] = random(width);
    cloudY[i] = random(-150, 350);
    cloudXOffsets[i] = random(1000); // Randomize Perlin noise starting points for each cloud
    cloudYOffsets[i] = random(1000);
  }
}

void draw() {
  // Draw the image as the background
  image(bgImage, 0, 0, width, height);
  
 // Draw clouds with Perlin noise movement
  for (int i = 0; i < numClouds; i++) {
    // Update cloud positions with Perlin noise
    cloudX[i] += map(noise(cloudXOffsets[i]), 0, 1, -0.5, 0.5); // Move horizontally based on noise
    cloudY[i] += map(noise(cloudYOffsets[i]), 0, 1, -0.1, 0.1); // Slight vertical drift

    // Increment noise offsets for smooth movement
    cloudXOffsets[i] += 0.01; // Adjust the increment for different movement speeds
    cloudYOffsets[i] += 0.01;

    // Wrap the cloud around the screen if it moves off the edge
    if (cloudX[i] > width) cloudX[i] = -cloudImage.width;
    if (cloudX[i] < -cloudImage.width) cloudX[i] = width;

    // Draw the cloud with transparency
    tint(255, 150); // Adjust transparency level
    image(cloudImage, cloudX[i], cloudY[i], 250, 150); // Draw cloud image with size adjustment
  }
  noTint(); // Reset tint to default

  // Simulate wind with mouse position
  windIntensity = map(mouseX, 0, width, 0, 1); 

  // Calculate wind power output
  currentWindPowerOutput = maxWindPowerOutput * windIntensity;

  // Update blade speed based on wind intensity
  bladeSpeed = map(windIntensity, 0, 1, 0.1, 2.0); // Scale blade speed from 0.1 to 2.0
  bladeSpeeds[speedIndex] = bladeSpeed; // Store the current speed in the array
  speedIndex = (speedIndex + 1) % bladeSpeeds.length; // Update index and wrap around

  // Update blade angle based on wind power output
  bladeAngle += bladeSpeed * windIntensity; 

  // Check if the mouse is moving forward or backward
  if (mouseX > previousMouseX) {
    drawLines = true;  // Set to true if mouse is moving forward
  } else {
    drawLines = false; // Set to false if mouse is still or moving backward
  }

  // Update previous mouse position
  previousMouseX = mouseX;

  // Play wind sound only if wind intensity is above 0.10
  if (windIntensity > 0.20 && !windSound.isPlaying()) {
    windSound.loop(); // Start or loop the wind sound if not already playing
  } else if (windIntensity <= 0.20 && windSound.isPlaying()) {
    windSound.pause(); // Pause the wind sound if wind intensity drops below the threshold
  }

  // Shapes set to CENTER mode
  ellipseMode(CENTER);
  rectMode(CENTER);

  // Draw grass plain at the bottom of the screen
  drawGrassPlain();

  // Base of wind turbine
  stroke(133, 132, 132);
  strokeWeight(1);
  fill(242, 243, 242);
  rect(310, 490, 15, 450);

  // Center of wind turbine
  stroke(133, 132, 132);
  strokeWeight(1);
  fill(242, 243, 242);
  ellipse(310, 255, 25, 27); 

  // Draw blades with rotation
  push();  // Save the current transformation
  translate(310, 255);  // Move to center of turbine
  rotate(bladeAngle);  // Rotate the blades
  fill(242, 243, 242);
  ellipse(-75, 3, 137, 20);  // Horizontal blade
  ellipse(0, -75, 20, 137);  // Vertical blade
  ellipse(75, 3, 137, 20);  // Horizontal blade
  pop();  // Restore the transformation
  
  // Set transparency for the cloud background image (0 = fully transparent, 255 = fully opaque)
  tint(255, 200);  // Adjust the second value (150) for the level of transparency
  
   // Position the text background image before displaying text
  int textBgX = 290; // X position for the text background image
  int textBgY = -85;  // Y position for the text background image
  int textBgWidth = 500; // Width of the text background image
  int textBgHeight = 230; // Height of the text background image
  image(textBackgroundImage, textBgX, textBgY, textBgWidth, textBgHeight);
  
  // Reset tint to default so it doesn't affect other images
  noTint();

  // Display Power Outputs
  fill(0); // Text color
  textSize(27); // Set text size
  textAlign(CENTER, CENTER); // Center the text
  text("Wind Intensity: " + nf(windIntensity, 1, 2), 520, 25);
  text("Wind Power Output: " + nf(currentWindPowerOutput, 1, 2) + " watts", 520, 60);
  text("Blade Speed: " + nf(bladeSpeed, 1, 2) + " rad/s", 520, 95); // Display blade speed
  
  // Moves the curve with the mouse
  translate(mouseX, mouseY);

  // Draw the curve when the mouse is moving forward
  if (drawLines) {
    stroke(128,128,128);
    strokeWeight(2);
    noFill();
    beginShape();
    vertex(30, 75); // Starting point
    bezierVertex(50, 50, 70, 90, 100, 70); // First wave
    bezierVertex(130, 50, 150, 90, 180, 70); // Second wave
    endShape();

    // Draw the extra line when the mouse moves forward
    stroke(128,128,128);
    strokeWeight(2);
    noFill();
    beginShape();
    vertex(30, 100);
    bezierVertex(50, 75, 70, 120, 100, 100); // First wave
    bezierVertex(130, 75, 150, 120, 180, 100); // Second wave
    endShape();
  }
}

void drawGrassPlain() {
  fill(157, 152, 108, 130); // Base color for plains

  beginShape();
  for (float x = 0; x <= width; x += 5) {
    // Use Perlin noise to create a more realistic terrain
    float noiseVal = noise(x * 0.01, frameCount * 0.01);
    float y = height - 75 + noiseVal * 30;
    vertex(x, y);
  }
  vertex(width, height); // Close the shape
  vertex(0, height); // Close the shape
  endShape(CLOSE);
}

void keyPressed() {
  // Stop sounds when the user presses a key
  windSound.pause(); // Pause the wind sound
  backgroundSound.pause(); // Pause the background sound
}

void stop() {
  // Clean up Minim objects before exiting
  windSound.close();
  backgroundSound.close();
  minim.stop();
}
