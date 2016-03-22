class Ray {
    Vector origin;
    Vector direction;

    public Ray(Vector origin, Vector direction) {
        this.origin = origin.copy();
        this.direction = direction.normalize();
    }
}