import processing.serial.*;

Serial arPort;

// 변수 정의
int ResultRedValue = 0;
int ResultGreenValue = 0;
int ResultBlueValue = 0;
boolean LEDon = false;

// 수신된 데이터 파싱을 위한 변수
String receivedData = "";

void setup() {
  size(640, 480);
  
  // 시리얼 포트 연결
  println("사용 가능한 포트:");
  printArray(Serial.list());
  
  try {
    arPort = new Serial(this, "COM8", 9600);
    arPort.bufferUntil('\n');  // 줄바꿈 문자까지 버퍼링
    println("시리얼 연결 성공: COM8");
  } catch (Exception e) {
    println("시리얼 연결 실패: " + e.getMessage());
    exit();
  }
  
  delay(2000);  // Arduino 초기화 대기
}

void draw() {
  background(50);
  
  // 화면에 현재 RGB 값과 LED 상태 표시
  fill(255);
  textAlign(LEFT);
  textSize(16);
  text("RGB 값:", 20, 30);
  text("R: " + ResultRedValue, 20, 60);
  text("G: " + ResultGreenValue, 20, 90);
  text("B: " + ResultBlueValue, 20, 120);
  text("LED 상태: " + (LEDon ? "ON" : "OFF"), 20, 150);
  
  // 현재 색상을 화면에 표시
  if (ledOn) {
    fill(redValue, greenValue, blueValue);
    rect(200, 50, 100, 100);
  } else {
    fill(100);
    rect(200, 50, 100, 100);
  }
  
  // 컨트롤 RGB 색상들 표시
  fill(redValue, 0, 0);
  rect(350, 30, 30, 30);
  text("R Control", 390, 50);
  
  fill(0, greenValue, 0);
  rect(350, 70, 30, 30);
  text("G Control", 390, 90);
  
  fill(0, 0, blueValue);
  rect(350, 110, 30, 30);
  text("B Control", 390, 130);
}

void serialEvent(Serial myPort) {
  // 시리얼 데이터 수신 처리
  receivedData = myPort.readStringUntil('\n');
  
  if (receivedData != null) {
    receivedData = trim(receivedData);
    
    // Arduino에서 보낸 데이터 파싱
    // 예상 형식: "R:255,G:128,B:64,LED:ON"
    if (receivedData.startsWith("R:")) {
      parseArduinoData(receivedData);
    }
  }
}

void parseArduinoData(String data) {
  try {
    // 데이터 파싱
    String[] parts = split(data, ',');
    
    for (String part : parts) {
      part = trim(part);
      
      if (part.startsWith("R:")) {
        redValue = int(part.substring(2));
      } else if (part.startsWith("G:")) {
        greenValue = int(part.substring(2));
      } else if (part.startsWith("B:")) {
        blueValue = int(part.substring(2));
      } else if (part.startsWith("LED:")) {
        ledOn = part.substring(4).equals("ON");
      }
    }
    
    // 디버그 출력
    println("수신된 데이터: " + data);
    println("파싱된 값 - R:" + redValue + " G:" + greenValue + " B:" + blueValue + " LED:" + ledOn);
    
  } catch (Exception e) {
    println("데이터 파싱 오류: " + e.getMessage());
  }
}

void keyPressed() {
  // 테스트를 위한 키보드 입력
  if (key == 's' || key == 'S') {
    // Arduino에 상태 요청 명령 보내기
    if (myPort != null) {
      myPort.write("STATUS\n");
    }
  } else if (key == 't' || key == 'T') {
    // Arduino에 LED 토글 명령 보내기
    if (myPort != null) {
      myPort.write("TOGGLE\n");
    }
  }
}

void mousePressed() {
  // 마우스 클릭으로 LED 토글
  if (myPort != null) {
    myPort.write("TOGGLE\n");
  }
}
