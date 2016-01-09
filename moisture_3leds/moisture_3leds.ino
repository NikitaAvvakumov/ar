/*
 * moisture sensor controls 3 LEDs, according to its readings
 * and write sensor reading to serial port
 */

const int SENSOR = A0;
const int GREEN = 8;
const int YELLOW = 9;
const int RED = 10;
int moisture = 0;

void setup() {
  pinMode(SENSOR, INPUT);
  pinMode(GREEN, OUTPUT);
  pinMode(YELLOW, OUTPUT);
  pinMode(RED, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  moisture = analogRead(SENSOR);
  Serial.println(moisture);
  
  if (moisture >= 500) {
    digitalWrite(GREEN, HIGH);
    digitalWrite(YELLOW, HIGH);
    digitalWrite(RED, HIGH);
  } else if (moisture >= 200) {
    digitalWrite(GREEN, LOW);
    digitalWrite(YELLOW, HIGH);
    digitalWrite(RED, HIGH);
  } else {
    digitalWrite(GREEN, LOW);
    digitalWrite(YELLOW, LOW);
    digitalWrite(RED, HIGH);
  }
  delay(5000);
//  delay(1800000); // read sensor every 30 min
}
