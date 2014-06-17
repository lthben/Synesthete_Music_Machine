import controlP5.*;

ControlP5 cp5;

class GUI {

        CheckBox[] checkboxes;
        IntList color_palette; //use IntList to access shuffle() function. Contains 125 colors (5x5x5) RGB individual components 64 apart, i.e. 0, 63, 127, 191, 255 
        private ControlP5 cp5;

        GUI(ControlP5 _cp5) {
                cp5 = _cp5;

                checkboxes = new CheckBox[125];

                init_color_palette();

                set_up_palette();
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

                color_palette.shuffle(); //randomize the order
        }

        void set_up_palette() {
                int counter = 0;

                for (int yPos=height-100; yPos<height; yPos+=25) {
                        for (int xPos=25; xPos<width-50; xPos+=25) {

                                if (counter < 125) {
                                        checkboxes[counter] = cp5.addCheckBox("checkBox" + counter)
                                                .setPosition(xPos, yPos)
                                                        . setColorForeground(color(120))
                                                                .setColorActive(color(255))
                                                                        .setColorBackground(color_palette.get(counter))
                                                                                .setSize(25, 25)
                                                                                        .addItem("color" + counter, color_palette.get(counter))
                                                                                                .hideLabels()
                                                                                                        ;              
                                        counter++;
                                }
                        }
                }
        }
}

