interface Shape3D {
    public Material getMaterial();
    public void setMaterial(Material material);
    public Hit intersect(Ray ray);
    public Vector getPosition();
}