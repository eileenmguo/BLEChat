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
char buf[16] = {0};
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
  //  temp = analogRead(PHOTO_RES);
  //  Serial.println(temp);
  //  target = temp > 400 ? SERVO_MAX : SERVO_MIN;

  if (ble_available()) {
    while (ble_available() && len < 16) {
      buf[len] = ble_read();
      Serial.write(buf[len]);
      len += 1;
    }
    Serial.println();

    switch (buf[0]) {
      case 'p':
        char * dataBuf = buf + 2;
        int p = atoi(dataBuf);
        Serial.println(p);
        target = map(p, 0, 180, SERVO_MIN, SERVO_MAX);
        Serial.println(target);
        break;
    }
    // Handle the command
    len = 0;
  }

  ble_do_events();

  servoTick();
  delay(5);
}

