// Arduino UNO - Etch-A-Sketch 컨트롤러
// 가변저항: X축(A0), Y축(A2)

void setup() {
  Serial.begin(9600);
  // 아날로그 핀 초기화 (기본적으로 입력 모드)
}

void loop() {
  // A0(X축)과 A2(Y축)에서 아날로그 값 읽기
  int xValue = analogRead(A0);  // 0-1023 범위
  int yValue = analogRead(A2);  // 0-1023 범위
  
  // 시리얼로 X,Y 좌표 전송 (쉼표로 구분)
  Serial.print(xValue);
  Serial.print(",");
  Serial.println(yValue);
  
  // 약간의 딜레이로 시리얼 통신 안정화
  delay(10);
}