import processing.serial.*; 

Serial myPort;

// --- Campos de Texto ---
String incrementoStr = "10";
boolean digitandoInc = false;
String velocStr = "2"; 
boolean digitandoVel = false;
String anguloStr = "90"; // NOVO CAMPO DE ÂNGULO
boolean digitandoAngulo = false;

// --- Coordenadas dos Botões e Campos ---
int centroX;
int btnCalibX, btnCalibY, btnCalibW, btnCalibH;
int btnNudgeLX, btnNudgeLY, btnNudgeW, btnNudgeH, btnNudgeRX, btnNudgeRY; 
int txtIncX, txtIncY, txtIncW, txtIncH;
int btnVelX, btnVelY, btnVelW, btnVelH;
int txtVelX, txtVelY, txtVelW, txtVelH;
int btnOffX, btnOffY, btnOffW, btnOffH;
int txtAngX, txtAngY, txtAngW, txtAngH;
int btnMoveHX, btnMoveHY, btnMoveW, btnMoveH; // Mover Horário
int btnMoveAX, btnMoveAY; // Mover Anti-Horário

void setup() {
  size(400, 500); // Podemos diminuir a altura, já que o relógio se foi
  centroX = width / 2;
  
  // ----- PORTA SERIAL -----
  printArray(Serial.list()); 
  String portName = Serial.list()[0]; // !!! MUDE O [0] SE PRECISAR !!!
  myPort = new Serial(this, portName, 9600);
  
  // --- POSIÇÕES DOS CONTROLES (de cima para baixo) ---
  
  // Botão "Confirmar 0°" 
  btnCalibW = 150;
  btnCalibH = 40;
  btnCalibX = centroX - (btnCalibW / 2);
  btnCalibY = 30; 
  
  // Campo "Incremento (passos)"
  txtIncW = 80;
  txtIncH = 40;
  txtIncX = centroX - (txtIncW / 2);
  txtIncY = btnCalibY + 70; // 100
  
  // Botões Nudge "<" e ">"
  btnNudgeW = 60;
  btnNudgeH = 40;
  btnNudgeLX = txtIncX - btnNudgeW - 10; 
  btnNudgeLY = txtIncY; 
  btnNudgeRX = txtIncX + txtIncW + 10; 
  btnNudgeRY = txtIncY;

  // Campo "Delay (ms)"
  txtVelW = 80;
  txtVelH = 40;
  txtVelX = centroX - (txtVelW/2);
  txtVelY = txtIncY + 70; // 170
  
  // Botão "Definir Velocidade"
  btnVelW = 150;
  btnVelH = 40;
  btnVelX = centroX - (btnVelW/2);
  btnVelY = txtVelY + 50; // 220
  
  // --- CONTROLES DE ÂNGULO ---
  // Campo "Ângulo Alvo"
  txtAngW = 100;
  txtAngH = 40;
  txtAngX = centroX - (txtAngW/2);
  txtAngY = btnVelY + 70; // 290
  
  // Botões de Mover
  btnMoveW = 160;
  btnMoveH = 50;
  btnMoveHX = centroX - btnMoveW - 10; // Botão da Esquerda
  btnMoveHY = txtAngY + 60; // 350
  btnMoveAX = centroX + 10; // Botão da Direita
  btnMoveAY = btnMoveHY;
  
  // Botão "Desligar Motor"
  btnOffW = 150;
  btnOffH = 40;
  btnOffX = centroX - (btnOffW / 2);
  btnOffY = btnMoveHY + 60; // 410
}

void draw() {
  background(240); 
  
  // Botão "Confirmar 0°"
  fill(0, 150, 255); noStroke();
  rect(btnCalibX, btnCalibY, btnCalibW, btnCalibH, 10);
  fill(255); textSize(18); textAlign(CENTER, CENTER);
  text("Calibração 0°", btnCalibX + btnCalibW/2, btnCalibY + btnCalibH/2);
  
  // Campo "Incremento"
  fill(255); 
  if (digitandoInc) stroke(0, 0, 255); else stroke(0); 
  rect(txtIncX, txtIncY, txtIncW, txtIncH, 5);
  fill(0); textSize(20);
  text(incrementoStr, txtIncX + txtIncW/2, txtIncY + txtIncH/2);
  fill(50); textSize(14);
  text("Incremento Manual (passos)", centroX, txtIncY - 15);
  
  // Botões Nudge "<" e ">"
  fill(150); noStroke();
  rect(btnNudgeLX, btnNudgeLY, btnNudgeW, btnNudgeH, 10);
  fill(0); textSize(24); text("<", btnNudgeLX + btnNudgeW/2, btnNudgeLY + btnNudgeH/2);
  fill(150); noStroke();
  rect(btnNudgeRX, btnNudgeRY, btnNudgeW, btnNudgeH, 10);
  fill(0); text(">", btnNudgeRX + btnNudgeW/2, btnNudgeRY + btnNudgeH/2);
  
  // Campo "Velocidade" (Delay)
  fill(255);
  if (digitandoVel) stroke(0, 0, 255); else stroke(0);
  rect(txtVelX, txtVelY, txtVelW, txtVelH, 5);
  fill(0); textSize(20);
  text(velocStr, txtVelX + txtVelW/2, txtVelY + txtVelH/2);
  fill(50); textSize(14);
  text("Delay entre passos (ms) [Maior=Lento]", centroX, txtVelY - 15);
  
  // Botão "Definir Velocidade"
  fill(0, 180, 0); noStroke();
  rect(btnVelX, btnVelY, btnVelW, btnVelH, 10);
  fill(255); textSize(18);
  text("Definir Velocidade", btnVelX + btnVelW/2, btnVelY + btnVelH/2);
  
  // --- CONTROLES DE ÂNGULO ---
  // Campo "Ângulo Alvo"
  fill(255);
  if (digitandoAngulo) stroke(0, 0, 255); else stroke(0);
  rect(txtAngX, txtAngY, txtAngW, txtAngH, 5);
  fill(0); textSize(20);
  text(anguloStr, txtAngX + txtAngW/2, txtAngY + txtAngH/2);
  fill(50); textSize(14);
  text("Ângulo Alvo (0-359)", centroX, txtAngY - 15);
  
  // Botão "Mover (Horário)"
  fill(60, 60, 200); noStroke(); // Azul escuro
  rect(btnMoveHX, btnMoveHY, btnMoveW, btnMoveH, 10);
  fill(255); textSize(18);
  text("Mover (Horário)", btnMoveHX + btnMoveW/2, btnMoveHY + btnMoveH/2);
  
  // Botão "Mover (Anti-horário)"
  fill(200, 60, 60); noStroke(); // Vermelho escuro
  rect(btnMoveAX, btnMoveAY, btnMoveW, btnMoveH, 10);
  fill(255); textSize(18);
  text("Mover (Anti-horário)", btnMoveAX + btnMoveW/2, btnMoveAY + btnMoveH/2);

  // Botão "Desligar Motor"
  fill(255, 100, 0); noStroke();
  rect(btnOffX, btnOffY, btnOffW, btnOffH, 10);
  fill(255); textSize(18);
  text("Desligar Motor", btnOffX + btnOffW/2, btnOffY + btnOffH/2);
}

// --- LÓGICA DE CLIQUE ---
void mousePressed() {
  // Desativa todos os campos de texto
  digitandoInc = false;
  digitandoVel = false;
  digitandoAngulo = false;

  // Verifica clique no campo Incremento
  if (mouseX > txtIncX && mouseX < (txtIncX + txtIncW) &&
      mouseY > txtIncY && mouseY < (txtIncY + txtIncH)) {
    digitandoInc = true; incrementoStr = ""; return;
  } 
  
  // Verifica clique no campo Velocidade
  if (mouseX > txtVelX && mouseX < (txtVelX + txtVelW) &&
      mouseY > txtVelY && mouseY < (txtVelY + txtVelH)) {
    digitandoVel = true; velocStr = ""; return;
  }
  
  // Verifica clique no campo Ângulo
  if (mouseX > txtAngX && mouseX < (txtAngX + txtAngW) &&
      mouseY > txtAngY && mouseY < (txtAngY + txtAngH)) {
    digitandoAngulo = true; anguloStr = ""; return;
  }

  // Botão "Confirmar 0°"
  if (mouseX > btnCalibX && mouseX < (btnCalibX + btnCalibW) &&
      mouseY > btnCalibY && mouseY < (btnCalibY + btnCalibH)) {
    myPort.write("C\n"); println(">>> COMANDO: Calibração 0"); return;
  }
  
  // Botão Nudge "<"
  if (mouseX > btnNudgeLX && mouseX < (btnNudgeLX + btnNudgeW) &&
      mouseY > btnNudgeLY && mouseY < (btnNudgeLY + btnNudgeH)) {
    myPort.write("<" + incrementoStr + "\n"); println(">>> COMANDO: Nudge <"); return;
  }
  
  // Botão Nudge ">"
  if (mouseX > btnNudgeRX && mouseX < (btnNudgeRX + btnNudgeW) &&
      mouseY > btnNudgeRY && mouseY < (btnNudgeRY + btnNudgeH)) {
    myPort.write(">" + incrementoStr + "\n"); println(">>> COMANDO: Nudge >"); return;
  }
  
  // Botão "Definir Velocidade"
  if (mouseX > btnVelX && mouseX < (btnVelX + btnVelW) &&
      mouseY > btnVelY && mouseY < (btnVelY + btnVelH)) {
    myPort.write("V" + velocStr + "\n"); println(">>> COMANDO: Velocidade = " + velocStr); return;
  }
  
  // --- NOVOS BOTÕES DE MOVER ---
  // Botão "Mover (Horário)"
  if (mouseX > btnMoveHX && mouseX < (btnMoveHX + btnMoveW) &&
      mouseY > btnMoveHY && mouseY < (btnMoveHY + btnMoveH)) {
    myPort.write("H" + anguloStr + "\n"); // Envia 'H' + ângulo
    println(">>> COMANDO: Mover HORARIO para " + anguloStr); return;
  }
  
  // Botão "Mover (Anti-horário)"
  if (mouseX > btnMoveAX && mouseX < (btnMoveAX + btnMoveW) &&
      mouseY > btnMoveAY && mouseY < (btnMoveAY + btnMoveH)) {
    myPort.write("T" + anguloStr + "\n"); // Envia 'T' + ângulo
    println(">>> COMANDO: Mover ANTI-HORARIO para " + anguloStr); return;
  }
  
  // Botão "Desligar Motor"
  if (mouseX > btnOffX && mouseX < (btnOffX + btnOffW) &&
      mouseY > btnOffY && mouseY < (btnOffY + btnOffH)) {
    myPort.write("D\n"); println(">>> COMANDO: Desligar Motor"); return;
  }
}

// --- FUNÇÃO PARA DIGITAR (Controla os 3 campos) ---
void keyTyped() {
  if (digitandoInc) { // Campo Incremento
    if (key >= '0' && key <= '9') incrementoStr += key;
    if (key == BACKSPACE && incrementoStr.length() > 0)
      incrementoStr = incrementoStr.substring(0, incrementoStr.length() - 1);
    if (key == ENTER || key == RETURN) {
      digitandoInc = false; if (incrementoStr.equals("")) incrementoStr = "1";
    }
  } else if (digitandoVel) { // Campo Velocidade
    if (key >= '0' && key <= '9') velocStr += key;
    if (key == BACKSPACE && velocStr.length() > 0)
      velocStr = velocStr.substring(0, velocStr.length() - 1);
    if (key == ENTER || key == RETURN) {
      digitandoVel = false; if (velocStr.equals("")) velocStr = "1";
      myPort.write("V" + velocStr + "\n"); println(">>> COMANDO: Velocidade = " + velocStr);
    }
  } else if (digitandoAngulo) { // Campo Ângulo
    if (key >= '0' && key <= '9') anguloStr += key;
    if (key == BACKSPACE && anguloStr.length() > 0)
      anguloStr = anguloStr.substring(0, anguloStr.length() - 1);
    if (key == ENTER || key == RETURN) {
      digitandoAngulo = false; if (anguloStr.equals("")) anguloStr = "0";
    }
  }
}
