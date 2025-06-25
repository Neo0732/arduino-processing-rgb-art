// RGB LED 3원색 조합 제어 - Processing 코드
// Arduino와 시리얼 통신으로 RGB LED 제어

import processing.serial.*;

Serial arduino;
String portName = "COM8"; // Arduino가 연결된 포트 (필요시 수정)

// RGB 값 변수
int rValue = 0;
int gValue = 0;
int bValue = 0;

// 화면 설정
int screenWidth = 640;
int screenHeight = 480;

// UI 요소
int colorPreviewSize = 150;
int channelPreviewSize = 80;
int margin = 20;

// 버튼 설정
int buttonWidth = 120;
int buttonHeight = 40;
int buttonX, buttonY;

// 폰트 설정
PFont font;

void setup() {
  size(640, 480);
  
  // 한글 폰트 로드
  try {
    font = createFont("AppleSDGothicNeoM.ttf", 16);
    textFont(font);
    println("한글 폰트 로드 성공: AppleSDGothicNeoM.ttf");
  } catch (Exception e) {
    println("한글 폰트 로드 실패. 기본 폰트를 사용합니다.");
    println("data 폴더에 AppleSDGothicNeoM.ttf 파일이 있는지 확인하세요.");
  }
  
  // 시리얼 포트 초기화
  try {
    arduino = new Serial(this, portName, 9600);
    arduino.bufferUntil('\n');
    println("Arduino 연결 성공: " + portName);
  } catch (Exception e) {
    println("Arduino 연결 실패. 포트를 확인하세요: " + portName);
    println("사용 가능한 포트:");
    printArray(Serial.list());
  }
  
  // 버튼 위치 설정
  buttonX = width - buttonWidth - margin;
  buttonY = height - buttonHeight - margin;
  
  // 기본 텍스트 설정
  textAlign(CENTER, CENTER);
  textSize(12);
  
  background(0);
}

void draw() {
  background(30);
  
  // 제목 표시
  fill(255);
  textSize(24);
  textAlign(CENTER);
  text("RGB LED 3원색 조합 제어", width/2, 30);
  
  // 현재 RGB 값 표시
  textSize(16);
  text("R: " + rValue + "  G: " + gValue + "  B: " + bValue, width/2, 60);
  
  // 메인 색상 미리보기 (큰 사각형)
  fill(rValue, gValue, bValue);
  stroke(255);
  strokeWeight(2);
  rect(width/2 - colorPreviewSize/2, 90, colorPreviewSize, colorPreviewSize);
  
  // RGB 개별 채널 미리보기
  int channelY = 260;
  int channelSpacing = (width - 3 * channelPreviewSize - 2 * margin) / 2;
  
  // R 채널 미리보기
  fill(rValue, 0, 0);
  rect(margin + channelSpacing/2, channelY, channelPreviewSize, channelPreviewSize);
  fill(255);
  textAlign(CENTER);
  textSize(14);
  text("R", margin + channelSpacing/2 + channelPreviewSize/2, channelY + channelPreviewSize + 15);
  text(rValue, margin + channelSpacing/2 + channelPreviewSize/2, channelY + channelPreviewSize + 30);
  
  // G 채널 미리보기
  fill(0, gValue, 0);
  rect(margin + channelSpacing/2 + channelPreviewSize + channelSpacing, channelY, channelPreviewSize, channelPreviewSize);
  fill(255);
  text("G", margin + channelSpacing/2 + channelPreviewSize + channelSpacing + channelPreviewSize/2, channelY + channelPreviewSize + 15);
  text(gValue, margin + channelSpacing/2 + channelPreviewSize + channelSpacing + channelPreviewSize/2, channelY + channelPreviewSize + 30);
  
  // B 채널 미리보기
  fill(0, 0, bValue);
  rect(margin + channelSpacing/2 + 2 * (channelPreviewSize + channelSpacing), channelY, channelPreviewSize, channelPreviewSize);
  fill(255);
  text("B", margin + channelSpacing/2 + 2 * (channelPreviewSize + channelSpacing) + channelPreviewSize/2, channelY + channelPreviewSize + 15);
  text(bValue, margin + channelSpacing/2 + 2 * (channelPreviewSize + channelSpacing) + channelPreviewSize/2, channelY + channelPreviewSize + 30);
  
  // 랜덤 버튼 그리기
  drawRandomButton();
  
  // 수동 제어 버튼 그리기
  drawManualButton();
  
  // 상태 정보 표시
  fill(200);
  textSize(12);
  textAlign(LEFT);
  text("가변저항으로 RGB 값을 조절하거나 랜덤 버튼을 클릭하세요", margin, height - 60);
  text("Arduino 핀 - 가변저항: R(A2), G(A1), B(A0) | 버튼: D13", margin, height - 45);
  text("결과 LED: R(9), G(10), B(11)", margin, height - 30);
  
  // 연결 상태 표시
  if (arduino != null) {
    fill(0, 255, 0);
    text("● Arduino 연결됨", margin, height - 15);
  } else {
    fill(255, 0, 0);
    text("● Arduino 연결 안됨", margin, height - 15);
  }
}

void drawRandomButton() {
  // 랜덤 버튼
  if (mouseX >= buttonX && mouseX <= buttonX + buttonWidth && 
      mouseY >= buttonY - 50 && mouseY <= buttonY - 50 + buttonHeight) {
    fill(80, 150, 255); // 호버 색상
  } else {
    fill(60, 120, 200); // 기본 색상
  }
  
  stroke(255);
  strokeWeight(1);
  rect(buttonX, buttonY - 50, buttonWidth, buttonHeight);
  
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(14);
  text("랜덤 색상", buttonX + buttonWidth/2, buttonY - 50 + buttonHeight/2);
}

void drawManualButton() {
  // 수동 제어 버튼
  if (mouseX >= buttonX && mouseX <= buttonX + buttonWidth && 
      mouseY >= buttonY && mouseY <= buttonY + buttonHeight) {
    fill(80, 200, 80); // 호버 색상
  } else {
    fill(60, 160, 60); // 기본 색상
  }
  
  stroke(255);
  strokeWeight(1);
  rect(buttonX, buttonY, buttonWidth, buttonHeight);
  
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(14);
  text("수동 제어", buttonX + buttonWidth/2, buttonY + buttonHeight/2);
}

void mousePressed() {
  // 랜덤 버튼 클릭 확인
  if (mouseX >= buttonX && mouseX <= buttonX + buttonWidth && 
      mouseY >= buttonY - 50 && mouseY <= buttonY - 50 + buttonHeight) {
    // 랜덤 RGB 값 생성
    rValue = (int)random(0, 256);
    gValue = (int)random(0, 256);
    bValue = (int)random(0, 256);
    
    // Arduino로 랜덤 값 전송
    if (arduino != null) {
      arduino.write("RANDOM:" + rValue + "," + gValue + "," + bValue + "\n");
    }
    
    println("랜덤 색상 생성: R=" + rValue + ", G=" + gValue + ", B=" + bValue);
  }
  
  // 수동 제어 버튼 클릭 확인
  if (mouseX >= buttonX && mouseX <= buttonX + buttonWidth && 
      mouseY >= buttonY && mouseY <= buttonY + buttonHeight) {
    // Arduino로 수동 모드 명령 전송
    if (arduino != null) {
      arduino.write("MANUAL\n");
    }
    println("수동 제어 모드로 전환");
  }
}

void serialEvent(Serial port) {
  if (port == arduino) {
    String inString = arduino.readStringUntil('\n');
    if (inString != null) {
      inString = trim(inString);
      
      // RGB 값 파싱
      if (inString.startsWith("RGB:")) {
        String rgbData = inString.substring(4);
        String[] values = split(rgbData, ',');
        if (values.length == 3) {
          rValue = int(values[0]);
          gValue = int(values[1]);
          bValue = int(values[2]);
        }
      }
      
      // 랜덤 값 파싱 (Arduino 버튼으로부터)
      if (inString.startsWith("RANDOM:")) {
        String randomData = inString.substring(7);
        String[] values = split(randomData, ',');
        if (values.length == 3) {
          rValue = int(values[0]);
          gValue = int(values[1]);
          bValue = int(values[2]);
          println("Arduino 버튼으로 랜덤 색상: R=" + rValue + ", G=" + gValue + ", B=" + bValue);
        }
      }
    }
  }
}

void keyPressed() {
  // 스페이스바로 랜덤 색상 생성
  if (key == ' ') {
    rValue = (int)random(0, 256);
    gValue = (int)random(0, 256);
    bValue = (int)random(0, 256);
    
    if (arduino != null) {
      arduino.write("RANDOM:" + rValue + "," + gValue + "," + bValue + "\n");
    }
    
    println("키보드로 랜덤 색상 생성: R=" + rValue + ", G=" + gValue + ", B=" + bValue);
  }
}
