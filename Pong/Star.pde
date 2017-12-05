class Star extends FCircle{
  
  float y = height/2, energy = 400, maxenergy = 400;
  boolean gravityOn, buttonPushed;
  long onTimeStamp, vibeTimeStamp;
  float force = 40;

  final int maxTime = 7000;

  Star(int position, String name){
    super(80);
    setPosition(position, height/2);
    setFriction(0);
    setRestitution(1);
    setRotatable(false);
    setStatic(true);
    setBullet(true);
    setGrabbable(false);
    setName(name);
    setColorHSV(180, 1, 1);
  }

  void setY(float val)
  {
    if(val >= height-100 || val <= 100)
      return;
    y = val;
  }
  
  void step()
  {
    setPosition(getX(), y);
    if(gravityOn){
      int onTime = (int)(millis() - onTimeStamp);
      onTime = constrain(onTime, 0, maxTime); //5 sec limit
      setColorHSV((int)map(onTime, 0, maxTime, 180, 360), 1, 1);
      energy -= 1;  
      
      int interval = (int)map(onTime, 0, 7000, 500, 150);
      int intensity = (int)map(onTime, 0, 7000, 100, 200);
      if(millis()-vibeTimeStamp >= interval){ //send serial vibe
        vibeTimeStamp = millis();
        String message = "v "+ str(interval/2)+" "+str(intensity);
        println(message);
        if(getName().equals("star1"))
        sendPort.write(message);
      }
    } else {
      if(energy + 0.7 <= maxenergy)
        energy += 0.7;
    }
    if(energy <= 0){
      turnOffGravity();
    }
  }

  void turnOnGravity()
  {
    onTimeStamp = millis();
    vibeTimeStamp = millis();
    gravityOn = true;
  }

  void turnOffGravity()
  {
    gravityOn = false;
    setColorHSV(180, 1, 1);
  }

  void setColorHSV(int h, double s, double v) {
    double r=0; 
    double g=0;
    double b=0;
    h %= 360;
    double hf=h/60.0;

    int i=(int)hf;
    double f = h/60.0 - i;
    double pv = v * (1 - s);
    double qv = v * (1 - s*f);
    double tv = v * (1 - s * (1 - f));

    switch (i){
    case 0: //rojo dominante
      r = v;
      g = tv;
      b = pv;
      break;
    case 1: //verde
      r = qv;
      g = v;
      b = pv;
      break;
    case 2: 
      r = pv;
      g = v;
      b = tv;
      break;
    case 3: //azul
      r = pv;
      g = qv;
      b = v;
      break;
    case 4:
      r = tv;
      g = pv;
      b = v;
      break;
    case 5: //rojo
      r = v;
      g = pv;
      b = qv;
      break;
    }
    float red=constrain(255*(float)r,0,255);
    float green=constrain(255*(float)g,0,255);
    float blue=constrain(255*(float)b,0,255);

    setFill(red, green, blue);
    
    String message = "c "+ str(int(red))+" "+ str(int(green))+" "+ str(int(blue));
    println(message);
    if(getName().equals("star1"))
    sendPort.write(message);
  }
}