/**
 * Getting Started with Capture.
 * 
 * Reading and displaying an image from an attached Capture device. 
 */

import processing.video.*;

Capture cam;

int SAMPLE_RES = 25; //spacing between samples
int NUM_TRACKS = 5;
int NUM_BARS = 9;
int PLAY_SPEED = 500; //in milliseconds

void setup() {
        size(640, 480, P2D);

        frameRate(5);

        String[] cameras = Capture.list();

        if (cameras.length == 0) {
                println("There are no cameras available for capture.");
                exit();
        } else {
                println("Available cameras:");
                for (int i = 0; i < cameras.length; i++) {
                        println(cameras[i]);
                }

                // The camera can be initialized directly using an element
                // from the array returned by list():
                //    cam = new Capture(this, cameras[0]);
                // Or, the settings can be defined based on the text in the list
                cam = new Capture(this, 640, 480, 1);

                // Start capturing the images from the camera
                cam.start();
        }
}

void draw() {
        if (cam.available() == true) {
                cam.read();
        }

        cam.loadPixels();

        for (int j = height / NUM_TRACKS; j < height; j += height / NUM_TRACKS) {
                fill(200, 150);
                strokeWeight(1);
                line(0, j, width, j);
        }

        for (int i = width/NUM_BARS; i < width; i += width/NUM_BARS) {
                line(i, 0, i, height);
        }



        for (int j = 0; j < height; j+= height/NUM_TRACKS) {
                for (int i = 0; i < width - 1; i+= width/NUM_BARS) {

                        color c = compute_one_box(i, j);
                        fill(c, 80);
                        rect(i, j, width/NUM_BARS, height/NUM_TRACKS);

                        fill(255);
                        textSize(8);
                        text(int(red(c)) + "," + int(green(c)) + "," + int(blue(c)), i + 10, j + 50);
                }
        }
}


color compute_one_box(int x, int y) {

        int red = 0;
        int green = 0;
        int blue = 0;
        int numPoints = 0;

        for (int i = x + SAMPLE_RES/2; i < x + width/NUM_BARS; i += SAMPLE_RES) {
                for (int j = y + SAMPLE_RES/2; j < y +  height/NUM_TRACKS; j += SAMPLE_RES) {
                        fill(255, 255, 0);
                        noStroke();
                        ellipse(i, j, 2, 2);


                        color currColor = cam.pixels[j*cam.width + i];

                        // Extract the red, green, and blue components of the current pixel's color
                        int currR = (currColor >> 16) & 0xFF;
                        int currG = (currColor >> 8) & 0xFF;
                        int currB = currColor & 0xFF;
                        red += currR; 
                        green += currG; 
                        blue += currB;
                        numPoints++;
                }
        }

        return color( red/numPoints, green/numPoints, blue/numPoints);
}

