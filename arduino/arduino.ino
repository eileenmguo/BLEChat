#include <RBL_nRF8001.h>
#include <RBL_services.h>

#include <SPI.h>
#include <EEPROM.h>
#include <boards.h>

#include <Servo.h>

#define SERVO_PIN 5
#define BUTTON_PIN 2
#define PHOTO_RES A1

#define SERVO_MAX 180
#define SERVO_MIN 0

Servo servo;
int target = 90;
int lightVal = 0;
bool buttonPressed = 0;
bool servoUp = 1;
byte buf[4] = {0};
bool automated = true;

unsigned long lastDebounceTime = 0;
unsigned long debounceDelay = 200;

void servoTick(bool forever = false) {
  if (forever) {
    if (servo.read() == SERVO_MAX) {
      servoUp = false;
    } else if (servo.read() == SERVO_MIN) {
      servoUp = true;
    }
    int inc = servoUp ? 1 : -1;
    servo.write(servo.read() + inc);
  } else if (target > servo.read()) {
    servo.write(servo.read() + 1);
  } else if (target < servo.read()) {
    servo.write(servo.read() - 1);
  }

  if (millis() - lastDebounceTime > debounceDelay) {
    ble_write(0x01);
    ble_write(map(servo.read(), SERVO_MIN, SERVO_MAX, 0, 255));
    lastDebounceTime = millis();
  }
}

void setup() {
  pinMode(BUTTON_PIN, INPUT);
  pinMode(PHOTO_RES, INPUT);

  servo.attach(SERVO_PIN);
  servo.write(servo.read());

  ble_begin();

  Serial.begin(57600);
  Serial.println("Ready...");
}

void loop() {
  bool bp = !digitalRead(BUTTON_PIN);
  if (bp && automated) {
    automated = 0;
    ble_write(0x02);
    ble_write(bp);
  } else if (buttonPressed & !bp) {
    target = servo.read();
  }
  buttonPressed = bp;
  
  int lv = analogRead(PHOTO_RES);
  if (lv < 400 && automated) {
    target = SERVO_MIN;
  } else if (lv > 700 && automated) {
    target = SERVO_MAX;
  }

  if (abs(lv - lightVal) > 10) {
    lightVal = lv;
    ble_write(0x00);
    byte data = map(lightVal, 260, 1023, 0, 255);
    ble_write(data);
  }

  if (ble_available()) {
    unsigned short len = 0;
    while (ble_available() && len < 4) {
      buf[len] = ble_read();
      Serial.print(buf[len]);
      len += 1;
    }

    byte data;
    switch (buf[0]) {
      case 3:
        data = buf[1];
        target = map(data, 0, 255, SERVO_MIN, SERVO_MAX);
        break;
      case 4:
        data = buf[1];
        automated = data;
        break;
    }
  }
  
  servoTick(buttonPressed);
  ble_do_events();
  delay(10);
}

