class Hit {
    float t;
    Vector position;
    Shape3D hitObject;
    Vector normal;
    Ray ray;
    static final float EPSILON = 0.001;

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