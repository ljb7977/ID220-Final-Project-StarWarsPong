#define motorPin 6

const int redPin = 11;
const int greenPin = 10;
const int bluePin = 9;

unsigned long timestamp;
unsigned long interval = 300;
unsigned long motorspeed = 100;

bool motorOn, next_motorOn;

void setup() {
  Serial.begin(38400);
  timestamp = millis();
  analogWrite(redPin, 0);
  analogWrite(greenPin, 255);
  analogWrite(bluePin, 255);
}

void loop() {
  // put your main code here, to run repeatedly:

  //interval = map(pressure, 100, 600, 300, 75);
  //motorspeed = map(pressure, 100, 600, 100, 200);
  if(millis()-timestamp >= interval){
    timestamp = millis();
    if(motorOn)
      analogWrite(motorPin, 0);
    else
      //analogWrite(motorPin, motorspeed);
    motorOn = !motorOn;
  }
  
}

void serialEvent()
{
  if(Serial.available()){
    char op = (char)Serial.read();
    
    if(op == 'c'){
      byte r = Serial.parseInt();
      byte g = Serial.parseInt();
      byte b = Serial.parseInt();
      analogWrite(redPin, r);
      analogWrite(greenPin, g);
      analogWrite(bluePin, b);
    } else if (op == 'r'){
      analogWrite(motorPin, 255);
      timestamp = millis();
      motorOn = true;
    }
  }
}
