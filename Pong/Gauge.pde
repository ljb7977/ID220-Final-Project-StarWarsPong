class Gauge extends FBox{
  int x;

  Gauge(int x, int y, String name, Star parent){
    super(200, 20);
    this.x = x;
    setParent(parent);
    setGrabbable(false);
    setPosition(x, y);
    setSensor(true);
    setName(name);
  }

  void step()
  {
    Star parent = (Star)getParent();
    resize();
  }

  void resize()
  {
    Star parent = (Star)getParent();
    float size = map(parent.energy, 0, parent.maxenergy, 0, width);
    if(getName().equals("gauge1"))
      setPosition(x+size/2, getY());
    else if (getName().equals("gauge2"))
      setPosition(x-size/2, getY());
    if(size <= 2)
      setDrawable(false);
    else{
      setDrawable(true);
      setWidth(size);  
    }
  }
}