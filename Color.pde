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

    public color getColor() {
        return color(r, g, b);
    }
}