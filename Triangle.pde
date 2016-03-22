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
        float epsilon = 0.001;

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