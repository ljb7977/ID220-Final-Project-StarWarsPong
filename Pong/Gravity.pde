class Gravity extends FCircle{
  Gravity(String name, Star parent){
    super(200);
    setParent(parent);
    setFill(128);
    setSensor(true);
    setRotatable(false);
    setDrawable(false);
    setBullet(true);
    setName(name);
  }

  void step(){
    float r, b;
    Star parent = (Star)getParent();
    setPosition(parent.getX(), parent.getY());
  
    setDrawable(parent.gravityOn);
  }
}