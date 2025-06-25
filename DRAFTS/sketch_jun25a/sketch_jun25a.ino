// RGB LED 3원색 조합 제어 - Arduino 코드
// 가변저항으로 RGB 값 조절, 버튼으로 랜덤 색상 생성

// 핀 정의
// 가변저항 핀
const int POT_R = A2;
const int POT_G = A1;
const int POT_B = A0;

// R 미리보기 LED 핀 (빨간색 채널 미리보기)
const int R_PREVIEW_R = A3;
const int R_PREVIEW_G = 2;
const int R_PREVIEW_B = 3;

// G 미리보기 LED 핀 (초록색 채널 미리보기)
const int G_PREVIEW_R = 4;
const int G_PREVIEW_G = A4;
const int G_PREVIEW_B = 5;

// B 미리보기 LED 핀 (파란색 채널 미리보기)
const int B_PREVIEW_R = 6;
const int B_PREVIEW_G = 7;
const int B_PREVIEW_B = A5;

// 결과 LED 핀 (최종 RGB 조합)
const int RESULT_R = 9;
const int RESULT_G = 10;
const int RESULT_B = 11;

// 버튼 핀
const int BUTTON = 13;

// 변수 선언
int rValue = 0, gValue = 0, bValue = 0;
int lastButtonState = HIGH;
int buttonState = HIGH;
bool randomMode = false;
int randomR = 0, randomG = 0, randomB = 0;

void setup() {
  Serial.begin(9600);
  
  // PWM 지원 핀들만 pinMode 설정 (analogWrite는 자동으로 OUTPUT 모드 설정)
  // 아날로그 핀들(A3, A4, A5)은 analogWrite 사용 시 자동으로 OUTPUT 설정됨
  
  // PWM 지원 디지털 핀들을 출력으로 설정
  pinMode(R_PREVIEW_G, OUTPUT);  // 핀 2 (PWM 지원)
  pinMode(R_PREVIEW_B, OUTPUT);  // 핀 3 (PWM 지원)
  pinMode(G_PREVIEW_R, OUTPUT);  // 핀 4 (PWM 미지원이지만 디지털 출력)
  pinMode(G_PREVIEW_B, OUTPUT);  // 핀 5 (PWM 지원)
  pinMode(B_PREVIEW_R, OUTPUT);  // 핀 6 (PWM 지원)
  pinMode(B_PREVIEW_G, OUTPUT);  // 핀 7 (PWM 미지원이지만 디지털 출력)
  
  // 결과 LED 핀들 (모두 PWM 지원)
  pinMode(RESULT_R, OUTPUT);     // 핀 9 (PWM 지원)
  pinMode(RESULT_G, OUTPUT);     // 핀 10 (PWM 지원)
  pinMode(RESULT_B, OUTPUT);     // 핀 11 (PWM 지원)
  
  // 버튼 핀을 입력으로 설정 (내부 풀업 저항 사용)
  pinMode(BUTTON, INPUT_PULLUP);
  
  // 랜덤 시드 설정
  randomSeed(analogRead(A6));
}

void loop() {
  // 버튼 상태 확인
  buttonState = digitalRead(BUTTON);
  
  // 버튼이 눌렸을 때 (하강 엣지 감지)
  if (lastButtonState == HIGH && buttonState == LOW) {
    // 랜덤 RGB 값 생성
    randomR = random(0, 256);
    randomG = random(0, 256);
    randomB = random(0, 256);
    randomMode = true;
    
    // Processing으로 랜덤 값 전송
    Serial.print("RANDOM:");
    Serial.print(randomR);
    Serial.print(",");
    Serial.print(randomG);
    Serial.print(",");
    Serial.println(randomB);
    
    delay(50); // 디바운싱
  }
  
  lastButtonState = buttonState;
  
  // Processing으로부터 명령 수신 처리
  if (Serial.available() > 0) {
    String command = Serial.readStringUntil('\n');
    command.trim();
    
    if (command == "MANUAL") {
      randomMode = false;
    }
  }
  
  // 가변저항 값 읽기 (0-1023을 0-255로 변환)
  if (!randomMode) {
    rValue = map(analogRead(POT_R), 0, 1023, 0, 255);
    gValue = map(analogRead(POT_G), 0, 1023, 0, 255);
    bValue = map(analogRead(POT_B), 0, 1023, 0, 255);
  } else {
    rValue = randomR;
    gValue = randomG;
    bValue = randomB;
  }
  
  // 미리보기 LED 제어 (PWM 지원 핀은 analogWrite, 미지원 핀은 digitalWrite 사용)
  // R 채널 미리보기 (빨간색만 표시)
  analogWrite(R_PREVIEW_R, rValue);     // A3 (아날로그 핀, analogWrite 지원)
  analogWrite(R_PREVIEW_G, 0);          // 핀 2 (PWM 지원)
  analogWrite(R_PREVIEW_B, 0);          // 핀 3 (PWM 지원)
  
  // G 채널 미리보기 (초록색만 표시)
  digitalWrite(G_PREVIEW_R, LOW);       // 핀 4 (PWM 미지원, 디지털 출력만)
  analogWrite(G_PREVIEW_G, gValue);     // A4 (아날로그 핀, analogWrite 지원)
  analogWrite(G_PREVIEW_B, 0);          // 핀 5 (PWM 지원)
  
  // B 채널 미리보기 (파란색만 표시)
  analogWrite(B_PREVIEW_R, 0);          // 핀 6 (PWM 지원)
  digitalWrite(B_PREVIEW_G, LOW);       // 핀 7 (PWM 미지원, 디지털 출력만)
  analogWrite(B_PREVIEW_B, bValue);     // A5 (아날로그 핀, analogWrite 지원)
  
  // 결과 LED 제어 (RGB 조합)
  analogWrite(RESULT_R, rValue);
  analogWrite(RESULT_G, gValue);
  analogWrite(RESULT_B, bValue);
  
  // Processing으로 현재 RGB 값 전송
  Serial.print("RGB:");
  Serial.print(rValue);
  Serial.print(",");
  Serial.print(gValue);
  Serial.print(",");
  Serial.println(bValue);
  
  delay(50); // 안정적인 통신을 위한 딜레이
}