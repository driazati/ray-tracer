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