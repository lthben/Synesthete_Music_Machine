import controlP5.*;

ControlP5 cp5;
CheckBox[] checkboxes;

public class SecondApplet extends PApplet {

        IntList color_palette; //use IntList to access shuffle() function. Contains 125 colors (5x5x5) RGB individual components 64 apart, i.e. 0, 63, 127, 191, 255 

        public void setup() {

                size(640, 480);

                frameRate(5);

                cp5 = new ControlP5(this);

                checkboxes = new CheckBox[125];

                init_color_palette();

                set_up_palette();
        }



        public void draw() {

                background(0);
        }

        void init_color_palette() {

                color_palette = new IntList();

                for (int red=0; red<256; red+= (red==0? 63: 64)) {
                        for (int green=0; green<256; green+= (green==0? 63: 64)) {
                                for (int blue=0; blue<256; blue+= (blue==0? 63: 64)) {
                                        color_palette.append(color(red, green, blue));
                                        //println(red(color_palette[index]) + "," + green(color_palette[index]) + "," + blue(color_palette[index]));
                                }
                        }
                }

                color_palette.shuffle();
        }

        void set_up_palette() {
                int counter = 0;

                for (int yPos=30; yPos<height; yPos+=30) {
                        for (int xPos=20; xPos<width-30; xPos+=30) {

                                if (counter < 125) {
                                        checkboxes[counter] = cp5.addCheckBox("checkBox" + counter)
                                                .setPosition(xPos, yPos)
                                                        . setColorForeground(color(120))
                                                                .setColorActive(color(255))
                                                                        .setColorBackground(color_palette.get(counter))
                                                                                .setSize(30, 30)
                                                                                        .addItem("color" + counter, color_palette.get(counter))
                                                                                                .hideLabels()
                                                                                                        ;              
                                        counter++;
                                }
                        }
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
}

