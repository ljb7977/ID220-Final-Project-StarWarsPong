import fisica.*;
import processing.serial.*;

Serial myPort, sendPort;
FWorld world;

Gravity g1, g2;
Star p1, p2;
Comet comet;
Gauge gauge1, gauge2;
boolean up, down;
int gamestate;

final int main = 1;
final int ready = 2;
final int gameover = 3;

PImage logo;

long messageTimeStamp;

int win;
int winscore = 50;

void setup()
{
  fullScreen(2);
  //size(1280, 720);
  smooth();
  frameRate(60);
  background(0);
  noStroke();
  imageMode(CENTER);
  
  logo = loadImage("logo.png");
  //logo.resize(335, 271);
  
  PFont font;
  font = createFont("SF Distant Galaxy.ttf", 64);
  textFont(font);
  textAlign(CENTER, CENTER);
  
  println(Serial.list());
  
  sendPort = new Serial(this, Serial.list()[1], 57600);
  sendPort.clear();
  sendPort.bufferUntil(10);
  
  Fisica.init(this);
  world = new FWorld();
  world.setGravity(0,0);
  world.setEdges(0, 20, width, height-20);
  world.remove(world.right);
  world.remove(world.left);
  world.setEdgesFriction(0);
  world.setEdgesRestitution(1);

  p1 = new Star(100, "star1");
  p2 = new Star(width-100, "star2");

  g1 = new Gravity("gravity1", p1);
  g2 = new Gravity("gravity2", p2);

  gauge1 = new Gauge(0, height-10, "gauge1", p1);
  gauge2 = new Gauge(width, 10, "gauge2", p2);

  comet = new Comet();
  
  world.add(g1);
  world.add(g2);
  world.add(p1);
  world.add(p2);
  world.add(comet);
  world.add(gauge1);
  world.add(gauge2);

  myPort = new Serial(this, Serial.list()[0], 57600);
  myPort.clear();
  myPort.bufferUntil(10);

  gamestate = ready;

  reset();
  comet.setVelocity(0,0);
}

void draw()
{
  if(gamestate == main){
    if(messageTimeStamp != 0){
      if(millis() - messageTimeStamp <= 2000){
        if(win == 1){
          pushMatrix();
          translate(300, height/2);
          rotate(radians(90));

          textSize(60);

          text("p1 scored!", 0, 0);
          popMatrix();

          pushMatrix();
          translate(width-300, height/2);
          rotate(radians(270));

          textSize(60);

          text("p1 scored!", 0, 0);
          popMatrix();
        } else if (win == 2){
          pushMatrix();
          translate(300, height/2);
          rotate(radians(90));

          textSize(60);
          text("p2 scored!", 0, 0);
          popMatrix();

          pushMatrix();
          translate(width-300, height/2);
          rotate(radians(270));

          textSize(60);
          text("p2 scored!", 0, 0);
          popMatrix();
        }
      } else {
        messageTimeStamp = 0;
      }
      reset();
      return;
    }
    background(0);

    if(up){
       p2.setY(p2.y-5);
    } else if (down){
       p2.setY(p2.y+5);
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
        comet.joint = null;
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

    if(comet.joint != null){
      comet.joint.step();
    }

    world.step();
    world.draw();

    if((win = comet.outOfBoard()) != 0){
      if(win == 1){
        p1.score+=10;
      } else if (win == 2){
        p2.score+=10;
      }

      println(win);
      messageTimeStamp = millis();
      println("Out");
    }

    if(comet.isTouchingBody(p1)){
      println("Collide");
      sendPort.write("r");
      println("r");

      win = 2;
      p2.score+=10;

      messageTimeStamp = millis();
      p1.maxenergy += 10;
    }
    if(comet.isTouchingBody(p2)){
      println("Collide");
      sendPort.write("r");
      println("r");

      win = 1;
      p1.score+=10;

      messageTimeStamp = millis();
      p2.maxenergy += 10;
    }

    printScore();
    if(p1.score >= winscore || p2.score >=winscore){
      messageTimeStamp = millis();
      gamestate = gameover;
    }
  } else if (gamestate == ready) {
    background(0);

    if(up){
       p2.setY(p2.y-5);
    } else if (down){
       p2.setY(p2.y+5);
    }

    image(logo, width/2, 300);

    pushMatrix();

    translate(400, height/2);
    rotate(radians(90));

    textSize(40);
    text("Keep pressing button to start game", 0, 0);

    popMatrix();  

    pushMatrix();

    translate(width-400, height/2);
    rotate(radians(270));

    textSize(40);
    text("Keep pressing button to start game", 0, 0);

    popMatrix();

    p1.energy = p1.maxenergy;
    p2.energy = p2.maxenergy;

    p1.step();
    p2.step();

    g1.step();
    g2.step();

    /*
    gauge1.step();
    gauge2.step();
    */

    gauge1.setDrawable(false);
    gauge2.setDrawable(false);

    comet.setDrawable(false);

    world.step();
    world.draw();

    if(p1.gravityOn && p2.gravityOn){
      if(millis()-p1.onTimeStamp > p1.maxTime && millis()-p2.onTimeStamp > p2.maxTime){
        reset();
        gauge1.setDrawable(true);
        gauge2.setDrawable(true);
        comet.setDrawable(true);
        gamestate = main;
        p1.turnOffGravity();
        p2.turnOffGravity();

        sendPort.write("r");
        println("r");
        reset();
      }
    }
  } else if (gamestate == gameover){
    if(messageTimeStamp != 0){
      if(millis() - messageTimeStamp <= 3000){
        if(win == 1){
          pushMatrix();
          translate(300, height/2);
          rotate(radians(90));

          textSize(60);

          text("p1 win!", 0, 0);
          popMatrix();

          pushMatrix();
          translate(width-300, height/2);
          rotate(radians(270));

          textSize(60);

          text("p1 win!", 0, 0);
          popMatrix();
        } else if (win == 2){
          pushMatrix();
          translate(300, height/2);
          rotate(radians(90));

          textSize(60);
          text("p2 win!", 0, 0);
          popMatrix();

          pushMatrix();
          translate(width-300, height/2);
          rotate(radians(270));

          textSize(60);
          text("p2 win!", 0, 0);
          popMatrix();
        }
      } else {
        messageTimeStamp = 0;
        gamestate = ready;
      }
      reset();
      p1.score = 0;
      p2.score = 0;
      return;
    }
  }
}

void printScore()
{
  pushMatrix();

  translate(50, 150);
  rotate(radians(90));

  textSize(30);
  text("Score: "+str(p1.score), 0, 0);

  popMatrix();  

  pushMatrix();

  translate(width-50, height-150);
  rotate(radians(270));

  textSize(30);
  text("Score: "+str(p2.score), 0, 0);

  popMatrix();
}

void reset()
{
  p1.energy = p1.maxenergy;
  p2.energy = p2.maxenergy;

  comet.respawn();
}

void keyPressed()
{
  if(key == ' '){
    if(p2.buttonPushed == false){
        p2.turnOnGravity();
        p2.buttonPushed = true;
    }
  }

  if(key == CODED){
    if(keyCode ==RIGHT){
       up = true;
    } else if (keyCode ==LEFT){
       down = true;
    }
  }
}

void keyReleased()
{
  if(key == ' '){
    if(p2.buttonPushed){
      p2.buttonPushed = false;
      p2.turnOffGravity();
    }
  }
  if(key == CODED){
    if(keyCode == RIGHT){
       up = false;
    } else if (keyCode == LEFT){
       down = false;
    }
  }
}

void serialEvent(Serial p){
  String s = p.readStringUntil(10);
  String[] list;
  if(s != null){
    list = s.split(" ");
    //println(list);
    if(list.length != 2)
      return;
    float temp = float(list[0]);
    if(Float.isNaN(temp))
      return;
    p1.setY(map(temp, 2, 30, 120, height-120));
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