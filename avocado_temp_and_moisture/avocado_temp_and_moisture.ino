/*
 * environmental sensors for a potted avocado plant
 * soil moisture sensor readout controls 3 LEDs
 * temperature and soil moisture values are written to serial port
 */

const int SOIL_PIN = A0;
const int TEMP_PIN = A1;
const int GREEN = 8;
const int YELLOW = 9;
const int RED = 10;
float soil, temp;

void setup() {
  pinMode(SOIL_PIN, INPUT);
  pinMode(TEMP_PIN, INPUT);
  pinMode(GREEN, OUTPUT);
  pinMode(YELLOW, OUTPUT);
  pinMode(RED, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  soil = getMoisturePercentageFrom(SOIL_PIN);
  temp = getTempFrom(TEMP_PIN);
  Serial.print("soil moisture ");
  Serial.print(soil);
  Serial.print("%, air temp ");
  Serial.print(temp);
  Serial.println("C.");
  
  if (soil >= 70) {
    digitalWrite(GREEN, HIGH);
    digitalWrite(YELLOW, HIGH);
    digitalWrite(RED, HIGH);
  } else if (soil >= 30) {
    digitalWrite(GREEN, LOW);
    digitalWrite(YELLOW, HIGH);
    digitalWrite(RED, HIGH);
  } else {
    digitalWrite(GREEN, LOW);
    digitalWrite(YELLOW, LOW);
    digitalWrite(RED, HIGH);
  }
  delay(1000);
}

float getTempFrom(int pin) {
  float tempReadout = analogRead(pin) * 0.004882814;
  return (tempReadout - 0.5) * 100.0;
}

float getMoisturePercentageFrom(int pin) {
  float soilReadout = analogRead(pin);
  return soilReadout/800.0 * 100.0;
}
