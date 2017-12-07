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

  int outOfBoard()
  {
    if(catcher != null)
      return 0;
    if(getX() <= -10)
      return 2;
    if(getX() >= width+10)
      return 1;
    return 0;
  }

  void respawn()
  {
    setPosition(width/2, height/2);
    int rand = int(random(0, 2));
    if(rand == 0)
      rand = -1;
    setVelocity(random(200, 300) * rand, random(-10, 10)); 
    //setVelocity(0,0);
    setRotation(0);
    setAngularVelocity(0);
  }
}