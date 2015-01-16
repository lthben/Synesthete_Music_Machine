/**
 * Author:         Benjamin Low (Lthben@gmail.com)
 * Date:           June-July 2014
 * Description:    A fun application for SMMF14 that takes the image seen by a webcam, 
 *                 processes the color data and sends out the result 
 *                 to another program that converts the data into sound  
 */

import processing.video.*;

Capture cam;
ScanLine scanline;
GUI my_GUI;

OscP5 oscP5;
NetAddress myRemoteLocation;

//user defined parameters
int play_dur; //in milliseconds, can range from 1 second onwards 
int color_detection_threshold; //sensitivity to detection, should be in range 1 to 50 whereabouts

//IntList chosen_colors; //user chosen colors
int[] my_chosen_colors; //improved version 2 - static array

int[] chosen_sounds;

final int NUM_TRACKS = 10; //maximum number of sound tracks 

int cursor_mode;
final int SHOW_COLOR = 1, SHOW_COORD = 2, CURSOR_OFF = 3;
color color_at_cursor;

color[] color_palette;

void setup() {
        size(1440, 720, P2D); //1440 x 900 

        frameRate(10);

        cursor_mode = CURSOR_OFF;

        //chosen_colors = new IntList();
        my_chosen_colors = new int[NUM_TRACKS];
        for (int i=0; i<NUM_TRACKS; i++) {
                 my_chosen_colors[i] = -99;       
        }

        chosen_sounds = new int[NUM_TRACKS];

        for (int i=0; i<NUM_TRACKS; i++) {
                chosen_sounds[i] = -1;
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

                // cam = new Capture(this, cameras[0]);
//                cam = new Capture(this, 480, 360, 15); //can set fps here too
                cam = new Capture(this, 480, 360, "HD Pro Webcam C920", 10);

                cam.start();
        }

        scanline = new ScanLine();

        my_GUI = new GUI(this);

        oscP5 = new OscP5(this, 12000);
        myRemoteLocation = new NetAddress("127.0.0.1", 12001);
}

void draw() {

        background(0);

        if (cam.available() == true) {
                cam.read();
        }

        cam.loadPixels();

        //mirror image
        pushMatrix();
        scale(-1, 1);
        //tint(255, 50);
        imageMode(CENTER);
        pushMatrix();
        translate(380, 0);
        image(cam, -width/2, 335+cam.height/2);
        popMatrix();
        popMatrix();

        scanline.show_frame_crop();

        pushMatrix();
        translate(100, 335);
        if ( scanline.is_playing ) { 
                scanline.run();
        }
        popMatrix();

        my_GUI.check_mouse_pos(mouseX, mouseY);
        my_GUI.show_chosen_colors();
        my_GUI.show_sound_names();
        my_GUI.show_color_feedback();
        my_GUI.run_select_boxes();
        my_GUI.show_boundary_boxes();

        run_cursor();

        show_running_time();
}

void run_cursor() {

        color_at_cursor = get(mouseX, mouseY);

        fill(255);
        textSize(12);

        if (cursor_mode == SHOW_COLOR) {
                text(red(color_at_cursor)+","+green(color_at_cursor)+","+blue(color_at_cursor), mouseX + 3, mouseY - 3);
        } else if (cursor_mode == SHOW_COORD) {
                text(mouseX + ", " + mouseY, mouseX, mouseY);
        } else {
                //turn off
        }
}


void show_running_time() {
        fill(255, 255);
        textSize(14);
        //text("time: " + millis()/1000, width - 150, 50);
        //text("mouse pos: " + my_GUI.mouse_is_in, width-150, 50);
        //text("is_lock_colors: " + my_GUI.is_lock_colors, width-150, 50);
}

void keyPressed() {
        if (key == 'f') {
                println("Framerate: " + frameRate);
        }
        if (key == '1') {
                cursor_mode = SHOW_COLOR;
        } else if (key == '2') {
                cursor_mode = SHOW_COORD;
        } else if (key == '3') {
                cursor_mode = CURSOR_OFF;
        }
}


void controlEvent(ControlEvent theEvent) {

        String myString = (String)theEvent.getName();
        //println(myString);

        //OscMessage select_sound_msg = new OscMessage("/channel/sound");
        OscMessage select_collection_msg = new OscMessage("/collection");
        OscMessage select_preview_msg = new OscMessage("/preview");

        if (myString.contains("checkBox")) {

                if (my_GUI.is_ready_for_selection == true) {

                        String the_color_index_string = myString.replace("checkBox", "");
                        int the_color_index_int = int(the_color_index_string);
                        //println(the_color_index_int);

                        int the_pending_channel = my_GUI.which_select_box_pending();

                        my_chosen_colors[the_pending_channel] = color_palette[the_color_index_int];
                        my_GUI.my_chosen_colors_indices[the_pending_channel] = the_color_index_int;

                        my_GUI.is_ready_for_selection = false;
                        my_GUI.select_boxes_state[the_pending_channel] = my_GUI.FULL;
                        /***
                         if ( chosen_colors.hasValue(color_palette[the_color_index_int]) ) {
                         
                         for (int i=0; i<chosen_colors.size (); i++) { 
                         
                         //println("equals");
                         //  println("palette: " + color_palette.get(the_color_index_int));
                         // println("chosen: " + chosen_colors.get(i));
                         
                         if ( color_palette[the_color_index_int] == chosen_colors.get(i) ) {
                         
                         chosen_colors.remove(i);
                         my_GUI.chosen_colors_indices.remove(i);
                         }
                         }
                         } else if ( chosen_colors.size() < NUM_TRACKS ) { 
                         chosen_colors.append(color_palette[the_color_index_int]);
                         my_GUI.chosen_colors_indices.append(the_color_index_int);
                         }
                         ***/
                        //println(my_GUI.chosen_colors_indices);
                }
        } 
        /**
         else if (myString.contains("song")) {
         float the_value_f = theEvent.value();
         int the_value = int(the_value_f);
         //String the_value_s = str(the_value);
         //println(myString);
         //println(theEvent.controller().name()+" = "+theEvent.value());
         //println(the_value);
         
         if ( the_value < 100 ) {
         chosen_sounds[0] = the_value;
         my_GUI.sound_names[0] = my_GUI.get_sound_name(the_value);
         select_sound_msg.add(0);
         } else if ( the_value < 200 ) {
         chosen_sounds[1] = the_value;
         the_value -= 100;
         my_GUI.sound_names[1] = my_GUI.get_sound_name(the_value);
         select_sound_msg.add(1);
         } else if ( the_value < 300 ) {
         chosen_sounds[2] = the_value;
         the_value -= 200;
         my_GUI.sound_names[2] = my_GUI.get_sound_name(the_value);
         select_sound_msg.add(2);
         } else if ( the_value < 400 ) {
         chosen_sounds[3] = the_value;
         the_value -= 300;
         my_GUI.sound_names[3] = my_GUI.get_sound_name(the_value);
         select_sound_msg.add(3);
         } else if ( the_value < 500 ) {
         chosen_sounds[4] = the_value;
         the_value -= 400;
         my_GUI.sound_names[4] = my_GUI.get_sound_name(the_value);
         select_sound_msg.add(4);
         } else if ( the_value < 600 ) {
         chosen_sounds[5] = the_value;
         the_value -= 500;
         my_GUI.sound_names[5] = my_GUI.get_sound_name(the_value);
         select_sound_msg.add(5);
         } else if ( the_value < 700 ) {
         chosen_sounds[6] = the_value;
         the_value -= 600;
         my_GUI.sound_names[6] = my_GUI.get_sound_name(the_value);
         select_sound_msg.add(6);
         } else if ( the_value < 800 ) {
         chosen_sounds[7] = the_value;
         the_value -= 700;
         my_GUI.sound_names[7] = my_GUI.get_sound_name(the_value);
         select_sound_msg.add(7);
         } else if ( the_value < 900 ) {
         chosen_sounds[8] = the_value;
         the_value -= 800;
         my_GUI.sound_names[8] = my_GUI.get_sound_name(the_value);
         select_sound_msg.add(8);
         } else if ( the_value < 1000 ) {
         chosen_sounds[9] = the_value;
         the_value -= 900;
         my_GUI.sound_names[9] = my_GUI.get_sound_name(the_value);
         select_sound_msg.add(9);
         } 
         
         select_sound_msg.add(the_value);
         oscP5.send(select_sound_msg, myRemoteLocation);
         
         for (int i = 0; i<NUM_TRACKS; i++) {
         //println("sound " + (i+1) + ": " + chosen_sounds[i]);
         }
         } 
         **/
        else if (myString.contains("collect_")) { //collections 0 - 5
                myString = myString.substring(9, myString.length());
                int which_collection = Integer.parseInt(myString);

                select_collection_msg.add(which_collection);
                oscP5.send(select_collection_msg, myRemoteLocation);

                //                println("collection selected " + which_collection);

                switch(which_collection) {
                        case(0): 
                        my_GUI.collection_name = "Pleasant"; 
                        break;
                        case(1): 
                        my_GUI.collection_name = "Electronic"; 
                        break;
                        case(2): 
                        my_GUI.collection_name = "Nature"; 
                        break;
                        case(3): 
                        my_GUI.collection_name = "Comedy"; 
                        break;
                        case(4): 
                        my_GUI.collection_name = "Radio"; 
                        break;
                        case(5): 
                        my_GUI.collection_name = "Musical"; 
                        break;
                        case(6): 
                        my_GUI.collection_name = "Spongebob"; 
                        break;
                        case(7): 
                        my_GUI.collection_name = "Adventure_Time"; 
                        break;
                }
                my_GUI.set_sound_names(my_GUI.collection_name);
        } else if (myString.contains("bang")) {

                myString = myString.substring(4, myString.length());
                int which_bang = Integer.parseInt(myString); //0-9

                select_preview_msg.add(which_bang);
                oscP5.send(select_preview_msg, myRemoteLocation);
        } else if (myString.contains("none")) {
                /**
                 float the_value_f = theEvent.value();
                 int the_value = int(the_value_f);    
                 //println("event: " + myString + " value: " + the_value);
                 
                 String channel_c = myString.substring(5, 6);
                 //float channel_f = Float.valueOf(channel_c).floatValue();
                 int channel = int(channel_c);
                 
                 //println("channel: " + channel);
                 
                 chosen_sounds[channel] = -1;
                 my_GUI.sound_names[channel] = "no sound selected";
                 
                 select_sound_msg.add(channel);
                 select_sound_msg.add(-1);
                 oscP5.send(select_sound_msg, myRemoteLocation);
                 **/
                select_collection_msg.add(-1);
                oscP5.send(select_collection_msg, myRemoteLocation);

                my_GUI.collection_name = "";
                my_GUI.set_sound_names("");
        }
}


void oscEvent(OscMessage theOscMessage) {
        if (theOscMessage.checkAddrPattern("/channel/sound")==true) {
                /* check if the typetag is the right one. */
                if (theOscMessage.checkTypetag("ii")) {
                        /* parse theOscMessage and extract the values from the osc message arguments. */
                        int channel = theOscMessage.get(0).intValue();  
                        int sound = theOscMessage.get(1).intValue();
                        //float secondValue = theOscMessage.get(1).floatValue();
                        //String thirdValue = theOscMessage.get(2).stringValue();
                        //print("### received an osc message /test with typetag ifs.");
                        //println(" values: "+firstValue+", "+secondValue+", "+thirdValue);
                        print("channel: " + channel + " sound: " + sound);
                } 
                //print("### received an osc message.");
                //print(" addrpattern: "+theOscMessage.addrPattern());
                //println(" typetag: "+theOscMessage.typetag());
        } else if (theOscMessage.checkAddrPattern("/preview")==true) {
                if (theOscMessage.checkTypetag("i")) {
                        int preview_channel = theOscMessage.get(0).intValue();
                        println("previewing: " + preview_channel);
                }
        } else if (theOscMessage.checkAddrPattern("/channel/pitch/volume")==true) {
                if (theOscMessage.checkTypetag("iff")) {
                        int the_channel = theOscMessage.get(0).intValue();
                        float the_pitch = theOscMessage.get(1).floatValue();
                        float the_volume = theOscMessage.get(2).floatValue();
                        println("channel: " + the_channel + " pitch: " + the_pitch + " volume: " + the_volume);
                }
        }
}

void play_stop() {
        OscMessage play_msg = new OscMessage("/play");


        if (scanline.is_playing) {
                my_GUI.play_button.setColorBackground(color(0, 255, 0));
                play_msg.add(0);
        } else {
                my_GUI.play_button.setColorBackground(color(255, 0, 0));
                play_msg.add(1);
        }
        scanline.is_playing = !scanline.is_playing;
        oscP5.send(play_msg, myRemoteLocation);
}

void play_duration(float theDur) {
        play_dur = int(theDur)*1000;
}


void color_detection_threshold(float theValue) {
        color_detection_threshold = int(theValue);
}


void frame_crop(float theValue) {
        scanline.crop_amount = theValue;
}

void mouseClicked() {
        my_GUI.on_mouse_click();
}

