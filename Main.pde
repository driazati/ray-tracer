// This is the starter code for the CS 3451 Ray Tracing project.
// The most important part of this code is the interpreter, which will
// help you parse the scene description (.cli) files.

// A global variable for holding current active file name.
// By default, the program reads in i0.cli, which draws a rectangle.
String gCurrentFile = new String("i0.cli");

Scene scene;
int vertex_count;
float[][] vertex_buffer;

void setup() {
    size(300, 300);  
    noStroke();
    colorMode(RGB, 1.0);
    background(0, 0, 0);
    scene = new Scene(new Vector(0, 0, 0));
    interpreter();
    vertex_count = 0;
    vertex_buffer = new float[2][3];
}

void reset_scene() {
    scene = new Scene(new Vector(0, 0, 0));
}

void keyPressed() {
    reset_scene();
    switch(key) {
        case '1':  gCurrentFile = new String("i1.cli"); interpreter(); break;
        case '2':  gCurrentFile = new String("i2.cli"); interpreter(); break;
        case '3':  gCurrentFile = new String("i3.cli"); interpreter(); break;
        case '4':  gCurrentFile = new String("i4.cli"); interpreter(); break;
        case '5':  gCurrentFile = new String("i5.cli"); interpreter(); break;
        case '6':  gCurrentFile = new String("i6.cli"); interpreter(); break;
        case '7':  gCurrentFile = new String("i7.cli"); interpreter(); break;
        case '8':  gCurrentFile = new String("i8.cli"); interpreter(); break;
        case '9':  gCurrentFile = new String("i9.cli"); interpreter(); break;
        case '0':  gCurrentFile = new String("i10.cli"); interpreter(); break;
    }
}

float get_float(String str) { return float(str); }

// this routine helps parse the text in a scene description file
void interpreter() {
    println("Parsing '" + gCurrentFile + "'");
    String str[] = loadStrings(gCurrentFile);
    
    if (str == null) {
        println("Error! Failed to read the file.");
    }

    scene = new Scene(new Vector(0, 0, 0));

    for (int i = 0; i < str.length; i++) {
        String[] token = splitTokens(str[i], " "); // Get a line and parse tokens.
        if (token.length == 0) continue; // Skip blank line.
        
        if (token[0].equals("fov")) {
            float fov =  get_float(token[1]);
            scene.setFOV(fov);
        }
        else if (token[0].equals("background")) {
            float r = get_float(token[1]);
            float g = get_float(token[2]);
            float b = get_float(token[3]);
            scene.background = new Color(r, g, b);
        }
        else if (token[0].equals("light")) {
            float x = get_float(token[1]);
            float y = get_float(token[2]);
            float z = get_float(token[3]);
            float r = get_float(token[4]);
            float g = get_float(token[5]);
            float b = get_float(token[6]);
            scene.lights.add(new Light(new Vector(x, y, z), new Color(r, g, b)));
        }
        else if (token[0].equals("surface")) {
            float Cdr = get_float(token[1]);
            float Cdg = get_float(token[2]);
            float Cdb = get_float(token[3]);
            float Car = get_float(token[4]);
            float Cag = get_float(token[5]);
            float Cab = get_float(token[6]);
            float Csr = get_float(token[7]);
            float Csg = get_float(token[8]);
            float Csb = get_float(token[9]);
            float P = get_float(token[10]);
            float K = get_float(token[11]);

            Color diff = new Color(Cdr, Cdg, Cdb);
            Color amb = new Color(Car, Cag, Cab);
            Color spec = new Color(Csr, Csg, Csb);

            Material material = new Material(diff, amb, spec, P, K);
            scene.lastMaterial = material;
        }    
        else if (token[0].equals("sphere")) {
            float r = get_float(token[1]);
            float x = get_float(token[2]);
            float y = get_float(token[3]);
            float z = get_float(token[4]);
            scene.addShape(new Sphere(r, new Vector(x, y, z)));
        }
        else if (token[0].equals("begin")) {
            vertex_count = 0;
            vertex_buffer = new float[2][3];
        }
        else if (token[0].equals("vertex")) {
            float x = get_float(token[1]);
            float y = get_float(token[2]);
            float z = get_float(token[3]);
            if (vertex_count == 2) {
                Triangle triangle = new Triangle(
                        new Vector(x, y, z),
                        new Vector(vertex_buffer[0][0], vertex_buffer[0][1], vertex_buffer[0][2]),
                        new Vector(vertex_buffer[1][0], vertex_buffer[1][1], vertex_buffer[1][2])
                    );
                scene.addShape(triangle);
            } else {
                vertex_buffer[vertex_count][0] = x;
                vertex_buffer[vertex_count][1] = y;
                vertex_buffer[vertex_count][2] = z;
            }

            vertex_count++;
        }
        else if (token[0].equals("end")) {

        }
        else if (token[0].equals("rect")) {   // this command demonstrates how the parser works
            float x = get_float(token[1]);       // and is not really part of the ray tracer
            float y = get_float(token[2]);
            float w = get_float(token[3]);
            float h = get_float(token[4]);
            fill (255, 255, 255);  // make the fill color white
            rect (x, y, w, h);     // draw a rectangle on the screne
        }
        else if (token[0].equals("write")) {
            draw_scene();   // this is where you actually perform the ray tracing
            println("Saving image to '" + token[1] + "'");
            save(token[1]); // this saves your ray traced scene to a PNG file
        }
    }
}
int xdebug = 0, ydebug = 0;
void mousePressed() {
    // println("Mouse X: " + mouseX + " Y: " + mouseY);
    xdebug = mouseX;
    ydebug = mouseY;
    draw_scene();
}

boolean print;

// This is where you should put your code for creating
// eye rays and tracing them.
void draw_scene() {
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            if (y == 143 && x == 113) {
                print = true;
            } else {
                print = false;
            }
            // scene.x = x;
            // scene.y = y;
            Ray eyeRay = scene.getRayThroughPixel(x, y);
            Hit closestHit = scene.closestHit(eyeRay);
            color col = scene.shade(closestHit, 0).getColor();

            fill(col);     // you should put the correct pixel color here
            rect(x, y, 1, 1);  // make a tiny rectangle to fill the pixel
            print = false;
        }
    }
}

void draw() {
    // nothing should be placed here for this project
}