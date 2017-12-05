#include <SoftwareSerial.h>

#define num 5
#define motorPin 6

const int redPin = 11;
const int greenPin = 10;
const int bluePin = 9;

float readings[2][num];
int readindex[2];
float total[2];
float avg[2];
bool gravity, prev_gravity;

unsigned long int trigPin[2] = {8, 13};
unsigned long int echoPin[2] = {7, 12};

unsigned long timestamp;
unsigned long interval = 300;
unsigned long motorspeed = 100;

bool motorOn, next_motorOn;

SoftwareSerial sender(2, 3);

void setup() {
  Serial.begin(9600);
  sender.begin(9600);
  for(int i = 0; i<2; i++){
    pinMode(trigPin[i], OUTPUT);
    pinMode(echoPin[i], INPUT);
  }
  timestamp = millis();
}

void loop() {
  int i, angle, pressure;
  long duration[2];
  float distance[2];

  for(i=0;i<2;i++){
    digitalWrite(trigPin[i], LOW);  // Added this line
    delayMicroseconds(2); // Added this line
    digitalWrite(trigPin[i], HIGH);
    delayMicroseconds(10); // Added this line
    digitalWrite(trigPin[i], LOW);
    duration[i] = pulseIn(echoPin[i], HIGH, 100000);
    distance[i] = (duration[i]/2) / 29.1;
    total[i] -= readings[i][readindex[i]];
    readings[i][readindex[i]] = distance[i];
    total[i] += readings[i][readindex[i]];
    readindex[i] = readindex[i]+1;
    if(readindex[i] >= num)
      readindex[i] = 0;

    avg[i] = total[i]/num;
    float val = constrain(avg[i], 2, 30);
    sender.print(val);
    //Serial.print(distance[i]);
    sender.print(" ");
  }
  pressure = analogRead(A0);

  gravity = pressure >= 500;

  if(gravity == false && prev_gravity == true){
    //released
    analogWrite(motorPin, 255);
    timestamp = millis();
    motorOn = true;
  }

  sender.print(gravity);

  //interval = map(pressure, 100, 600, 300, 75);
  //motorspeed = map(pressure, 100, 600, 100, 200);

  //Serial.println(motorspeed);
  if(millis()-timestamp >= interval){
    timestamp = millis();
    if(motorOn)
      analogWrite(motorPin, 0);
    else
      if(gravity)
        analogWrite(motorPin, motorspeed);
    motorOn = !motorOn;
  }

  prev_gravity = gravity;
  sender.println("");
  delay(50);
}

void serialEvent()
{
  if(Serial.available()){
    char op = (char)Serial.read();
    
    if(op == 'c'){
      int r = Serial.parseInt();
      int g = Serial.parseInt();
      int b = Serial.parseInt();
      analogWrite(redPin, r);
      analogWrite(greenPin, g);
      analogWrite(bluePin, b);
    } /*else {
      analogWrite(redPin, 255);
      analogWrite(greenPin, 255);
      analogWrite(bluePin, 255);
    }*/
  }
}
