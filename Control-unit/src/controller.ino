#include <ClickEncoder.h>
#include <TimerOne.h>
#include "Keyboard.h"
int16_t last1, value1;
int16_t last2, value2;

ClickEncoder encoder1 = ClickEncoder(10,9,8);
ClickEncoder encoder2 = ClickEncoder(3,4,5);


void timerIsr() {      //Service methods from both instances must be included
  encoder1.service();
  encoder2.service();
}

void setup() {
  pinMode(8, INPUT_PULLUP);
  pinMode(9, INPUT_PULLUP);
  pinMode(10, INPUT_PULLUP);
  pinMode(3, INPUT_PULLUP);
  pinMode(4, INPUT_PULLUP);
  pinMode(5, INPUT_PULLUP);
  Timer1.initialize(1000);
  Timer1.attachInterrupt(timerIsr);
  Serial.begin(115200);
  encoder1.setButtonHeldEnabled(false);
  encoder1.setDoubleClickEnabled(false);
  encoder1.setAccelerationEnabled(true);
  encoder2.setButtonHeldEnabled(false);
  encoder2.setDoubleClickEnabled(false);
  encoder2.setAccelerationEnabled(true);
  last1 = -1;
  last2 = -1;
  Keyboard.begin(); //activate keyboard emulation
}


void loop() {
  value1 += encoder1.getValue();
  if (value1 > last1) {
    //Serial.println("Up");
    Keyboard.write(KEY_UP_ARROW);
  }else if (value1<last1){
    Keyboard.write(KEY_DOWN_ARROW);
    //Serial.println("Up");
  }
  last1 = value1;
  if(encoder1.getButton() == ClickEncoder::Clicked){
    Keyboard.write(KEY_RETURN);
  }

  value2 += encoder2.getValue();
  if (value2 > last2) {
    Keyboard.write(KEY_RIGHT_ARROW);
  }else if (value2<last2){
    Keyboard.write(KEY_LEFT_ARROW);
  }
  last2 = value2;
  if(encoder2.getButton() == ClickEncoder::Clicked){
    Keyboard.print('i'); //letter i to activate invert mode
  }


}
