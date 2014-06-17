public class ControlFrame extends Frame {

        SecondApplet papplet; 

        public ControlFrame (String title, int w, int h) {
                papplet = new SecondApplet();
                papplet.frame = this;
                setResizable(false);
                setUndecorated(false); //set to true at Science Centre
                setTitle(title);
                
                setLocation(1200, 200); 

                papplet.resize(w, h);
                papplet.setPreferredSize(new Dimension(w, h));
                papplet.setMinimumSize(new Dimension(w, h));

                add(papplet);
                papplet.init();
                pack();
                setVisible(true);
                //show();
        }
}       




