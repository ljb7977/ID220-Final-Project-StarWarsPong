#define motorPin 6

const int redPin = 11;
const int greenPin = 10;
const int bluePin = 9;

unsigned long timestamp;
unsigned long interval = 300;
unsigned long motorspeed = 100;

bool motorOn;

void setup() {
  Serial.begin(57600);
  timestamp = millis();
  analogWrite(redPin, 0);
  analogWrite(greenPin, 255);
  analogWrite(bluePin, 255);
}

void loop() {
  if(motorOn){
    if(millis()-timestamp >= interval){
      analogWrite(motorPin, 0);
      motorOn = false;
    }
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
      interval = 300;
      motorOn = true;
    } else if (op == 'v'){
      interval = Serial.parseInt();
      motorspeed = Serial.parseInt();
      analogWrite(motorPin, motorspeed);
      timestamp = millis();
      motorOn = true;
    } else if (op == 's'){
      analogWrite(motorPin, 0);
      motorOn = false;
    }
  }
}
