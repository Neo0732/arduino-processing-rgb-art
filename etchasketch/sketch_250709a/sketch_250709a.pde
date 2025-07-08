// Processing - 디지털 Etch-A-Sketch
// 1200x1000 크기, 검은 배경에 흰 점으로 그리기
// 스페이스키로 화면 지우기 (점멸 효과 포함)

import processing.serial.*;

Serial myPort;
int x = 600;  // 중앙 시작점
int y = 500;  // 중앙 시작점
int prevX = 600;
int prevY = 500;

boolean isClearing = false;
int clearTimer = 0;
int clearDuration = 300; // 점멸 지속 시간 (밀리초)

void setup() {
  size(1000, 600);
  background(0);  // 검은 배경
  
  // 시리얼 포트 설정
  println("사용 가능한 시리얼 포트:");
  printArray(Serial.list());
  
  // COM4 포트에 연결된 Arduino UNO 사용
  String portName = "COM4";
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');
}

void draw() {
  // 화면 지우기 애니메이션 처리
  if (isClearing) {
    int elapsed = millis() - clearTimer;
    if (elapsed < clearDuration) {
      // 빠른 점멸 효과 (100ms 간격)
      if ((elapsed / 100) % 2 == 0) {
        background(255);  // 흰색
      } else {
        background(0);    // 검은색
      }
    } else {
      // 점멸 완료 후 검은 화면으로 복귀
      background(0);
      isClearing = false;
      // 커서 위치 초기화
      x = 600;
      y = 500;
      prevX = x;
      prevY = y;
    }
  }
  
  // 현재 커서 위치에 작은 흰 점 표시 (Etch-A-Sketch 커서 효과)
  if (!isClearing) {
    stroke(100);
    strokeWeight(5);
    point(x, y);
  }
}

void serialEvent(Serial myPort) {
  if (!isClearing) {  // 지우기 중이 아닐 때만 처리
    String inString = myPort.readStringUntil('\n');
    
    if (inString != null) {
      inString = trim(inString);
      
      // 화면 지우기 신호 확인
      if (inString.equals("CLEAR")) {
        clearScreen();
        return;
      }
      
      String[] values = split(inString, ',');
      
      if (values.length == 2) {
        // Arduino 아날로그 값 (0-1023)을 화면 좌표로 변환
        int newX = (int)map(int(values[0]), 0, 1023, 0, width);
        int newY = (int)map(int(values[1]), 0, 1023, 0, height);
        
        // 이전 위치에서 현재 위치까지 선 그리기
        stroke(255);  // 흰색
        strokeWeight(2);
        line(prevX, prevY, newX, newY);
        
        // 위치 업데이트
        prevX = x;
        prevY = y;
        x = newX;
        y = newY;
      }
    }
  }
}

void keyPressed() {
  if (key == ' ') {  // 스페이스바로 화면 지우기
    clearScreen();
  }
}

// 화면 지우기 함수
void clearScreen() {
  isClearing = true;
  clearTimer = millis();
}

// 마우스로도 테스트 가능 (Arduino 없이 테스트할 때)
void mouseDragged() {
  if (!isClearing) {
    stroke(255);
    strokeWeight(2);
    line(pmouseX, pmouseY, mouseX, mouseY);
  }
}