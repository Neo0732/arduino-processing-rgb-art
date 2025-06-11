import cc.arduino.*;

Arduino arduino;

// 핀 정의
final int VAL_R = 0;    // A0 - R값을 위한 가변저항
final int VAL_G = 1;    // A1 - G값을 위한 가변저항  
final int VAL_B = 2;    // A2 - B값을 위한 가변저항

final int c1LED_R = 19;  // A5 - R 제어용 RGB LED의 R핀
final int c1LED_G = 18;  // A4 - R 제어용 RGB LED의 G핀
final int c1LED_B = 17;  // A3 - R 제어용 RGB LED의 B핀

final int c2LED_R = 3;   // G 제어용 RGB LED의 R핀
final int c2LED_G = 4;   // G 제어용 RGB LED의 G핀
final int c2LED_B = 5;   // G 제어용 RGB LED의 B핀

final int c3LED_R = 6;   // B 제어용 RGB LED의 R핀
final int c3LED_G = 7;   // B 제어용 RGB LED의 G핀
final int c3LED_B = 8;   // B 제어용 RGB LED의 B핀

final int tLED_R = 9;    // 조색 RGB LED의 R핀
final int tLED_G = 10;   // 조색 RGB LED의 G핀
final int tLED_B = 11;   // 조색 RGB LED의 B핀

final int BUTTON = 13;   // 조색 버튼 핀

// 변수 정의
int redValue = 0;
int greenValue = 0;
int blueValue = 0;

boolean lastButtonState = false;
boolean ledOn = false;
int lastDebounceTime = 0;
final int DEBOUNCE_DELAY = 25;

void setup() {
  size(640, 480);
  
  // Arduino 연결
  println("사용 가능한 포트:");
  printArray(Arduino.list());
  
  try {
    arduino = new Arduino(this, Arduino.list()[0], 57600);
    println("Arduino 연결 성공: " + Arduino.list()[0]);
  } catch (Exception e) {
    println("Arduino 연결 실패: " + e.getMessage());
    exit();
  }
  
  // 디지털 핀 모드 설정 (PWM 핀들)
  arduino.pinMode(c2LED_R, Arduino.OUTPUT);
  arduino.pinMode(c2LED_G, Arduino.OUTPUT);
  arduino.pinMode(c2LED_B, Arduino.OUTPUT);
  arduino.pinMode(c3LED_R, Arduino.OUTPUT);
  arduino.pinMode(c3LED_G, Arduino.OUTPUT);
  arduino.pinMode(c3LED_B, Arduino.OUTPUT);
  arduino.pinMode(tLED_R, Arduino.OUTPUT);
  arduino.pinMode(tLED_G, Arduino.OUTPUT);
  arduino.pinMode(tLED_B, Arduino.OUTPUT);
  arduino.pinMode(BUTTON, Arduino.INPUT);
  
  // 아날로그 핀 모드 설정 (A3, A4, A5를 디지털 출력으로)
  arduino.pinMode(c1LED_R, Arduino.OUTPUT);  // A5
  arduino.pinMode(c1LED_G, Arduino.OUTPUT);  // A4
  arduino.pinMode(c1LED_B, Arduino.OUTPUT);  // A3
  
  // LED 초기화
  initializeLEDs();
  
  delay(100);
}

void draw() {
  background(50);
  
  // 가변저항 값 읽기
  int potR = arduino.analogRead(VAL_R);
  int potG = arduino.analogRead(VAL_G);
  int potB = arduino.analogRead(VAL_B);
  
  // 값 변환 (0-1023 → 0-255)
  redValue = (int)map(potR, 0, 1023, 0, 255);
  greenValue = (int)map(potG, 0, 1023, 0, 255);
  blueValue = (int)map(potB, 0, 1023, 0, 255);
  
  // 개별 컨트롤 LED 업데이트
  arduino.analogWrite(c1LED_R, redValue);
  arduino.analogWrite(c2LED_G, greenValue);
  arduino.analogWrite(c3LED_B, blueValue);
  
  // 버튼 상태 처리
  handleButton();
  
  // 조색 LED 제어
  if (ledOn) {
    arduino.analogWrite(tLED_R, redValue);
    arduino.analogWrite(tLED_G, greenValue);
    arduino.analogWrite(tLED_B, blueValue);
  } else {
    arduino.analogWrite(tLED_R, 0);
    arduino.analogWrite(tLED_G, 0);
    arduino.analogWrite(tLED_B, 0);
  }
  
  // 디버그 정보 출력
  printDebugInfo(potR, potG, potB);
}

void handleButton() {
  boolean currentButtonState = arduino.digitalRead(BUTTON) == Arduino.HIGH;
  
  // 디바운싱 및 버튼 토글
  if (currentButtonState != lastButtonState) {
    if (millis() - lastDebounceTime > DEBOUNCE_DELAY) {
      if (currentButtonState == false) {  // 버튼 눌림 (풀업 저항으로 LOW)
        ledOn = !ledOn;
        println("버튼 클릭 - LED 상태: " + (ledOn ? "ON" : "OFF"));
      }
      lastDebounceTime = millis();
    }
  }
  
  lastButtonState = currentButtonState;
}

void initializeLEDs() {
  // 모든 LED 끄기
  arduino.analogWrite(tLED_R, 0);
  arduino.analogWrite(tLED_G, 0);
  arduino.analogWrite(tLED_B, 0);
  arduino.analogWrite(c1LED_R, 0);
  arduino.analogWrite(c1LED_G, 0);
  arduino.analogWrite(c1LED_B, 0);
  arduino.analogWrite(c2LED_R, 0);
  arduino.analogWrite(c2LED_G, 0);
  arduino.analogWrite(c2LED_B, 0);
  arduino.analogWrite(c3LED_R, 0);
  arduino.analogWrite(c3LED_G, 0);
  arduino.analogWrite(c3LED_B, 0);
}

void printDebugInfo(int potR, int potG, int potB) {
  println("Pot값 - R:" + potR + " G:" + potG + " B:" + potB + 
          " | RGB - R:" + redValue + " G:" + greenValue + " B:" + blueValue + 
          " | LED: " + (ledOn ? "ON" : "OFF"));
}
