import controlP5.*;

class GUI {

        CheckBox[] checkboxes;
        int[][] checkbox_positions;
        IntList chosen_colors_indices;

        MultiList ml1, ml2, ml3, ml4, ml5, ml6, ml7, ml8, ml9, ml10;
        Button play_button;

        String[] sound_names;

        PApplet p;

        ControlP5 cp5;

        GUI(PApplet parent) {

                p = parent;

                cp5 = new ControlP5(p);

                checkboxes = new CheckBox[117];
                checkbox_positions = new int[117][2];
                chosen_colors_indices = new IntList();

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
                        sound_names[i] = "no sound selected";
                }

                //play button
                play_button = cp5.addButton("play_stop")
                        .setPosition(1320, 260)
                                .setColorBackground(color(0, 255, 0)) 
                                        .setSize(50, 50)
                                                ;

                cp5.getController("play_stop").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(2);
        }

        void add_level_one_buttons(MultiList ml, int _index_ml) {

                MultiListButton b;

                b = ml.add("pick_sound " + (_index_ml+1), _index_ml);

                MultiListButton c;

                for (int index_collection=0; index_collection<NUM_TRACKS; index_collection++) {

                        String indexS = Integer.toString(_index_ml) + Integer.toString(index_collection) + ".0";
                        float index_ml_collection = Float.valueOf(indexS).floatValue();

                        c = b.add("collect_" + _index_ml + index_collection, int(index_ml_collection));

                        switch(index_collection) {
                                case(0):
                                c.setLabel("classical");
                                break;
                                case(1):
                                c.setLabel("pop rock");
                                break;
                                case(2):
                                c.setLabel("techno");
                                break;
                                case(3):
                                c.setLabel("trance");
                                break;
                                case(4):
                                c.setLabel("movie sounds");
                                break;
                                case(5):
                                c.setLabel("reggae");
                                break;
                                case(6):
                                c.setLabel("choral");
                                break;
                                case(7):
                                c.setLabel("piano");
                                break;
                                case(8):
                                c.setLabel("orchestral");
                                break;
                                case(9):
                                c.setLabel("electronic");
                                break;
                        }                 
                        c.setHeight(15);
                        c.setColorBackground(color(64 + 18*index_collection, 0, 0));

                        for (int index_sound=0; index_sound<NUM_TRACKS; index_sound++) {
                                add_level_two_buttons(c, _index_ml, index_collection, index_sound);
                        }
                }

                //add NONE button
                String indexS = Integer.toString(_index_ml) + Integer.toString(10) + ".0";
                float index_ml_collection = Float.valueOf(indexS).floatValue();

                c = b.add("none_" + _index_ml + 10, int(index_ml_collection));
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
                        for (int i=0; i<chosen_colors.size (); i++) {
                                color c = color(chosen_colors.get(i)); 
                                fill(c); 
                                noStroke(); 
                                rect(100+i*250, yPos, 50, 25);
                        }
                }

                for (int j=0; j<NUM_TRACKS/2; j++) {
                        noFill(); 
                        stroke(150); 
                        rect(100+j*250, yPos, 50, 25);
                }

                for (int j=0; j<NUM_TRACKS/2; j++) {
                        noFill(); 
                        stroke(150); 
                        rect(100+j*250, yPos+yOffset, 50, 25);
                }

                //show feedback on which colors were chosen
                for (int k=0; k<chosen_colors_indices.size (); k++) {
                        int chosen_color_index = chosen_colors_indices.get(k);
                        color c = chosen_colors.get(k);
                        fill(c);
                        int checkbox_xPos = checkbox_positions[chosen_color_index][0];
                        int checkbox_yPos = checkbox_positions[chosen_color_index][1];
                        rect(checkbox_xPos, checkbox_yPos, 24, 24);
                }
        }

        void show_sound_names() {

                fill(255);

                for (int i=0; i<NUM_TRACKS/2; i++) {
                        text(sound_names[i], 160+i*250, 95);
                }

                for (int j=NUM_TRACKS/2; j<NUM_TRACKS; j++) {
                        text(sound_names[j], 160+(j-5)*250, 185);
                }
        }

        void show_color_feedback() {
                //show detected colors as mouse hovers   

                int my_threshold = 0;

                if (mouseX > 100 && mouseX < 100+cam.width && mouseY > 335 && mouseY < 335+cam.height) { //same translation as scanline
                        my_threshold = color_detection_threshold;
                } else {
                        my_threshold = 0;
                }

                IntList detected_indices = scanline.check_this_color_palette(color_at_cursor, my_threshold);

                noFill();
                strokeWeight(2);
                stroke(255);

                for (int i=0; i<detected_indices.size (); i++) {

                        int index = detected_indices.get(i);

                        rect(checkbox_positions[index][0], checkbox_positions[index][1], 24, 24);
                }
        }

        String get_sound_name(int _index) { //add names for all 100 songs here
                switch(_index) {
                default:
                        return ("song" + _index);
                }
        }
}

