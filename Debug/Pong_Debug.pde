import fisica.*;
import processing.serial.*;

boolean debug = true;

FWorld world;

Gravity g1, g2;
Star p1, p2;
Comet comet;
Gauge gauge1, gauge2;
int gamestate;

final int main = 1;
final int ready = 2;
final int gameover = 3;

PImage logo, bg;

long messageTimeStamp;

int win;
int winscore = 50;

void setup()
{
  fullScreen(1);
  smooth();
  frameRate(60);
  bg = loadImage("bg.jpg");
  bg.resize(width, height);
  background(bg);
  noStroke();
  imageMode(CENTER);
  
  logo = loadImage("logo.png");
  
  PFont font;
  font = createFont("SF Distant Galaxy.ttf", 64);
  textFont(font);
  textAlign(CENTER, CENTER);
  
  Fisica.init(this);
  world = new FWorld();
  world.setGravity(0,0);
  world.setEdges(0, 20, width, height-20);
  world.remove(world.right);
  world.remove(world.left);
  world.setEdgesFriction(0);
  world.setEdgesRestitution(1);

  p1 = new Star(100, 1);
  p2 = new Star(width-100, 2);

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

  gamestate = ready;

  gauge1.setDrawable(false);
  gauge2.setDrawable(false);
  comet.setDrawable(false);
  
  comet.respawn();
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
      start_match();
      return;
    }
    background(bg);

    if(p1.up){
       p1.setY(p1.y-10);
    } else if (p1.down){
       p1.setY(p1.y+10);
    }

    if(p2.up){
       p2.setY(p2.y-10);
    } else if (p2.down){
       p2.setY(p2.y+10);
    }
    
    if(comet.catcher != null){
      if(!comet.catcher.gravityOn){ //when the catcher is turned off
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
    
    g1.step();
    g2.step();

    gauge1.step();
    gauge2.step();

    if(comet.joint != null){
      comet.joint.step();
    }

    world.step();
    world.draw();

    comet.step();
    p1.step();
    p2.step();

    if((win = comet.outOfBoard()) != 0){
      if(win == 1){
        p1.getScore();
      } else if (win == 2){
        p2.getScore();
      }
      println("Out");
    }

    if(comet.isTouchingBody(p1)){
      println("Collide");
      win = 2;
      p2.getScore();
    }
    if(comet.isTouchingBody(p2)){
      println("Collide");
      win = 1;
      p1.getScore();
    }

    printScore();
    if(p1.score >= winscore || p2.score >= winscore){
      messageTimeStamp = millis();
      gamestate = gameover;
    }
  } else if (gamestate == ready) {
    background(bg);

    if(p1.up){
       p1.setY(p1.y-10);
    } else if (p1.down){
       p1.setY(p1.y+10);
    }

    if(p2.up){
       p2.setY(p2.y-10);
    } else if (p2.down){
       p2.setY(p2.y+10);
    }

    image(logo, width/2, 300);

    pushMatrix();

    translate(400, height/2);
    rotate(radians(90));

    textSize(40);
    text("Press and hold the star to start game", 0, 0);

    popMatrix();  

    pushMatrix();

    translate(width-400, height/2);
    rotate(radians(270));

    textSize(40);
    text("Press and hold the star to start game", 0, 0);

    popMatrix();

    p1.energy = p1.maxenergy;
    p2.energy = p2.maxenergy;
    
    g1.step();
    g2.step();

    world.step();
    world.draw();

    p1.step();
    p2.step();

    if(p1.gravityOn && p2.gravityOn){
      if(millis()-p1.onTimeStamp > p1.maxTime && millis()-p2.onTimeStamp > p2.maxTime){
        start_match();
        gauge1.setDrawable(true);
        gauge2.setDrawable(true);

        gamestate = main;
        p1.turnOffGravity();
        p2.turnOffGravity();
      }
    }
  } else if (gamestate == gameover){
    if(messageTimeStamp != 0){
      if(millis() - messageTimeStamp <= 3000){

        pushMatrix();
        translate(500, height/2);
        rotate(radians(90));
        textSize(100);
        if(win == 1)
          text("WIN!", 0, 0);
        else
          text("LOSE....", 0, 0);
        popMatrix();
        
        pushMatrix();
        translate(width-500, height/2);
        rotate(radians(270));
        textSize(100);
        if(win == 2)
          text("LOSE....", 0, 0);
        else
          text("WIN!", 0, 0);
        popMatrix();
      } else {
        messageTimeStamp = 0;
        gamestate = ready;
        p1.maxenergy = 400;
        p2.maxenergy = 400;
        p1.score = 0;
        p2.score = 0;
        gauge1.setDrawable(false);
        gauge2.setDrawable(false);
        comet.setDrawable(false);
        start_match();
      }
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

void start_match()
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

  if(key == 'd'){
    if(p1.buttonPushed == false){
        p1.turnOnGravity();
        p1.buttonPushed = true;
    }
  }

  if(key == 'w'){
    p1.up = true;
  }

  if(key == 's'){
    p1.down = true;
  }

  if(key == CODED){
    if(keyCode == UP){
       p2.up = true;
    } else if (keyCode == DOWN){
       p2.down = true;
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
  
  if(key == 'd'){
    if(p1.buttonPushed){
      p1.buttonPushed = false;
      p1.turnOffGravity();
    }
  }

  if(key == 'w'){
    p1.up = false;
  }

  if(key == 's'){
    p1.down = false;
  }

  if(key == CODED){
    if(keyCode == UP){
       p2.up = false;
    } else if (keyCode == DOWN){
       p2.down = false;
    }
  }
}