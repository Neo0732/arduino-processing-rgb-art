// Arduino 시리얼 통신 RGB LED 제어 코드

// 핀 정의
const int VAL_R = A0;    // R값을 위한 가변저항
const int VAL_G = A1;    // G값을 위한 가변저항  
const int VAL_B = A2;    // B값을 위한 가변저항

const int c1LED_R = A5;  // R 제어용 RGB LED의 R핀
const int c1LED_G = A4;  // R 제어용 RGB LED의 G핀
const int c1LED_B = A3;  // R 제어용 RGB LED의 B핀

const int c2LED_R = 3;   // G 제어용 RGB LED의 R핀
const int c2LED_G = 4;   // G 제어용 RGB LED의 G핀
const int c2LED_B = 5;   // G 제어용 RGB LED의 B핀

const int c3LED_R = 6;   // B 제어용 RGB LED의 R핀
const int c3LED_G = 7;   // B 제어용 RGB LED의 G핀
const int c3LED_B = 8;   // B 제어용 RGB LED의 B핀

const int tLED_R = 9;    // 조색 RGB LED의 R핀
const int tLED_G = 10;   // 조색 RGB LED의 G핀
const int tLED_B = 11;   // 조색 RGB LED의 B핀

const int BUTTON = 13;   // 조색 버튼 핀

// 변수 정의
int redValue = 0;
int greenValue = 0;
int blueValue = 0;

bool lastButtonState = false;
bool ledOn = false;
unsigned long lastDebounceTime = 0;
const unsigned long DEBOUNCE_DELAY = 50;

String inputString = "";
bool stringComplete = false;

void setup() {
  // 핀 모드 설정
  pinMode(tLED_R, OUTPUT);
  pinMode(tLED_G, OUTPUT);
  pinMode(tLED_B, OUTPUT);
  pinMode(c1LED_R, OUTPUT);
  pinMode(c1LED_G, OUTPUT);
  pinMode(c1LED_B, OUTPUT);
  pinMode(c2LED_R, OUTPUT);
  pinMode(c2LED_G, OUTPUT);
  pinMode(c2LED_B, OUTPUT);
  pinMode(c3LED_R, OUTPUT);
  pinMode(c3LED_G, OUTPUT);
  pinMode(c3LED_B, OUTPUT);
  pinMode(BUTTON, INPUT_PULLUP);
  
  // 시리얼 통신 시작
  Serial.begin(9600);
  Serial.println("Arduino RGB LED Controller Ready");
  
  // LED 초기화
  initializeLEDs();
  
  // 초기 상태 전송
  sendStatusToProcessing();
}

void loop() {
  // 가변저항 값 읽기
  readPotentiometers();
  
  // 개별 컨트롤 LED 업데이트
  updateControlLEDs();
  
  // 버튼 처리
  handleButton();
  
  // 조색 LED 제어
  updateMainLED();
  
  // Processing으로 데이터 전송 (100ms마다)
  static unsigned long lastSendTime = 0;
  if (millis() - lastSendTime > 100) {
    sendStatusToProcessing();
    lastSendTime = millis();
  }
  
  // 시리얼 명령 처리
  handleSerialCommands();
  
  delay(10);
}

void readPotentiometers() {
  int potR = analogRead(VAL_R);
  int potG = analogRead(VAL_G);
  int potB = analogRead(VAL_B);
  
  redValue = map(potR, 0, 1023, 0, 255);
  greenValue = map(potG, 0, 1023, 0, 255);
  blueValue = map(potB, 0, 1023, 0, 255);
}

void updateControlLEDs() {
  // R 컨트롤 LED (빨간색만)
  analogWrite(c1LED_R, redValue);
  analogWrite(c1LED_G, 0);
  analogWrite(c1LED_B, 0);
  
  // G 컨트롤 LED (초록색만)
  analogWrite(c2LED_R, 0);
  analogWrite(c2LED_G, greenValue);
  analogWrite(c2LED_B, 0);
  
  // B 컨트롤 LED (파란색만)
  analogWrite(c3LED_R, 0);
  analogWrite(c3LED_G, 0);
  analogWrite(c3LED_B, blueValue);
}

void updateMainLED() {
  if (ledOn) {
    analogWrite(tLED_R, redValue);
    analogWrite(tLED_G, greenValue);
    analogWrite(tLED_B, blueValue);
  } else {
    analogWrite(tLED_R, 0);
    analogWrite(tLED_G, 0);
    analogWrite(tLED_B, 0);
  }
}

void handleButton() {
  bool currentButtonState = digitalRead(BUTTON);
  
  if (currentButtonState != lastButtonState) {
    lastDebounceTime = millis();
  }
  
  if ((millis() - lastDebounceTime) > DEBOUNCE_DELAY) {
    if (currentButtonState == LOW && lastButtonState == HIGH) {
      ledOn = !ledOn;
      Serial.println("Button pressed - LED: " + String(ledOn ? "ON" : "OFF"));
    }
  }
  
  lastButtonState = currentButtonState;
}

void sendStatusToProcessing() {
  Serial.print("R:");
  Serial.print(redValue);
  Serial.print(",G:");
  Serial.print(greenValue);
  Serial.print(",B:");
  Serial.print(blueValue);
  Serial.print(",LED:");
  Serial.println(ledOn ? "ON" : "OFF");
}

void handleSerialCommands() {
  while (Serial.available()) {
    char inChar = (char)Serial.read();
    
    if (inChar == '\n') {
      stringComplete = true;
    } else {
      inputString += inChar;
    }
  }
  
  if (stringComplete) {
    inputString.trim();
    
    if (inputString == "STATUS") {
      sendStatusToProcessing();
    } else if (inputString == "TOGGLE") {
      ledOn = !ledOn;
      Serial.println("Remote toggle - LED: " + String(ledOn ? "ON" : "OFF"));
    }
    
    inputString = "";
    stringComplete = false;
  }
}

void initializeLEDs() {
  analogWrite(tLED_R, 0);
  analogWrite(tLED_G, 0);
  analogWrite(tLED_B, 0);
  analogWrite(c1LED_R, 0);
  analogWrite(c1LED_G, 0);
  analogWrite(c1LED_B, 0);
  analogWrite(c2LED_R, 0);
  analogWrite(c2LED_G, 0);
  analogWrite(c2LED_B, 0);
  analogWrite(c3LED_R, 0);
  analogWrite(c3LED_G, 0);
  analogWrite(c3LED_B, 0);
}