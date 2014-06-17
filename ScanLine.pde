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
}

