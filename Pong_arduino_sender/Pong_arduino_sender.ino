#define num 10
#define trigPin 13
#define echoPin 12

float readings[num], total, avg;
int readindex;
bool gravity;

void setup() {
  Serial.begin(57600);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
}

void loop() {
  int i, angle, pressure;
  long duration;
  float distance;

  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  
  duration = pulseIn(echoPin, HIGH, 100000);
  distance = (duration/2) / 29.1;
  total -= readings[readindex];
  readings[readindex] = distance;
  total += readings[readindex];
  readindex++;
  
  if(readindex >= num)
    readindex = 0;

  avg = total/num;
  float val = constrain(avg, 2, 30);
  Serial.print(val);
  Serial.print(" ");
  
  pressure = analogRead(A0);
  gravity = pressure >= 500;

  Serial.print(gravity);
  Serial.println("");
  delay(30);
}

