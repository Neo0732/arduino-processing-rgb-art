// Arduino UNO - Etch-A-Sketch 컨트롤러
// 가변저항: X축(A0), Y축(A2)
// 누름스위치: 3번 핀 (화면 지우기)

const int BUTTON_PIN = 3;
bool lastButtonState = HIGH;
bool currentButtonState = HIGH;

void setup() {
  Serial.begin(9600);
  // 누름스위치 핀을 풀업 입력으로 설정
  pinMode(BUTTON_PIN, INPUT_PULLUP);
}

void loop() {
  // A0(X축)과 A2(Y축)에서 아날로그 값 읽기
  int xValue = analogRead(A0);  // 0-1023 범위
  int yValue = analogRead(A2);  // 0-1023 범위
  
  // 누름스위치 상태 확인 (디바운싱 포함)
  currentButtonState = digitalRead(BUTTON_PIN);
  
  // 버튼이 눌렸을 때 (HIGH에서 LOW로 변경)
  if (lastButtonState == HIGH && currentButtonState == LOW) {
    // 화면 지우기 신호 전송
    Serial.println("CLEAR");
    delay(50); // 디바운싱 딜레이
  }
  
  lastButtonState = currentButtonState;
  
  // 시리얼로 X,Y 좌표 전송 (쉼표로 구분)
  Serial.print(xValue);
  Serial.print(",");
  Serial.println(yValue);
  
  // 약간의 딜레이로 시리얼 통신 안정화
  delay(10);
}