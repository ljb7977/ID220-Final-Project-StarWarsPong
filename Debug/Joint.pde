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
    //c.setAngularVelocity(v.mag()/10);
    c.setAngularVelocity(0);
    //println(v.mag()/10);
    
    setEnableMotor(true);
    setEnableLimit(false);
    setMaxMotorTorque(10);
    setDrawable(false);
  }

  void step()
  {
    Star p = (Star)getBody1();
    int onTime = (int)(millis() - p.onTimeStamp);

    //println("onTime: "+str(onTime));

    onTime = constrain(onTime, 0, p.maxTime); //5 sec limit
    float speed = map(onTime, 0, p.maxTime, 0, 600);
    //println("speed: "+str(direction * speed));

    setMaxMotorTorque(speed);
    setMotorSpeed(direction *speed);
  }
}