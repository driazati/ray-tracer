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