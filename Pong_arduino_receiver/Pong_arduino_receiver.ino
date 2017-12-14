const int motorPin[2] = {6,5};
const int redPin[2] = {13, 10};
const int greenPin[2] = {12, 9};
const int bluePin[2] = {11, 8};

unsigned long timestamp[2];
unsigned long interval[2] = {300, 300};

bool motorOn[2];

void setup() {
  Serial.begin(57600);
  for(int i =0; i<2; i++){
    timestamp[i] = millis();
    analogWrite(redPin[i], 0);
    analogWrite(greenPin[i], 255);
    analogWrite(bluePin[i], 255);
  }
}

void loop() {
  for(int i=0;i<2;i++){
    if(motorOn[i]){
      if(millis()-timestamp[i] >= interval[i]){
        analogWrite(motorPin[i], 0);
        motorOn[i] = false;
      }
    }
  }
}

void serialEvent()
{
  if(Serial.available()){
    char c = (char)Serial.read();

    if(c != 'm')
      return;

    int num = Serial.parseInt();

    if(num == 0)
      return;
    num--;

    int op = Serial.parseInt();

    if(op == 0){
      byte r = Serial.parseInt();
      byte g = Serial.parseInt();
      byte b = Serial.parseInt();
      analogWrite(redPin[num], r);
      analogWrite(greenPin[num], g);
      analogWrite(bluePin[num], b);
    } else if (op == 1){ //r
      analogWrite(motorPin[num], 255);
      timestamp[num] = millis();
      interval[num] = 300;
      motorOn[num] = true;
    } else if (op == 2){ //v
      int motorspeed;
      interval[num] = Serial.parseInt();
      motorspeed = Serial.parseInt();
      analogWrite(motorPin[num], motorspeed);
      timestamp[num] = millis();
      motorOn[num] = true;
    } else if (op == 3){ //s
      analogWrite(motorPin[num], 0);
      motorOn[num] = false;
    }
  }
}
