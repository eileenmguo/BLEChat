#include <RBL_nRF8001.h>
#include <RBL_services.h>

#include <SPI.h>
#include <EEPROM.h>
#include <boards.h>

#include <Servo.h>

#define SERVO_PIN 5
#define BUTTON_PIN 2
#define SERVO_STEP 1
#define PHOTO_RES A0

#define SERVO_MAX 180
#define SERVO_MIN 0

Servo servo;
int pos = 90;
int target = 90;
int inc = SERVO_STEP;
int buttonValue = 0;
int lightVal = 0;
byte buf[4] = {0};
unsigned char len = 0;

void servoTick() {
  if (target > pos) {
    pos += 1;
  } else if (target < pos) {
    pos -= 1;
  }
  servo.write(pos);
}

void setup() {
  pinMode(BUTTON_PIN, INPUT);
  pinMode(PHOTO_RES, INPUT);

  servo.attach(SERVO_PIN);
  servo.write(pos);

  ble_begin();

  Serial.begin(57600);
  Serial.println("Ready...");
}

void loop() {
  int lv = analogRead(PHOTO_RES);
  if (abs(lv - lightVal) > 10) {
    lightVal = lv;
    Serial.print("l: ");
    lightVal = lv;
    ble_write(0x00);
    byte data = map(lightVal, 260, 740, 0, 255);
    Serial.println(data);
    ble_write(data);
  }

  if (ble_available()) {
    while (ble_available() && len < 4) {
      buf[len] = ble_read();
      Serial.print(buf[len]);
      len += 1;
    }
    Serial.println();

    switch (buf[0]) {
      case 3:
        byte data = buf[1];
        target = map(data, 0, 255, SERVO_MIN, SERVO_MAX);
        break;
    }
    len = 0;
  }

  ble_do_events();
  servoTick();
  delay(5);
}

