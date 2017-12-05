import fisica.*;
import processing.serial.*;

Serial myPort, sendPort;

FWorld world;

Gravity g1, g2;
Star p1, p2;
Comet comet;
Gauge gauge1, gauge2;
boolean up, down;

void setup()
{
  
  //fullScreen();
  size(1280, 720);
  smooth();
  frameRate(60);
  background(0);
  rectMode(CENTER);
  noStroke();
  
  println(Serial.list());
  //delay(10000);
  
  sendPort = new Serial(this, Serial.list()[1], 38400);
  sendPort.clear();
  sendPort.bufferUntil(10);
  
  Fisica.init(this);
  world = new FWorld();
  world.setGravity(0,0);
  world.setEdges();
  world.remove(world.right);
  world.remove(world.left);
  world.setEdgesFriction(0);
  world.setEdgesRestitution(1);

  p1 = new Star(100, "star1");
  p2 = new Star(width-100, "star2");

  g1 = new Gravity("gravity1", p1);
  g2 = new Gravity("gravity2", p2);

  gauge1 = new Gauge(50, height-50, "gauge1", p1);
  gauge2 = new Gauge(width-50, 50, "gauge2", p2);

  comet = new Comet();
  comet.respawn();
  
  world.add(g1);
  world.add(g2);
  world.add(p1);
  world.add(p2);
  world.add(comet);
  world.add(gauge1);
  world.add(gauge2);

  myPort = new Serial(this, Serial.list()[0], 38400);
  myPort.clear();
  myPort.bufferUntil(10);
}

void draw()
{
  background(0);
  if(up){
     p2.setY(p2.y-5);
     println(p2.y);
  } else if (down){
     p2.setY(p2.y+5);
     println(p2.y);
  }
  
  p1.step();
  p2.step();

  g1.step();
  g2.step();

  if(comet.catcher != null){
    if(!comet.catcher.gravityOn){ //when the catcher is turned off
      if(comet.catcher == p1)
        sendPort.write("r"); //send serial message (boom vibe)
      comet.catcher = null;
      comet.joint.removeFromWorld();
    }
  }

  if(comet.isTouchingBody(g1) && p1.gravityOn && (comet.catcher == null)){
    comet.catcher = p1;
    comet.joint = new Joint(p1, comet);
    comet.joint.addToWorld(world);
    println("catched by g1");
  } else if (comet.isTouchingBody(g2) && p2.gravityOn && (comet.catcher == null)){
    comet.catcher = p2;
    comet.joint = new Joint(p2, comet);
    comet.joint.addToWorld(world);
    println("catched by g2");
  }

  gauge1.step();
  gauge2.step();

  world.step();
  world.draw();

  if(comet.outOfBoard()){
    println("Out");
    delay(2000);
    comet.respawn();
  }
}

void keyPressed()
{
  if(key == ' '){
    p2.turnOnGravity();
  }

  if(key == CODED){
    if(keyCode == UP){
       up = true;
    } else if (keyCode == DOWN){
       down = true;
    }
  }
}

void keyReleased()
{
  if(key == ' '){
    p2.turnOffGravity();
  }
  if(key == CODED){
    if(keyCode == UP){
       up = false;
    } else if (keyCode == DOWN){
       down = false;
    }
  }
}

void serialEvent(Serial p){
  String s = p.readStringUntil(10);
  String[] list;
  if(s != null){
    list = s.split(" ");
    println(list);
    if(list.length != 2)
      return;
    float temp = float(list[0]);
    if(Float.isNaN(temp))
      return;
    p1.setY(map(temp, 2, 30, 100, height-100));
    if(list[1].charAt(0) == '1'){
      if(p1.buttonPushed == false){
        p1.turnOnGravity();
        p1.buttonPushed = true;
      }
    } else {
      if(p1.buttonPushed){
        p1.buttonPushed = false;
        p1.turnOffGravity();
      }
    }
  }
}

/*
void contactStarted(FContact contact)
{
   if(contact.contains("star1", "comet")){
     println("collide");
     delay(2000);
     comet.respawn();
   }
}
*/
/*
void contactPersisted(FContact contact)
{
   if(contact.contains("gravity1", "comet") && g1.on){
     //println("contact persisted");
   }
}

void contactEnded(FContact contact)
{
  if(contact.contains("gravity1", "comet") && g1.on){
     println("contact end");
   }
}
*/