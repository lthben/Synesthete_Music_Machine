/**
 * Author:         Benjamin Low (Lthben@gmail.com)
 * Date:           June 2014
 * Description:    An application that takes the image seen by a webcam, 
 *                 processes the color data and sends out the result 
 *                 to another program that converts the data into sound  
 */

import processing.video.*;

Capture cam;

int NUM_TRACKS = 5; //should range between 1 to 10
int PLAY_DUR = 30000; //in milliseconds, can range from 1 second onwards 
int COLOR_DETECTION_THRESHOLD = 20; //sensitivity to detection, should be in range 1 to 50 whereabouts

color[] chosen_colors; //user chosen colors
int[] detected_colors; //the number of detections of each chosen color. This determines volume per NUM_TRACK.
int[] colors_yPos; //the average yPos of the detected colors. This determines pitch per NUM_TRACK.

int scan_line_width = 10; //width of scanning line in pixels. Don't change this.

void setup() {
        size(640, 480, P2D);

        chosen_colors = new color[NUM_TRACKS];
        chosen_colors[0] = color(0, 0, 0);
        chosen_colors[1] = color(255, 0, 0);
        chosen_colors[2] = color(255, 0, 0);
        chosen_colors[3] = color(255, 0, 0);
        chosen_colors[4] = color(255, 0, 0);
        
        detected_colors = new int[NUM_TRACKS];
        colors_yPos = new int[NUM_TRACKS];

        frameRate(60);

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
}

void draw() {

        background(0);

        if (cam.available() == true) {
                cam.read();
        }

        cam.loadPixels();
        
        //mirror image
        pushMatrix();
        scale(-1,1);
        tint(255,100);
        image(cam, -width, 0);
        popMatrix();
        
        run_scan_line();
        
        color c = get(mouseX, mouseY);
        
        fill(255);
        textSize(12);
        
        text(red(c)+","+green(c)+","+blue(c), mouseX + 3, mouseY - 3);
        
        text("time: " + millis()/1000, width - 100, 20);
        
        //text("detected color: " + detected_colors[0], width - 200, 40);
        
        //text("average yPos: " + colors_yPos[0], width - 200, 60);
        
}


float scan_line_xPos;
int box_size = scan_line_width; //scan line is made up of vertical boxes
int scan_res = scan_line_width/2; //scan resolution
        
void run_scan_line() {
        
        //scan line movement speed
        scan_line_xPos += (width * 1.0 / frameRate) / ( PLAY_DUR * 1.0 / 1000.0);
        
        if (scan_line_xPos > width) scan_line_xPos = 0;
        
        for (int i=0; i < NUM_TRACKS; i++) {
                //clear before checking for each column
                detected_colors[i] = 0;
                colors_yPos[i] = 0;
        }

        get_column_data();        
}

void get_column_data() {
        //get column data, i.e. number of detected colors and their average yPos 
        
        for (int box_yPos = 0; box_yPos < height; box_yPos+= box_size) {

                //if (xPos > width) xPos = 0;

                color box_color = compute_one_box_color( int(scan_line_xPos), box_yPos);
                
                //display boxes
                fill(box_color, 80);
                rect(scan_line_xPos, box_yPos, box_size, box_size);

                //update detected colors for this column 
                int color_index = check_color(box_color); 
                
                if (color_index != -1) { 
                        detected_colors[color_index] += 1;
                        colors_yPos[color_index] += box_yPos;
                }

                fill(255);
                textSize(8);

                if (check_color(box_color) != -1) { 
                        textSize(12); 
                        fill(255, 255, 0);
                }

                //text(int(red(box_color)) + "," + int(green(box_color)) + "," + int(blue(box_color)), scan_line_xPos, box_yPos + 20);
        }
        
        //compute average yPos
        for (int i=0; i<NUM_TRACKS; i++) {
                if (detected_colors[i] != 0) {
                        colors_yPos[i] = colors_yPos[i] / detected_colors[i];    
                }   
        }
}

color compute_one_box_color(int x, int y) {
        // computes the average color for one box, given the upper left coordinates of the box

        int red = 0;
        int green = 0;
        int blue = 0;
        int numPoints = 0;

        for (int i = x + scan_res/2; i < x + box_size; i += scan_res) {
                for (int j = y + scan_res/2; j < y + box_size; j += scan_res) {
                        fill(255, 255, 0);
                        noStroke();
                        //ellipse(i, j, 2, 2); //show position of sampling points


                        color currColor = cam.pixels[j*cam.width + (cam.width - i)]; //mirror image

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

int check_color(color the_color) {
        //checks if the color belongs to any of the chosen colors and returns an index of that color in chosen_colors[]
        
        for (int i =0; i < chosen_colors.length; i++) {

                if (abs(red(the_color) - red(chosen_colors[i])) < COLOR_DETECTION_THRESHOLD) {

                        if (abs(green(the_color) - green(chosen_colors[i])) < COLOR_DETECTION_THRESHOLD) {

                                if (abs(blue(the_color) - blue(chosen_colors[i])) < COLOR_DETECTION_THRESHOLD) {

                                        return i; //return index of color detected
                                }
                        }
                }
        }
        return -1; //no color detected
}

void keyPressed() {
         if (key == 'f') {
                 println("Framerate: " + frameRate);
         
         }
}
