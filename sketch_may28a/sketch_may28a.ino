// RGB LED 가변저항 제어 코드
// 가변저항 3개로 RGB 값을 조절하고 버튼으로 LED 켜기

// 핀 정의
const int VAL_R = A0;    // R값을 위한 가변저항
const int VAL_G = A1;    // G값을 위한 가변저항  
const int VAL_B = A2;    // B값을 위한 가변저항
const int c1LED_R = A5;     // RGB LED의 R핀
const int c1LED_G = A4;    // RGB LED의 G핀
const int c1LED_B = A3;    // RGB LED의 B핀
const int c2LED_R = 3;     // RGB LED의 R핀
const int c2LED_G = 4;    // RGB LED의 G핀
const int c2LED_B = 5;    // RGB LED의 B핀
const int c3LED_R = 6;     // RGB LED의 R핀
const int c3LED_G = 7;    // RGB LED의 G핀
const int c3LED_B = 8;    // RGB LED의 B핀
const int tLED_R = 9;     // RGB LED의 R핀
const int tLED_G = 10;    // RGB LED의 G핀
const int tLED_B = 11;    // RGB LED의 B핀
const int BUTTON = 13;   // 버튼 핀

// 변수 정의
int redValue = 0;
int greenValue = 0;
int blueValue = 0;
int ctrl1r = 0;
int ctrl1g = 0;
int ctrl1b = 0;
int ctrl2r = 0;
int ctrl2g = 0;
int ctrl2b = 0;
int ctrl3r = 0;
int ctrl3g = 0;
int ctrl3b = 0;
bool buttonPressed = false;
bool lastButtonState = false;
bool ledOn = false;

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
  pinMode(BUTTON, INPUT_PULLUP);  // 내부 풀업 저항 사용
  
  // 시리얼 통신 시작 (디버깅용)
  Serial.begin(9600);
  
  // LED 초기화 (꺼진 상태)
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

void loop() {
  // 가변저항 값 읽기 (0-1023)
  int potR = analogRead(VAL_R);
  int potG = analogRead(VAL_G);
  int potB = analogRead(VAL_B);
  
  // 0-1023 값을 0-255 값으로 변환 (PWM 범위)
  redValue = map(potR, 0, 1023, 0, 255);
  greenValue = map(potG, 0, 1023, 0, 255);
  blueValue = map(potB, 0, 1023, 0, 255);

  analogWrite(c1LED_R, redValue);
  analogWrite(c2LED_G, greenValue);
  analogWrite(c3LED_B, blueValue);
  
  // 버튼 상태 읽기 (풀업 저항 사용으로 LOW가 눌린 상태)
  bool currentButtonState = digitalRead(BUTTON);
  
  // 버튼이 눌렸을 때 (falling edge 감지)
  if (lastButtonState == HIGH && currentButtonState == LOW) {
    ledOn = !ledOn;  // LED 상태 토글
    delay(25);       // 디바운싱
  }
  
  lastButtonState = currentButtonState;
  
  // LED 제어
  if (ledOn) {
    // 버튼이 눌려있을 때 조합된 RGB 값으로 LED 켜기

    while (redValue+greenValue+blueValue <= 0) {
      analogWrite(c1LED_R, redValue -1);
      analogWrite(c2LED_G, greenValue -1);
      analogWrite(c3LED_B, blueValue -1);
    }

    analogWrite(tLED_R, redValue);
    analogWrite(tLED_G, greenValue);
    analogWrite(tLED_B, blueValue);

  } else {
    // 버튼이 안 눌려있을 때 LED 끄기
    analogWrite(tLED_R, 0);
    analogWrite(tLED_G, 0);
    analogWrite(tLED_B, 0);
  }
  
  // 시리얼 모니터로 현재 값 출력 (디버깅용)
  Serial.print("R: ");
  Serial.print(redValue);
  Serial.print(", G: ");
  Serial.print(greenValue);
  Serial.print(", B: ");
  Serial.print(blueValue);
  Serial.print(", LED: ");
  Serial.println(ledOn ? "ON" : "OFF");
  
  delay(50);  // 안정성을 위한 딜레이
}