import oscP5.*;
import netP5.*;

class ScanLine {

        int[] detected_colors; //the number of detections of each chosen color. This determines volume per NUM_TRACK. E(X) = 0.5*(cam.height/box_size)
        int[] colors_yPos; //the average yPos of the detected colors. This determines pitch per NUM_TRACK. E(X) = cam.height/2

        int scan_line_width = 10; //width of scanning line in pixels

        int box_size = scan_line_width; //scan line is made up of vertical boxes
        int scan_res = scan_line_width/2; //scan resolution. will determine number of sample points per box. E.g. 10/2 = 4.

        boolean is_playing;

        float crop_amount = 5;
        float scan_line_xPos = crop_amount * 0.01 * cam.width;

        ScanLine() {
                detected_colors = new int[NUM_TRACKS];
                colors_yPos = new int[NUM_TRACKS];
        }

        void run() {

                float crop_x = crop_amount * 0.01 * cam.width; 
                float crop_y = crop_amount * 0.01 * cam.height;

                //scan line movement speed
                scan_line_xPos += ( (cam.width - 2*crop_x) * 1.0 / frameRate) / ( play_dur * 1.0 / 1000.0);
                if (scan_line_xPos > (cam.width - crop_x) - scan_line_width) scan_line_xPos = crop_x;

                //clear before checking for each column
                for (int i=0; i < NUM_TRACKS; i++) {
                        detected_colors[i] = 0;
                        colors_yPos[i] = 0;
                }

                get_column_data(int(crop_x), int(crop_y));

                stroke(127);
                strokeWeight(1);
                line(scan_line_xPos, crop_y, scan_line_xPos, cam.height-crop_y);
                line(scan_line_xPos+scan_line_width, crop_y, scan_line_xPos+scan_line_width, cam.height-crop_y);

                pushMatrix();
                translate(cam.width+50, 0);
                show_output();
                popMatrix();
        }

        void get_column_data(int _crop_x, int _crop_y) {
                //get column data, i.e. number of detected colors and their average yPos 

                for (int box_yPos = _crop_y; box_yPos < cam.height - _crop_y - box_size; box_yPos+= box_size) {

                        //if (xPos > width) xPos = 0;

                        color box_color = compute_one_box_color( int(scan_line_xPos), box_yPos);

                        //display boxes
                        fill(box_color);
                        rect(scan_line_xPos, box_yPos, box_size, box_size);

                        //update detected colors for this column 
                        update_colors(box_color, box_yPos);
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

                                color curr_color = cam.pixels[j*cam.width + (cam.width - i)]; //mirror image

                                // Extract the red, green, and blue components of the current pixel's color
                                int currR = (curr_color >> 16) & 0xFF;
                                int currG = (curr_color >> 8) & 0xFF;
                                int currB = curr_color & 0xFF;
                                red += currR; 
                                green += currG; 
                                blue += currB;
                                numPoints++;
                        }
                }

                return color( red/numPoints, green/numPoints, blue/numPoints);
        }

        IntList check_this_color_chosen (color the_color) {
                //for the scanline:-
                //checks whether a color is nearby to one or more of the chosen colors 
                //and returns an array of indices from the chosen colors.

                IntList detected_indices = new IntList();

                for (int i =0; i < chosen_colors.size (); i++) {

                        int curr_color = chosen_colors.get(i);
                        int currR = (curr_color >> 16) & 0xFF;
                        int currG = (curr_color >> 8) & 0xFF;
                        int currB = curr_color & 0xFF;

                        if (abs(red(the_color) - currR) <= color_detection_threshold) {

                                if (abs(green(the_color) - currG) <= color_detection_threshold) {

                                        if (abs(blue(the_color) - currB) <= color_detection_threshold) {

                                                detected_indices.append(i);
                                        }
                                }
                        }
                } 

                return detected_indices;
        }

        IntList check_this_color_palette (color the_color, int _threshold) {
                //for the mouse cursor:-
                //checks whether a color is nearby to one or more of the palette colors 
                //and returns an array of indices from the palette colors

                IntList detected_indices = new IntList();

                for (int i =0; i < color_palette.length; i++) {

                        int curr_color = color_palette[i];
                        int currR = (curr_color >> 16) & 0xFF;
                        int currG = (curr_color >> 8) & 0xFF;
                        int currB = curr_color & 0xFF;

                        if (abs(red(the_color) - currR) <= _threshold) {

                                if (abs(green(the_color) - currG) <= _threshold) {

                                        if (abs(blue(the_color) - currB) <= _threshold) {

                                                detected_indices.append(i);
                                        }
                                }
                        }
                }

                return detected_indices;
        }

        void update_colors(color the_color, int yPos) {
                //checks if the color belongs to any of the chosen colors and updates the detected colors

                        IntList detected_indices = check_this_color_chosen(the_color);

                for (int i=0; i<detected_indices.size (); i++) {

                        int index = detected_indices.get(i);
                        detected_colors[index] += 1;
                        colors_yPos[index] += yPos;
                }
        }

        void show_output() {
                fill(50);
                noStroke();
                rect(0, 0, cam.width, cam.height); 

                final int X_SPACING = 30;
                final int MAX_DIAMETER = X_SPACING * 5;
                float xPos = 0, yPos = 0, diameter = 0; 

                for (int i=0; i<NUM_TRACKS; i++) {

                        xPos = (i+1) * X_SPACING * 1.5 - 0.25 * X_SPACING;

                        yPos = colors_yPos[i];

                        diameter = map(detected_colors[i], 0, (cam.height-crop_amount*2)/box_size, 0, MAX_DIAMETER);

                        fill(color(chosen_colors.get(i)));
                        ellipse(xPos, yPos, diameter, diameter);

                        send_data(i, yPos, diameter);
                }
        }

        void send_data(int _index, float _yPos, float _diameter) {
                
                OscMessage data_msg = new OscMessage("/channel/pitch/volume"); //0-9, 0-cam.height (360), 0-150

                data_msg.add(_index);
                data_msg.add(_yPos);
                data_msg.add(_diameter);
                oscP5.send(data_msg, myRemoteLocation);
        }

        void show_frame_crop() {

                float x_width = crop_amount * 0.01 * cam.width;
                float y_width = crop_amount * 0.01 * cam.height;

                pushMatrix();
                translate(100, 335);

                fill(255, 100);
                noStroke();

                beginShape();
                vertex(0, 0);
                vertex(x_width, y_width);
                vertex(cam.width-x_width, y_width);
                vertex(cam.width-x_width, cam.height-y_width);
                vertex(x_width, cam.height-y_width);
                vertex(x_width, y_width);
                vertex(0, 0);
                vertex(0, cam.height);
                vertex(cam.width, cam.height);
                vertex(cam.width, 0);
                vertex(0, 0);
                endShape(CLOSE);

                popMatrix();
        }
}

