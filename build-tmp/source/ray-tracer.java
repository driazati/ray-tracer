import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class ray-tracer extends PApplet {

class Color {
    float r, g, b;
    public Color(float r, float g, float b) {
        this.r = r;
        this.g = g;
        this.b = b;
    }

    public Color scale(float scale) {
        return new Color(this.r * scale, this.g * scale, this.b * scale);
    }

    public Color add(Color b) {
        return new Color(this.r + b.r, this.g + b.g, this.b + b.b);
    }

    public Color multiply(Color b) {
        return new Color(this.r * b.r, this.g * b.g, this.b * b.b);
    }

    public String toString() {
        return String.format("R: %f, G: %f, B: %f", r, g, b);
    }

    public int getColor() {
        return color(r, g, b);
    }
}
class Hit {
    float t;
    Vector position;
    Shape3D hitObject;
    Vector normal;
    Ray ray;
    static final float EPSILON = 0.001f;

    public Hit(float t, Vector position, Shape3D hitObject, Vector normal, Ray ray) {
        this.t = t;
        this.position = position.copy();
        this.hitObject = hitObject;
        this.normal = normal.normalize();
        this.ray = ray;
    }

    public boolean close(Hit b) {
        return (this.position.x - b.position.x < EPSILON) &&
               (this.position.y - b.position.y < EPSILON) &&
               (this.position.z - b.position.z < EPSILON);
    }

    public String toString() {
        return String.format("Pos: %s,  t: %f, hit: %s", position, t, hitObject);
    }
}
class Light {
    Color col;
    Vector position;

    public Light(Vector position, Color col) {
        this.col = col;
        this.position = position;
    }
}
class Material {
    Color diffuse;
    Color ambient;
    Color specular;
    float phong;
    float krefl;
    public Material(Color diffuse, Color ambient, Color specular, float phong, float krefl) {
        this.diffuse = diffuse;
        this.ambient = ambient;
        this.specular = specular;
        this.phong = phong;
        this.krefl = krefl;
    }
}
class Ray {
    Vector origin;
    Vector direction;

    public Ray(Vector origin, Vector direction) {
        this.origin = origin.copy();
        this.direction = direction.normalize();
    }
}
class Scene {
    Vector eye;
    ArrayList<Shape3D> shapes;
    ArrayList<Light> lights;
    float fov;
    float k;
    Color background;
    Material lastMaterial;
    static final int REFLECTIONS = 50;

    public Scene(Vector eye) {
        setFOV(60);
        this.background = new Color(0, 0, 0);
        this.eye = eye;
        lights = new ArrayList<Light>();
        shapes = new ArrayList<Shape3D>();
    }

    public void addShape(Shape3D shape) {
        shape.setMaterial(lastMaterial);
        this.shapes.add(shape);
    }

    public void setFOV(float fov) {
        this.fov = fov;
        this.k = tan(radians(fov / 2));
    }

    public Ray getRayThroughPixel(int x, int y) {
        Vector pixel = new Vector(0, 0, 0);
        pixel.x = (x - width / 2) * 2 * this.k / width;

        pixel.y = -(y - height / 2) * 2 * this.k / height;
        pixel.z = -1;

        float dx = pixel.x - eye.x;
        float dy = pixel.y - eye.y;
        float dz = pixel.z - eye.z;
        Vector dir = new Vector(dx, dy, dz);
        return new Ray(eye, dir.normalize());
    }

    public Hit closestHit(Ray ray) {
        Hit closest = null;

        for (Shape3D shape : shapes) {
            Hit newHit = shape.intersect(ray);
            
            if (newHit != null) {
                if (closest == null) {
                    closest = newHit;
                } else if (newHit.t < closest.t - EPSILON) {
                    closest = newHit;
                }
            }

        }

        return closest;
    }
    
    public boolean visible(Light light, Hit hit) {
        Vector dir = hit.position.subtract(light.position).normalize();
        Ray lightRay = new Ray(
            light.position,
            dir
        );

        Hit lightHit = closestHit(lightRay);

        return (lightHit != null && lightHit.close(hit));
    }

    public Color shade(Hit hit, int depth) {
        if (hit == null) {
            return this.background;
        }

        Material mat = hit.hitObject.getMaterial();
        Color fc = mat.ambient;

        Vector v = this.eye.subtract(hit.position).normalize();

        for (Light light : this.lights) {
            //Shadows
            if (!visible(light, hit)) {
                continue;
            }

            //Diffuse
            Vector l = light.position.subtract(hit.position).normalize();
            float scale = hit.normal.dot(l);
            scale = max(0, scale);
            Color diffuse = mat.diffuse.multiply(light.col.scale(scale));

            //Specular
            Vector s = light.position.subtract(hit.position).normalize();
            Vector h = s.add(v).normalize();
            float p = pow(max(0, h.dot(hit.normal)), mat.phong);

            //k_s * I * max(0, n dot h)^p
            Color specular = new Color(0, 0, 0);
            specular = mat.specular.multiply(light.col).scale(p);

            fc = fc.add(specular).add(diffuse);
        }

        //Reflections
        Color reflect = new Color(0, 0, 0);
        if (depth < REFLECTIONS && mat.krefl > 0) {
            Vector d = hit.position.subtract(hit.ray.origin);
            Vector norm = hit.normal.normalize();

            Vector reflectDir = d.subtract(norm.scale(2 * norm.dot(d))).normalize();

            Ray reflectRay = new Ray(hit.position, reflectDir);

            Hit reflectHit = closestHit(reflectRay);
            if (reflectHit == null) {
                reflect = this.background.scale(mat.krefl);
            } else {
                reflect = shade(reflectHit, depth + 1).scale(mat.krefl);
            }
        }

        fc = fc.add(reflect);
        return fc;
    }
}
interface Shape3D {
    public Material getMaterial();
    public void setMaterial(Material material);
    public Hit intersect(Ray ray);
    public Vector getPosition();
}
class Sphere implements Shape3D {
    float radius;
    Vector center;
    Material material;
    static final float EPSILON = 0.0001f;

    public Sphere(float radius, Vector center) {
        this.radius = radius;
        this.center = center;
        this.material = null;
    }

    public Vector getPosition() {
        return this.center;
    }

    public void setMaterial(Material material) {
        this.material = material;
    }

    public Material getMaterial() {
        return this.material;
    }

    public Hit intersect(Ray ray) {
        //discriminant
        Vector l = ray.origin.subtract(this.center);

        float a = ray.direction.dot(ray.direction);
        float b = 2.0f * ray.direction.dot(l);
        float c = l.dot(l) - radius * radius;
        float disc = (b * b - 4.0f * a * c);

        float t = 0;

        if (disc < 0) {
            //no intersection
            return null;
        } else if (disc == 0) {
            //tangent
            t = -0.5f * b / a;
        } else {
            //2 hits
            float t0 = -0.5f * (b + sqrt(disc)) / a;
            float t1 = -0.5f * (b - sqrt(disc)) / a;

            if (t0 < EPSILON || t1 < EPSILON) {
                return null;
            }

            t = (t0 < t1) ? t0 : t1;
        }

        Vector position = ray.origin.add(ray.direction.scale(t));
        Vector normal = position.subtract(this.center).normalize();

        return new Hit(t, position, this, normal, ray);
    }
}
class Triangle implements Shape3D {
    Material material;
    Vector a, b, c;

    public Triangle(Vector a, Vector b, Vector c) {
        this.a = a;
        this.b = b;
        this.c = c;
    }

    public Vector getPosition() {
        return this.a;
    }

    public Material getMaterial() {
        return this.material;
    }

    public void setMaterial(Material material) {
        this.material = material;
    }

    public Hit intersect(Ray ray) {
        float epsilon = 0.001f;

        Vector edge1 = this.b.subtract(this.a);
        Vector edge2 = this.c.subtract(this.a);

        Vector p = ray.direction.cross(edge2);

        float determinant = edge1.dot(p);

        if (determinant > -epsilon && determinant < epsilon) {
            return null;
        }

        float inverseDet = 1.0f / determinant;
        Vector T = ray.origin.subtract(this.a);
        float u = T.dot(p) * inverseDet;

        if (u < 0 || u > 1) {
            return null;
        }

        Vector q = T.cross(edge1);

        float v = ray.direction.dot(q) * inverseDet;
        if (v < 0 || u + v > 1) {
            return null;
        }

        float t = edge2.dot(q) * inverseDet;

        if (t > epsilon) {
            Vector position = ray.origin.add(ray.direction.scale(t));
            Vector norm = edge2.cross(edge1).normalize();
            return new Hit(t, position, this, norm, ray);
        }

        return null;
    }
}
class Vector {
    public float x;
    public float y;
    public float z;

    public Vector(float x, float y, float z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public Vector copy() {
        return new Vector(this.x, this.y, this.z);
    }

    public float dot(Vector b) {
        return (this.x * b.x + this.y * b.y + this.z * b.z);
    }

    public Vector normalize() {
        float magnitude = sqrt(x * x + y * y + z * z);
        return new Vector(this.x / magnitude,
            this.y / magnitude,
            this.z / magnitude);
    }

    public void negate() {
        this.x = -this.x;
        this.y = -this.y;
        this.z = -this.z;
    }

    public Vector scale(float scalar) {
        return new Vector(this.x * scalar, this.y * scalar, this.z * scalar);
    }

    public Vector cross(Vector b) {
        return new Vector(
            this.y * b.z - this.z * b.y,
            this.z * b.x - this.x * b.z,
            this.x * b.y - this.y * b.x
        );
    }

    public Vector add(Vector b) {
        return new Vector(this.x + b.x, this.y + b.y, this.z + b.z);
    }

    public Vector subtract(Vector b) {
        return new Vector(this.x - b.x, this.y - b.y, this.z - b.z);
    }

    public String toString() {
        return String.format("%f %f %f", this.x, this.y, this.z);
    }

    public boolean equals(Vector b) {
        return this.x == b.x && this.y == b.y && this.z == b.z;
    }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "ray-tracer" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
