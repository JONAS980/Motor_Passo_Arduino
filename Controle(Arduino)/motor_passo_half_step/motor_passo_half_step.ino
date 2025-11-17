/*----------------------------------------------------------------------------------------------------------------- 
Programa    : motor_passo_half_step.ino
Data        : 17/11/2025
Autor       : Jonas Rocha
Descrição   : 
      # Motor_Passo_Arduino
      Controle Motor de Passo em modo Half-Step através de um Arduino Mega e com controle Através Interface Criada com Processing IDE(https://processing.org/) comunicando pela rede serial padrão do Arduino

      Hadware: || 
      1 Arduino Mega. ||
      1 Placa de reguladora de Tensão Com 1 saida 3.3V e 1 saida 5V. ||
      1 Driver Uln200. ||
      1 Motor De Passo 28byj-48. ||

      Projeto basico para testar aplicação de teste da Processing IDE(https://processing.org/)
-------------------------------------------------------------------------------------------------------------------*/


// --- Pinos de Controle do Motor ---
#define IN1 4
#define IN2 5
#define IN3 6
#define IN4 7

// --- Configurações do Motor (HALF-STEP) ---
const int stepsPerRevolution = 4096;
int currentStep = 0;
long passos_atuais = 0; 
int step_delay = 2; 

// Sequência de 8 passos (Half-Step)
int steps_seq[8][4] = {
  {HIGH, LOW,  LOW,  LOW},
  {HIGH, HIGH, LOW,  LOW},
  {LOW,  HIGH, LOW,  LOW},
  {LOW,  HIGH, HIGH, LOW},
  {LOW,  LOW,  HIGH, LOW},
  {LOW,  LOW,  HIGH, HIGH},
  {LOW,  LOW,  LOW,  HIGH},
  {HIGH, LOW,  LOW,  HIGH}
};

void setup() {
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);
  Serial.begin(9600);
  Serial.println("Arduino pronto (v11 - Volta Completa)");
}

void setStep(int s) {
  digitalWrite(IN1, steps_seq[s][0]);
  digitalWrite(IN2, steps_seq[s][1]);
  digitalWrite(IN3, steps_seq[s][2]);
  digitalWrite(IN4, steps_seq[s][3]);
}

void moveSteps(int steps) {
  boolean direcao = steps > 0;
  int steps_para_andar = abs(steps);

  for(int i = 0; i < steps_para_andar; i++) {
    if (direcao) {
      currentStep++;
      if (currentStep > 7) currentStep = 0; 
    } else {
      currentStep--;
      if (currentStep < 0) currentStep = 7;
    }
    setStep(currentStep);
    delay(step_delay); 
  }
}

void releaseMotor() {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, LOW);
  Serial.println("Motor desligado (bobinas livres).");
}

void loop() {
  if (Serial.available() > 0) {
    char cmd = Serial.peek();
    int grau_alvo = 0;
    long passos_alvo = 0;
    long passos_para_mover = 0;

    if (cmd == 'H' || cmd == 'T') { // 'H' Horário, 'T' Anti-Horário
      Serial.read(); // Consome o 'H' ou 'T'
      grau_alvo = Serial.parseInt();
      if (grau_alvo >= 360) grau_alvo = 0; // 360 é o mesmo que 0

      passos_alvo = (long)(grau_alvo * (stepsPerRevolution / 360.0) + 0.5);
      passos_para_mover = passos_alvo - passos_atuais;
      
      // --- NOVO BLOCO DE CÓDIGO (v11) ---
      // Se o motor já está na posição (movimento é 0)
      if (passos_para_mover == 0) {
        if (cmd == 'H') {
          passos_para_mover = stepsPerRevolution; // Adiciona uma volta completa
          Serial.println("Ja esta na posicao. Dando volta HORARIA...");
        } else { // cmd == 'T'
          passos_para_mover = -stepsPerRevolution; // Adiciona uma volta completa
          Serial.println("Ja esta na posicao. Dando volta ANTI-HORARIA...");
        }
      }
      // --- FIM DO NOVO BLOCO ---
      
      else { // Só executa se NÃO estava na posição (lógica antiga)
        if (cmd == 'H') { // FORÇA Sentido Horário (+)
          if (passos_para_mover < 0) {
            passos_para_mover += stepsPerRevolution;
          }
          Serial.print("Movendo HORARIO para "); Serial.print(grau_alvo); Serial.print(" graus...");
        } else { // FORÇA Sentido Anti-Horário (-)
          if (passos_para_mover > 0) {
            passos_para_mover -= stepsPerRevolution;
          }
          Serial.print("Movendo ANTI-HORARIO para "); Serial.print(grau_alvo); Serial.print(" graus...");
        }
      }
      
      moveSteps(passos_para_mover);
      passos_atuais = passos_alvo;

    } else if (cmd == 'C') { // Calibrar
      Serial.read();
      passos_atuais = 0; 
      Serial.println("CALIBRADO! Posicao atual = 0 graus.");
      
    } else if (cmd == '>') { // Nudge >
      Serial.read();
      int incremento = Serial.parseInt();
      moveSteps(incremento);
      passos_atuais += incremento;
      
    } else if (cmd == '<') { // Nudge <
      Serial.read();
      int incremento = Serial.parseInt();
      moveSteps(-incremento);
      passos_atuais -= incremento;
      
    } else if (cmd == 'V') { // Velocidade
      Serial.read();
      step_delay = Serial.parseInt();
      if (step_delay < 1) step_delay = 1; 
      Serial.print("Velocidade definida (delay): "); Serial.println(step_delay);
    
    } else if (cmd == 'D') { // Desligar
      Serial.read();
      releaseMotor();
      
    } else {
      Serial.read(); // Ignora
    }
    
    while(Serial.available() > 0) Serial.read(); // Limpa buffer
  }
}