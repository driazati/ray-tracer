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