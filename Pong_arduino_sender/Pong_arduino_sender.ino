#define num 10

const int echoPin[2] = {12, 10};
const int trigPin[2] = {13, 11};
const int pressPin[2] = {A1, A0};

float readings[2][num], total[2];
int readindex;

void setup() {
  Serial.begin(57600);
  for(int i = 0; i < 2; i++){
    pinMode(trigPin[i], OUTPUT);
    pinMode(echoPin[i], INPUT);
  }
}

void loop() {
  int pressure;
  long duration;
  float distance, avg;
  bool gravity;

  for(int i=0; i<2; i++){
    digitalWrite(trigPin[i], LOW);
    delayMicroseconds(i);
    digitalWrite(trigPin[i], HIGH);
    delayMicroseconds(10);
    digitalWrite(trigPin[i], LOW);
    
    duration = pulseIn(echoPin[i], HIGH, 100000);
    distance = (duration/2) / 29.1;
    total[i] -= readings[i][readindex];
    readings[i][readindex] = distance;
    total[i] += readings[i][readindex];
    readindex++;
    
    if(readindex >= num)
      readindex = 0;

    avg = 32-total[i]/num*2;
    float val = constrain(avg, 2, 30);

    Serial.print(i+1);
    Serial.print(" ");
    Serial.print(val);
    Serial.print(" ");
    
    pressure = analogRead(pressPin[i]);
    gravity = pressure >= 500;

    Serial.print(gravity);
    Serial.println("");
  }
  delay(30);
}
