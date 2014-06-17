/**
 * Author:         Benjamin Low (Lthben@gmail.com)
 * Date:           June 2014
 * Description:    An application that takes the image seen by a webcam, 
 *                 processes the color data and sends out the result 
 *                 to another program that converts the data into sound  
 */

import processing.video.*;

Capture cam;
ScanLine scanline;
GUI myGUI;

//user defined parameters
int play_dur = 50000; //in milliseconds, can range from 1 second onwards 
int color_detection_threshold = 20; //sensitivity to detection, should be in range 1 to 50 whereabouts
color[] chosen_colors; //user chosen colors
int[] chosen_sounds;

final int NUM_TRACKS = 10; //maximum number of sound tracks 

void setup() {
        size(1280, 720, P2D);

        frameRate(60);

        chosen_colors = new color[NUM_TRACKS];
        chosen_sounds = new int[NUM_TRACKS];

        for (int i=0; i<NUM_TRACKS; i++) {
                chosen_colors[i] = color(0, 0, 0);
        }

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
                cam = new Capture(this, 640, 480, 15); //can set fps here too

                // Start capturing the images from the camera
                cam.start();
        }
        
        scanline = new ScanLine();

        cp5 = new ControlP5(this);

        myGUI = new GUI(cp5);
}

void draw() {

        background(50);

        if (cam.available() == true) {
                cam.read();
        }

        cam.loadPixels();

        //mirror image
        pushMatrix();
        scale(-1, 1);
        //tint(255, 50);
        imageMode(CENTER);
        image(cam, -width/2 , height/2);
        popMatrix();

        pushMatrix();
        translate(320, 120);
        scanline.run_scan_line();
        popMatrix();

        color c = get(mouseX, mouseY);

        fill(255);
        textSize(12);

        text(red(c)+","+green(c)+","+blue(c), mouseX + 3, mouseY - 3);

        text("time: " + millis()/1000, width - 100, 20);

        //text("detected color: " + detected_colors[0], width - 200, 40);

        //text("average yPos: " + colors_yPos[0], width - 200, 60);
}

void keyPressed() {
        if (key == 'f') {
                println("Framerate: " + frameRate);
        }
}

void controlEvent(ControlEvent theEvent) {

        String myString = (String)theEvent.getName();

        if (myString.contains("checkBox")) {
                String the_color_index_string = myString.replace("checkBox", "");
                int the_color_index_int = int(the_color_index_string);
                println(the_color_index_int);
        }
}

