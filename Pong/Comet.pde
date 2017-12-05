class Comet extends FCircle{

  Star catcher;
  Joint joint;

  Comet(){
    super(20);
    setPosition(width/2, height/2);
    setFriction(0);
    setRestitution(1);
    setBullet(true);
    setDamping(0);
    setName("comet");
    catcher = null;
  }

  boolean outOfBoard()
  {
    if(catcher != null)
      return false;
    if(getX() <= -10 || getX() >= width+10)
      return true;
    return false;
  }

  void respawn()
  {
    setPosition(width/2, height/2);
    setVelocity(-100, 10); 
    //setVelocity(0,0);
    setRotation(0);
    setAngularVelocity(0);
  }
}