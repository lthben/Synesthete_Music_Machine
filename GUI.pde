import controlP5.*;

class GUI {

        CheckBox[] checkboxes;
        int[][] checkbox_positions;
        //IntList chosen_colors_indices;
        int[] my_chosen_colors_indices;

        MultiList ml1, ml2, ml3, ml4, ml5, ml6, ml7, ml8, ml9, ml10;
        MultiListButton b1, b2, b3, b4, b5, b6, b7, b8, b9, b10;
        Button play_button;

        String[] sound_names;
        String collection_name;

        PApplet p;

        ControlP5 cp5;

        int mouse_is_in;
        final int CAM_WINDOW = 0, 
        COL_1_BOX = 10, COL_2_BOX = 11, COL_3_BOX = 12, COL_4_BOX = 13, COL_5_BOX = 14, 
        COL_6_BOX = 15, COL_7_BOX = 16, COL_8_BOX = 17, COL_9_BOX = 18, COL_10_BOX = 19, 
        COL_1_SELECT_BOX = 20, COL_2_SELECT_BOX = 21, COL_3_SELECT_BOX = 22, COL_4_SELECT_BOX = 23, COL_5_SELECT_BOX = 24, 
        COL_6_SELECT_BOX = 25, COL_7_SELECT_BOX = 26, COL_8_SELECT_BOX = 27, COL_9_SELECT_BOX = 28, COL_10_SELECT_BOX = 29, 
        NOWHERE_IMPT = 99;

        boolean is_show_color_feedback;

        int[] select_boxes_state;
        final int EMPTY = 0, PENDING = 1, FULL = 2;

        boolean is_ready_for_selection; //palette only accepts clicks when this is true, i.e. when a select box is pending
        boolean is_lock_colors;//lock colors in palette when clicking inside the cam window, unlock when clicking outside
        int color_to_feedback;//stores the color at mouse cursor locked by mouseclicking inside the cam window

        GUI(PApplet parent) {

                p = parent;

                cp5 = new ControlP5(p);

                checkboxes = new CheckBox[117];
                checkbox_positions = new int[117][2];
                //                chosen_colors_indices = new IntList();
                my_chosen_colors_indices = new int[NUM_TRACKS];

                select_boxes_state = new int[NUM_TRACKS];
                for (int i=0; i<NUM_TRACKS; i++) {
                        select_boxes_state[i] = EMPTY;
                }

                init_color_palette();

                set_up_palette();

                //Preview and None sound bangs
                for (int i=0; i<NUM_TRACKS/2; i++) {
                        cp5.addBang("bang" + i)
                                .setPosition(100+i*250, 110)
                                        .setSize(25, 25)
                                                .setId(i)
                                                        .setLabel("preview")
                                                                ;
                }

                for (int i=0; i<NUM_TRACKS/2; i++) {
                        cp5.addBang("bang" + (i+5))
                                .setPosition(100+i*250, 200)
                                        .setSize(25, 25)
                                                .setId(i+5)
                                                        .setLabel("preview")
                                                                ;
                }

                //sliders
                cp5.addSlider("play_duration")
                        .setPosition(100, 280)
                                .setRange(10, 120)
                                        .setWidth(200)
                                                .setHeight(30)
                                                        .setValue(60)
                                                                ;

                cp5.addSlider("color_detection_threshold")
                        .setPosition(350, 280)
                                .setRange(1, 63*2)
                                        .setWidth(200)
                                                .setHeight(30)
                                                        .setValue(63)
                                                                ;

                cp5.addSlider("frame_crop")
                        .setPosition(600, 280)
                                .setRange(0, 50)
                                        .setWidth(200)
                                                .setHeight(30)
                                                        .setValue(2)
                                                                ;

                cp5.getController("play_duration").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
                cp5.getController("color_detection_threshold").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
                cp5.getController("frame_crop").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);

                //sound selection multilists
                for (int index_ml=0; index_ml<NUM_TRACKS; index_ml++) {

                        MultiList a_multilist;

                        switch(index_ml) {
                                case(1):
                                a_multilist = ml1;
                                break;
                                case(2):
                                a_multilist = ml2;
                                break;
                                case(3):
                                a_multilist = ml3;
                                break;
                                case(4):
                                a_multilist = ml4;
                                break;
                                case(5):
                                a_multilist = ml5;
                                break;
                                case(6):
                                a_multilist = ml6;
                                break;
                                case(7):
                                a_multilist = ml7;
                                break;
                                case(8):
                                a_multilist = ml8;
                                break;
                                case(9):
                                a_multilist = ml9;
                                break;
                                case(10):
                                a_multilist = ml10;
                                break;
                        }

                        if (index_ml<5) {
                                a_multilist = cp5.addMultiList("ml"+index_ml, 130+index_ml*250, 110, 75, 25);
                        } else {
                                a_multilist = cp5.addMultiList("ml"+index_ml, 130+(index_ml-5)*250, 200, 75, 25);
                        }

                        add_level_one_buttons(a_multilist, index_ml);
                }

                //text labels
                cp5.addTextlabel("label_title")
                        .setText("S Y N E S T H E T E  M U S I C A L  I N S T R U M E N T")
                                .setPosition(25, 20)
                                        .setColorValue(color(255))
                                                .setFont(createFont("Helvetica", 24))
                                                        ;

                cp5.addTextlabel("label_colors")
                        .setText("colours")
                                .setPosition(25, 85)
                                        .setColorValue(color(255))
                                                .setFont(createFont("Helvetica", 12))
                                                        ;

                cp5.addTextlabel("label_sounds")
                        .setText("sounds")
                                .setPosition(25, 115)
                                        .setColorValue(color(255))
                                                .setFont(createFont("Helvetica", 12))
                                                        ;

                cp5.addTextlabel("label_instructions")
                        .setText("Click to select or de-select colours")
                                .setPosition(25, 725)
                                        .setColorValue(color(255))
                                                .setFont(createFont("Helvetica", 12))
                                                        ;

                sound_names = new String[NUM_TRACKS];
                for (int i=0; i<NUM_TRACKS; i++) {
                        sound_names[i] = "";
                }
                collection_name = "";

                //play button
                play_button = cp5.addButton("play_stop")
                        .setPosition(1320, 260)
                                .setColorBackground(color(0, 255, 0)) 
                                        .setSize(50, 50)
                                                ;

                cp5.getController("play_stop").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(2);
        }

        void add_level_one_buttons(MultiList ml, int _index_ml) {

                MultiListButton a_multiListButton; 

                if (ml == ml1) {
                        a_multiListButton = b1;
                } else if (ml == ml2) {
                        a_multiListButton = b2;
                } else if (ml == ml3) {
                        a_multiListButton = b3;
                } else if (ml == ml4) {
                        a_multiListButton = b4;
                } else if (ml == ml5) {
                        a_multiListButton = b5;
                } else if (ml == ml6) {
                        a_multiListButton = b6;
                } else if (ml == ml7) {
                        a_multiListButton = b7;
                } else if (ml == ml8) {
                        a_multiListButton = b8;
                } else if (ml == ml9) {
                        a_multiListButton = b9;
                } else if (ml == ml10) {
                        a_multiListButton = b10;
                }

                a_multiListButton = ml.add("pick_collection" + _index_ml, _index_ml);
                a_multiListButton.setLabel("pick sounds");

                MultiListButton c;

                for (int index_collection=0; index_collection<6; index_collection++) {

                        String indexS = Integer.toString(_index_ml) + Integer.toString(index_collection) + ".0";
                        float index_ml_collection = Float.valueOf(indexS).floatValue();

                        c = a_multiListButton.add("collect_" + _index_ml + index_collection, int(index_ml_collection));

                        switch(index_collection) {
                                case(0):
                                c.setLabel("pleasant");
                                break;
                                case(1):
                                c.setLabel("electronic");
                                break;
                                case(2):
                                c.setLabel("nature");
                                break;
                                case(3):
                                c.setLabel("comedy");
                                break;
                                case(4):
                                c.setLabel("radio");
                                break;
                                case(5):
                                c.setLabel("musical");
                                break;
                                //                                case(6):
                                //                                c.setLabel("choral");
                                //                                break;
                                //                                case(7):
                                //                                c.setLabel("piano");
                                //                                break;
                                //                                case(8):
                                //                                c.setLabel("orchestral");
                                //                                break;
                                //                                case(9):
                                //                                c.setLabel("electronic");
                                //                                break;
                        }                 
                        c.setHeight(15);
                        c.setColorBackground(color(64 + 18*index_collection, 0, 0));

                        //                        for (int index_sound=0; index_sound<NUM_TRACKS; index_sound++) {
                        //                                add_level_two_buttons(c, _index_ml, index_collection, index_sound);
                        //                        }
                }

                //add NONE button
                String indexS = Integer.toString(_index_ml) + Integer.toString(10) + ".0";
                float index_ml_collection = Float.valueOf(indexS).floatValue();

                c = a_multiListButton.add("none_" + _index_ml + 10, int(index_ml_collection));
                c.setLabel("none");
                c.setHeight(15);
                c.setColorBackground(color(64 + 18*10, 0, 0));
        }

        void add_level_two_buttons(MultiListButton c, int index_ml, int index_collection, int index_song) {

                MultiListButton d; 

                String sound_index_999_string = Integer.toString(index_ml) + Integer.toString(index_collection) + Integer.toString(index_song) + ".0";
                float sound_index_999_float = Float.valueOf(sound_index_999_string).floatValue();
                int sound_index_999 = int(sound_index_999_float); //0-999

                d = c.add("song_" + sound_index_999, sound_index_999);

                String sound_index_99_string = Integer.toString(index_collection) + Integer.toString(index_song);
                float sound_index_99_float = Float.valueOf(sound_index_99_string).floatValue();
                int sound_index_99 = int(sound_index_99_float);

                String sound_name = get_sound_name(sound_index_99);

                d.setLabel(sound_name);
                d.setColorBackground(color(0, 0, 64 + 18*index_song)); 
                d.setHeight(15);
        }

        void init_color_palette() {

                color[] _color_palette = { 
                        #FFCCCC, #FF9999, #FF6666, #FF3333, #FF0000, #CC0000, #990000, #660000, #330000, 
                        #FFE5CC, #FFCC99, #FFB266, #FF9933, #FF8000, #CC6600, #994C00, #663300, #331900, 
                        #FFFFCC, #FFFF99, #FFFF66, #FFFF33, #FFFF00, #CCCC00, #999900, #666600, #333300, 
                        #E5FFCC, #CCFF99, #B2FF66, #99FF33, #80FF00, #66CC00, #4C9900, #336600, #193300, 
                        #CCFFCC, #99FF99, #66FF66, #33FF33, #00FF00, #00CC00, #009900, #006600, #003300, 
                        #CCFFE5, #99FFCC, #66FFB2, #33FF99, #00FF80, #00CC66, #00994C, #006633, #003319, 
                        #CCFFFF, #99FFFF, #66FFFF, #33FFFF, #00FFFF, #00CCCC, #009999, #006666, #003333, 
                        #CCE5FF, #99CCFF, #66B2FF, #3399FF, #0080FF, #0066CC, #004C99, #003366, #001933, 
                        #CCCCFF, #9999FF, #6666FF, #3333FF, #0000FF, #0000CC, #000099, #000066, #000033, 
                        #E5CCFF, #CC99FF, #B266FF, #9933FF, #8000FF, #6600CC, #4C0099, #330066, #190033, 
                        #FFCCFF, #FF99FF, #FF66FF, #FF33FF, #FF00FF, #CC00CC, #990099, #660066, #330033, 
                        #FFCCE5, #FF99CC, #FF66B2, #FF3399, #FF0080, #CC0066, #99004C, #660033, #330019, 
                        #FFFFFF, #E0E0E0, #C0C0C0, #A0A0A0, #808080, #606060, #404040, #202020, #000000
                };

                color_palette = _color_palette;
        }

        void set_up_palette() {
                int counter = 0; 

                for (int yPos=335; yPos<height; yPos+=25) {
                        for (int xPos=1150; xPos<width-75; xPos+=25) {

                                if (counter < 117) {

                                        color c = color_palette[counter];
                                        //println(red(c) + " " + green(c) + " " + blue(c));

                                        checkboxes[counter] = cp5.addCheckBox("checkBox" + counter)
                                                .setPosition(xPos, yPos)
                                                        .setColorForeground(color(120))
                                                                .setColorActive(c) 
                                                                        .setColorBackground(c)
                                                                                .setSize(20, 20)
                                                                                        .addItem("color" + counter, counter)
                                                                                                .hideLabels()
                                                                                                        ; 

                                        checkbox_positions[counter][0] = xPos - 2;
                                        checkbox_positions[counter][1] = yPos - 2;

                                        counter++;
                                }
                        }
                }
        }

        void show_chosen_colors() {
                int yPos = 80; 
                int yOffset = 90;

                //show chosen colors in color boxes
                for (int i=0; i<5; i++) {
                        if (my_chosen_colors[i] != -1) {
                                color c = color(my_chosen_colors[i]);
                                fill(c);
                                noStroke();
                                rect(100+i*250, yPos, 50, 25);
                        }
                }
                for (int j=5; j<NUM_TRACKS; j++) {
                        if (my_chosen_colors[j] != -1) {
                                color c = color(my_chosen_colors[j]);   
                                fill(c);
                                noStroke();
                                rect(100+(j-5)*250, yPos+yOffset, 50, 25);
                        }
                }

                //show feedback on the palette on which colors were chosen 
                for (int k=0; k<NUM_TRACKS; k++) {
                        if (my_chosen_colors[k] != -1) {
                                int chosen_color_index = my_chosen_colors_indices[k];
                                color c = color(my_chosen_colors[k]);
                                fill(c);
                                stroke(100); 
                                strokeWeight(1);
                                int checkbox_xPos = checkbox_positions[chosen_color_index][0];
                                int checkbox_yPos = checkbox_positions[chosen_color_index][1];
                                rect(checkbox_xPos, checkbox_yPos, 24, 24);
                        }
                }

                /***
                 //show chosen colors in color boxes
                 if (chosen_colors.size() > 5) {
                 for (int i=0; i<5; i++) {
                 color c = color(chosen_colors.get(i)); 
                 fill(c); 
                 noStroke(); 
                 rect(100+i*250, yPos, 50, 25);
                 }
                 for (int j=5; j<chosen_colors.size (); j++) {
                 color c = color(chosen_colors.get(j));
                 fill(c);
                 noStroke();
                 rect(100+(j-5)*250, yPos+yOffset, 50, 25);
                 }
                 } else {
                 for (int i=0; i<chosen_colors.size(); i++) {
                 color c = color(chosen_colors.get(i)); 
                 fill(c); 
                 noStroke(); 
                 rect(100+i*250, yPos, 50, 25);
                 }
                 }
                 
                 //show feedback on which colors were chosen
                 for (int k=0; k<chosen_colors_indices.size (); k++) {
                 int chosen_color_index = chosen_colors_indices.get(k);
                 color c = chosen_colors.get(k);
                 fill(c);
                 stroke(100); 
                 strokeWeight(1);
                 int checkbox_xPos = checkbox_positions[chosen_color_index][0];
                 int checkbox_yPos = checkbox_positions[chosen_color_index][1];
                 rect(checkbox_xPos, checkbox_yPos, 24, 24);
                 }
                 ***/
        }

        void run_select_boxes() {
                int yPos = 80; 
                int yOffset = 90;

                //default colors when no mouse-over
                noStroke();
                fill(0, 51, 102);

                for (int i=0; i<5; i++) {
                        rect(150+i*250, yPos, 55, 25);
                        rect(150+i*250, yPos + yOffset, 55, 25);
                }

                //feedback on mouse hovering over
                noStroke();                
                fill(51, 153, 255);

                switch(mouse_is_in) {
                        case(COL_1_SELECT_BOX):
                        rect(150, yPos, 55, 25);
                        break;
                        case(COL_2_SELECT_BOX):
                        rect(400, yPos, 55, 25);
                        break;
                        case(COL_3_SELECT_BOX):
                        rect(650, yPos, 55, 25);
                        break;
                        case(COL_4_SELECT_BOX):
                        rect(900, yPos, 55, 25);
                        break;
                        case(COL_5_SELECT_BOX):
                        rect(1150, yPos, 55, 25);
                        break;
                        case(COL_6_SELECT_BOX):
                        rect(150, yPos + yOffset, 55, 25);
                        break;
                        case(COL_7_SELECT_BOX):
                        rect(400, yPos + yOffset, 55, 25);
                        break;
                        case(COL_8_SELECT_BOX):
                        rect(650, yPos + yOffset, 55, 25);
                        break;
                        case(COL_9_SELECT_BOX):
                        rect(900, yPos + yOffset, 55, 25);
                        break;
                        case(COL_10_SELECT_BOX):
                        rect(1150, yPos + yOffset, 55, 25);
                        break;

                default:
                        break;
                }

                //visual symbols depending on state
                for (int i=0; i<NUM_TRACKS; i++) {
                        if (select_boxes_state[i] == EMPTY) {
                                if (i<5) {
                                        show_add_sign( 176+i*250, yPos+12);
                                } else {
                                        show_add_sign( 176+(i-5)*250, yPos+yOffset+12 );
                                }
                        } else if (select_boxes_state[i] == PENDING) {
                                if (i<5) {
                                        show_pending_sign( 176+i*250, yPos+12);
                                } else {
                                        show_pending_sign( 176+(i-5)*250, yPos+yOffset+12 );
                                }
                        } else if (select_boxes_state[i] == FULL) {
                                if (i<5) {
                                        show_minus_sign( 176+i*250, yPos+12);
                                } else {
                                        show_minus_sign( 176+(i-5)*250, yPos+yOffset+12 );
                                }
                        }
                }
        }

        void show_add_sign(int x, int y) {
                int r = 3;
                noFill();
                stroke(255);
                strokeWeight(1);
                ellipse(x, y, 4*r, 4*r);
                line(x-r, y, x+r, y);
                line(x, y-r, x, y+r);
        }

        void show_minus_sign(int x, int y) {
                int r = 3;
                noFill();
                stroke(255);
                strokeWeight(1);
                ellipse(x, y, 4*r, 4*r);
                line(x-r, y, x+r, y);
        }

        void show_pending_sign(int x, int y) {
                int r = 3;
                float d;
                d = 7*r + 2*r*sin(frameCount*0.4);
                noFill();
                stroke(255);
                strokeWeight(2);
                ellipse(x, y, d, d);
                line(x-r, y, x+r, y);
                line(x, y-r, x, y+r);
        }

        void show_boundary_boxes() {

                int yPos = 80; 
                int yOffset = 90;

                //boundary box
                for (int j=0; j<NUM_TRACKS/2; j++) {
                        noFill(); 
                        stroke(255); 
                        strokeWeight(1);
                        rect(100+j*250, yPos, 104, 25);
                }

                for (int j=0; j<NUM_TRACKS/2; j++) {
                        noFill(); 
                        stroke(255); 
                        strokeWeight(1);
                        rect(100+j*250, yPos+yOffset, 104, 25);
                }
        }

        void show_color_feedback() {
                //show detected colors as mouse hovers   
                if (is_show_color_feedback == true || is_lock_colors == true) {

                        int my_threshold = 0;

                        if (is_lock_colors == false) {
                                if (mouse_is_in == CAM_WINDOW) { //same translation as scanline
                                        my_threshold = color_detection_threshold;
                                } else {
                                        my_threshold = 0;
                                }
                        } else if (is_lock_colors == true) {
                                my_threshold = color_detection_threshold;
                        }

                        if (is_lock_colors == true) {
                                //use the color locked by mouseclick
                        } else {
                                color_to_feedback = get(mouseX, mouseY);
                        }

                        IntList detected_indices = scanline.check_this_color_palette(color_to_feedback, my_threshold);

                        noFill();
                        strokeWeight(2);
                        stroke(255);

                        for (int i=0; i<detected_indices.size (); i++) {

                                int index = detected_indices.get(i);

                                rect(checkbox_positions[index][0], checkbox_positions[index][1], 24, 24);
                        }
                }
        }

        void on_mouse_click() {
                switch(mouse_is_in) {
                        case(COL_1_SELECT_BOX):
                        enumerate_select_box_state(0);
                        is_ready_for_selection = true;
                        break;
                        case(COL_2_SELECT_BOX):
                        enumerate_select_box_state(1);
                        is_ready_for_selection = true;
                        break;
                        case(COL_3_SELECT_BOX):
                        enumerate_select_box_state(2);
                        is_ready_for_selection = true;
                        break;
                        case(COL_4_SELECT_BOX):
                        enumerate_select_box_state(3);
                        is_ready_for_selection = true;
                        break;
                        case(COL_5_SELECT_BOX):
                        enumerate_select_box_state(4);
                        is_ready_for_selection = true;
                        break;
                        case(COL_6_SELECT_BOX):
                        enumerate_select_box_state(5);
                        is_ready_for_selection = true;
                        break;
                        case(COL_7_SELECT_BOX):
                        enumerate_select_box_state(6);
                        is_ready_for_selection = true;
                        break;
                        case(COL_8_SELECT_BOX):
                        enumerate_select_box_state(7);
                        is_ready_for_selection = true;
                        break;
                        case(COL_9_SELECT_BOX):
                        enumerate_select_box_state(8);
                        is_ready_for_selection = true;
                        break;
                        case(COL_10_SELECT_BOX):
                        enumerate_select_box_state(9);
                        is_ready_for_selection = true;
                        break;
                        case(CAM_WINDOW):
                        is_lock_colors = !is_lock_colors;
                        if (is_lock_colors == true) color_to_feedback = get(mouseX, mouseY);
                        break;
                default: 
                        is_lock_colors = false;
                }
        }

        void enumerate_select_box_state(int index) {

                if (select_boxes_state[index] == EMPTY) {

                        //only one select box can be pending at any time
                        for (int i=0; i<NUM_TRACKS; i++) {
                                if (select_boxes_state[i] == PENDING) {
                                        select_boxes_state[i] = EMPTY;
                                }
                        }

                        select_boxes_state[index] = PENDING;
                } else if (select_boxes_state[index] == PENDING) {

                        select_boxes_state[index] = FULL;
                        is_lock_colors = false;//release the color lock at the palette
                } else if (select_boxes_state[index] == FULL) {

                        select_boxes_state[index] = EMPTY;
                        my_chosen_colors[index] = -1;
                }
        }

        int which_select_box_pending() { 

                int index = -1;

                for (int i=0; i<NUM_TRACKS; i++) {
                        if (select_boxes_state[i] == PENDING) {
                                index = i;
                        }
                }
                return index;
        }

        void set_sound_names(String _collection_name) {

                int index_offset = 0;

                if (_collection_name.equals("Pleasant")) { 
                        index_offset = 0;
                } else if (_collection_name.equals("Electronic")) {
                        index_offset = 10;
                } else if (_collection_name.equals("Nature")) {
                        index_offset = 20;
                } else if (_collection_name.equals("Comedy")) {
                        index_offset = 30;
                } else if (_collection_name.equals("Radio")) {
                        index_offset = 40;
                } else if (_collection_name.equals("Musical")) {
                        index_offset = 50;
                } else if (_collection_name.equals("")) {
                        index_offset = -1;
                }

                if (index_offset != -1) {
                        for (int i=0; i<10; i++) {
                                sound_names[i] = get_sound_name(i + index_offset);
                        }
                } else {
                        for (int i=0; i<10; i++) {
                                sound_names[i] = "";
                        }
                }
        }

        void show_sound_names() {

                fill(255);

                for (int i=0; i<NUM_TRACKS/2; i++) {
                        text(sound_names[i], 215+i*250, 125);
                        text(collection_name, 215+i*250, 95);
                }

                for (int j=NUM_TRACKS/2; j<NUM_TRACKS; j++) {
                        text(sound_names[j], 215+(j-5)*250, 215);
                        text(collection_name, 215+(j-5)*250, 185);
                }
        }

        void check_mouse_pos(int x, int y) {
                if (y >= 80 && y <= 105) {

                        if (x > 100 && x <= 150) {
                                mouse_is_in = COL_1_BOX; 
                                if (my_chosen_colors[0] != -1) is_show_color_feedback = true;
                        } else if (x > 150 && x <= 205) {
                                mouse_is_in = COL_1_SELECT_BOX; 
                                is_show_color_feedback = false;
                        } else if (x > 350 && x <= 400) {
                                mouse_is_in = COL_2_BOX; 
                                if (my_chosen_colors[1] != -1) is_show_color_feedback = true;
                        } else if (x > 400 && x <= 455) {
                                mouse_is_in = COL_2_SELECT_BOX; 
                                is_show_color_feedback = false;
                        } else if (x > 600 && x <= 650) {
                                mouse_is_in = COL_3_BOX;
                                if (my_chosen_colors[2] != -1) is_show_color_feedback = true;
                        } else if (x > 650 && x <= 705) {
                                mouse_is_in = COL_3_SELECT_BOX;
                                is_show_color_feedback = false;
                        } else if (x > 850 && x <= 900) {
                                mouse_is_in = COL_4_BOX;
                                if (my_chosen_colors[3] != -1) is_show_color_feedback = true;
                        } else if (x > 900 && x <= 955) {
                                mouse_is_in = COL_4_SELECT_BOX;
                                is_show_color_feedback = false;
                        } else if (x > 1100 && x <= 1150) {
                                mouse_is_in = COL_5_BOX;
                                if (my_chosen_colors[4] != -1) is_show_color_feedback = true;
                        } else if (x > 1150 && x <= 1205) {
                                mouse_is_in = COL_5_SELECT_BOX;
                                is_show_color_feedback = false;
                        } else {
                                mouse_is_in = NOWHERE_IMPT;
                                is_show_color_feedback = false;
                        }
                } else if (y > 170 && y <= 195) {

                        if (x > 100 && x <= 150) {
                                mouse_is_in = COL_6_BOX;
                                if (my_chosen_colors[5] != -1) is_show_color_feedback = true;
                        } else if (x > 150 && x <= 205) {
                                mouse_is_in = COL_6_SELECT_BOX; 
                                is_show_color_feedback = false;
                        } else if (x > 350 && x <= 400) {
                                mouse_is_in = COL_7_BOX;
                                if (my_chosen_colors[6] != -1) is_show_color_feedback = true;
                        } else if (x > 400 && x <= 455) {
                                mouse_is_in = COL_7_SELECT_BOX;
                                is_show_color_feedback = false;
                        } else if (x > 600 && x <= 650) {
                                mouse_is_in = COL_8_BOX;
                                if (my_chosen_colors[7] != -1) is_show_color_feedback = true;
                        } else if (x > 650 && x <= 705) {
                                mouse_is_in = COL_8_SELECT_BOX;
                                is_show_color_feedback = false;
                        } else if (x > 850 && x <= 900) {
                                mouse_is_in = COL_9_BOX;
                                if (my_chosen_colors[8] != -1) is_show_color_feedback = true;
                        } else if (x > 900 && x <= 955) {
                                mouse_is_in = COL_9_SELECT_BOX;
                                is_show_color_feedback = false;
                        } else if (x > 1100 && x <= 1150) {
                                mouse_is_in = COL_10_BOX;
                                if (my_chosen_colors[9] != -1) is_show_color_feedback = true;
                        } else if (x > 1150 && x <= 1205) {
                                mouse_is_in = COL_10_SELECT_BOX;
                                is_show_color_feedback = false;
                        } else {
                                mouse_is_in = NOWHERE_IMPT;
                                is_show_color_feedback = false;
                        }
                } else if (y > 335 && y <= 700) {

                        if (x > 100 && x < 580) {
                                mouse_is_in = CAM_WINDOW;
                                is_show_color_feedback = true;
                        } else {
                                mouse_is_in = NOWHERE_IMPT;
                                is_show_color_feedback = false;
                        }
                } else {

                        mouse_is_in = NOWHERE_IMPT;
                        is_show_color_feedback = false;
                }
        }

        String get_sound_name(int _index) { //add names for all 100 songs here
                switch(_index) {

                        case(0): 
                        return ("aurora bells");         
                        case(1): 
                        return ("aurora bells 2");        
                        case(2): 
                        return ("aurora chords");
                        case(3): 
                        return ("piano-do"); 
                        case(4): 
                        return ("piano-mi"); 
                        case(5): 
                        return ("piano-so"); 
                        case(6): 
                        return ("shimmer-do-mi"); 
                        case(7): 
                        return ("drums_2beats"); 
                        case(8): 
                        return ("drums_4beats"); 
                        case(9): 
                        return("tick_4beats"); 
                        case(10): 
                        return ("blibs"); 
                        case(11): 
                        return("cosmic"); 
                        case(12): 
                        return("dialogue"); 
                        case(13): 
                        return("droplets"); 
                        case(14): 
                        return("embers"); 
                        case(15): 
                        return("planets"); 
                        case(16): 
                        return("space"); 
                        case(17): 
                        return("star"); 
                        case(18): 
                        return("sunrise"); 
                        case(19): 
                        return("tick tock"); 
                        case(20): 
                        return("birds"); 
                        case(21): 
                        return("weird bird"); 
                        case(22): 
                        return("hyena"); 
                        case(23): 
                        return("dogs"); 
                        case(24): 
                        return("monkey"); 
                        case(25): 
                        return("water"); 
                        case(26): 
                        return("wave"); 
                        case(27): 
                        return("flutter"); 
                        case(28): 
                        return("insects"); 
                        case(29): 
                        return("drip"); 
                        case(30): 
                        return("awww"); 
                        case(31): 
                        return("yay"); 
                        case(32): 
                        return("party toy"); 
                        case(33): 
                        return("trumpet"); 
                        case(34): 
                        return("claps"); 
                        case(35): 
                        return("boing"); 
                        case(36): 
                        return("boing ting"); 
                        case(37): 
                        return("falling"); 
                        case(38): 
                        return("badumtss"); 
                        case(39): 
                        return("beats"); 
                        case(40): 
                        return("ufo"); 
                        case(41): 
                        return("alien music"); 
                        case(42): 
                        return("blitz"); 
                        case(43): 
                        return("long blitz"); 
                        case(44): 
                        return("dial dudut"); 
                        case(45): 
                        return("countdown"); 
                        case(46): 
                        return("hangup"); 
                        case(47): 
                        return("rhythmic melody"); 
                        case(48): 
                        return("siren horn"); 
                        case(49): 
                        return("speed"); 
                        case(50): 
                        return("beats"); 
                        case(51): 
                        return("beats 2"); 
                        case(52): 
                        return("dub horns"); 
                        case(53): 
                        return("electric lead"); 
                        case(54): 
                        return("electric piano"); 
                        case(55): 
                        return("flute"); 
                        case(56): 
                        return("organ"); 
                        case(57): 
                        return("piano"); 
                        case(58): 
                        return("sax"); 
                        case(59): 
                        return("trumpet"); 
                default: 
                        return ("song" + _index);
                }
        }
}

