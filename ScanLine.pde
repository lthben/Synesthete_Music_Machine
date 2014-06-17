class ScanLine {

        int[] detected_colors; //the number of detections of each chosen color. This determines volume per NUM_TRACK.
        int[] colors_yPos; //the average yPos of the detected colors. This determines pitch per NUM_TRACK.

        final int scan_line_width = 10; //width of scanning line in pixels. Don't change this.

        float scan_line_xPos;
        int box_size = scan_line_width; //scan line is made up of vertical boxes
        int scan_res = scan_line_width/2; //scan resolution. will determine number of sample points per box. In this case, 4.

        ScanLine() {
                detected_colors = new int[NUM_TRACKS];
                colors_yPos = new int[NUM_TRACKS];
        }

        void run_scan_line() {

                //scan line movement speed
                scan_line_xPos += (cam.width * 1.0 / frameRate) / ( play_dur * 1.0 / 1000.0);

                if (scan_line_xPos > cam.width - scan_line_width) scan_line_xPos = 0;

                for (int i=0; i < NUM_TRACKS; i++) {
                        //clear before checking for each column
                        detected_colors[i] = 0;
                        colors_yPos[i] = 0;
                }

                get_column_data();
                
                stroke(127);
                strokeWeight(1);
                line(scan_line_xPos, 0, scan_line_xPos, cam.height);
                line(scan_line_xPos+scan_line_width, 0, scan_line_xPos+scan_line_width, cam.height);
        }

        void get_column_data() {
                //get column data, i.e. number of detected colors and their average yPos 

                for (int box_yPos = 0; box_yPos < cam.height; box_yPos+= box_size) {

                        //if (xPos > width) xPos = 0;

                        color box_color = compute_one_box_color( int(scan_line_xPos), box_yPos);

                        //display boxes
                        fill(box_color);
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

                        if (abs(red(the_color) - red(chosen_colors[i])) < color_detection_threshold) {

                                if (abs(green(the_color) - green(chosen_colors[i])) < color_detection_threshold) {

                                        if (abs(blue(the_color) - blue(chosen_colors[i])) < color_detection_threshold) {

                                                return i; //return index of color detected
                                        }
                                }
                        }
                }
                return -1; //no color detected
        }
}

