class Joint extends FRevoluteJoint{

  float direction;

  Joint(Star p, Comet c){
    super(p, c, p.getX(), p.getY());

    PVector v, r;
    v = new PVector(c.getVelocityX(), c.getVelocityY(), 0);
    r = new PVector(p.getX()-c.getX(), p.getY()-c.getY(), 0);
    direction = -1*r.cross(v).z;

    if(direction < 0){
      direction = -1;
    } else {
      direction = 1;
    }
    c.setAngularVelocity(v.mag()/10);
    //println(v.mag()/10);
    
    setEnableMotor(true);
    setEnableLimit(false);
    setMaxMotorTorque(50);
    setMotorSpeed(direction*100);
    setDrawable(false);
  }
}