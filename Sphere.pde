class Sphere implements Shape3D {
    float radius;
    Vector center;
    Material material;
    static final float EPSILON = 0.0001;

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
        float b = 2.0 * ray.direction.dot(l);
        float c = l.dot(l) - radius * radius;
        float disc = (b * b - 4.0 * a * c);

        float t = 0;

        if (disc < 0) {
            //no intersection
            return null;
        } else if (disc == 0) {
            //tangent
            t = -0.5 * b / a;
        } else {
            //2 hits
            float t0 = -0.5 * (b + sqrt(disc)) / a;
            float t1 = -0.5 * (b - sqrt(disc)) / a;

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