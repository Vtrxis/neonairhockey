//Audios do jogo (importante instalar o minim, se não o jogo não vai rodar)
import ddf.minim.*;
Minim minim;
AudioSample sfxImpacto;
AudioSample sfxGol;
AudioSample sfxLaterais;
AudioPlayer trilha;

//Sprites e logos do jogo (todas contidas na pasta data)
PImage spriteP1;
PImage spriteP2;
PImage spriteD;
PImage iconLogo;
PImage iconPlay;
PImage iconPause;
PImage iconRec;
PImage[] numeros = new  PImage[8];

//score
int placarP1 = 0;
int placarP2 = 0;

//posições player1
float p1y = 360;
float p1x = 300;
//poisções p2
float p2x = 980;
float p2y = 360;

//inputs do usuário
boolean keyA, keyD, keyW, keyS = false;
boolean keyCima, keyBaixo, keyDir, keyEsq = false;

float playerSize = 85;
//posições do player e arena
float dX = 640;
float dY = 360;
float dVX = 10;
float dVY = 10;
float dSize = 40;
float golTopo  = 720/2 - 100;
float golBaixo = 720/2 + 100;

//state
int estado = 0;

//Fonte
PFont arcade;

//Recordes salvos
int[] recP1 = {0, 0, 0};
int[] recP2 = {0, 0, 0};
boolean recordeSalvo = false;

//Inicialização (imagens e audios)
void setup() {
  size(1280, 720);
  textAlign(CENTER);

  noSmooth();

  //Fonte
  arcade = createFont("arcade.ttf", 32);
  textFont(arcade);

  minim      = new Minim(this);
  sfxImpacto = minim.loadSample("impacto.wav");
  sfxGol     = minim.loadSample("gol.wav");
  sfxLaterais = minim.loadSample("Laterais.wav");
  trilha = minim.loadFile("trilha.wav");
  trilha.setGain(-12);
  trilha.loop();

  spriteP1 = loadImage("player1.png");
  spriteP2 = loadImage("player2.png");
  spriteD = loadImage("disco.png");
  iconLogo = loadImage("logo.png");
  imageMode(CENTER);
  iconPlay = loadImage("playbtn.png");
  imageMode(CENTER);
  iconPause = loadImage("pause.png");
  imageMode(CENTER);
  iconRec = loadImage("recbtn.png");
  //Carrega a imagens referente ao score do jogo, atualiza a cada e adiciona +1 a cada reset (quando ocorre um gol)
  for (int i = 0; i < 8; i++) {
    numeros[i] = loadImage(i + ".png");
  }
}
//estados do jogo
void draw() {
  background(0);

  if      (estado == 0) telaMenu();
  else if (estado == 1) telaJogo();
  else if (estado == 2) telaPausa();
  else if (estado == 3) telaFim();
  else if (estado == 4) telaRecordes();
}
//Menu principal
void telaMenu() {
  //Desenhos gerados para design da tela inicial
  noStroke();
  fill(57, 255, 20);

  rect(10, 10, width-20, 12);
  rect(10, height-22, width-20, 12);

  rect(10, 10, 12, height-20);
  rect(width-22, 10, 12, height-20);

  //Logos e icones menu inicial.
  image(iconLogo, 640, 220, 500, 400);
  image(iconPlay, width/2, 360, 250, 250);
  image(iconRec, width/2, 410, 250, 250);
  image(iconPause, width/2, 460, 250, 250);
}

//arena
void telaJogo() {
  noStroke();

  fill(57, 255, 20);

  rect(10, 10, width-20, 12);
  rect(10, height-22, width-20, 12);

  rect(10, 10, 12, golTopo-10);
  rect(10, golBaixo, 12, height-golBaixo-10);

  rect(width-22, 10, 12, golTopo-10);
  rect(width-22, golBaixo, 12, height-golBaixo-10);

  fill(180, 0, 255);
  rect(width/2 - 6, 10, 12, height-20);

  dX += dVX;
  dY += dVY;

  if (dY - dSize/2 < 10) {
    dY = 10 + dSize/2;
    dVY *= -1;
    sfxLaterais.trigger();
  }
  if (dY + dSize/2 > height - 10) {
    dY = height - 10 - dSize/2;
    dVY *= -1;
    sfxLaterais.trigger();
  }

  if (dX - dSize/2 < 10) {
    if (dY > golTopo && dY < golBaixo) {
      placarP2++;
      sfxGol.trigger();
      resetBall();
      if (placarP2 >= 7) {
        estado = 3;
        recordeSalvo = false;
      }
    } else {
      dX = 10 + dSize/2;
      dVX *= -1;
      sfxLaterais.trigger();
    }
  }
  if (dX + dSize/2 > width - 10) {
    if (dY > golTopo && dY < golBaixo) {
      placarP1++;
      sfxGol.trigger();
      resetBall();
      if (placarP1 >= 7) {
        estado = 3;
        recordeSalvo = false;
      }
    } else {
      dX = width - 10 - dSize/2;
      dVX *= -1;
      sfxLaterais.trigger();
    }
  }
  //colisão p1
  float d1 = dist(dX, dY, p1x, p1y);
  if (d1 < dSize/2 + playerSize/2 * 0.75 && d1 > 0) {
    float ax  = dX - p1x;
    float ay  = dY - p1y;
    float len = sqrt(ax*ax + ay*ay);
    dX  = p1x + (ax/len) * (dSize/2 + playerSize/2 * 0.75 + 1);
    dY  = p1y + (ay/len) * (dSize/2 + playerSize/2 * 0.75 + 1);
    dVX = (ax/len) * 8;
    dVY = (ay/len) * 8;
    sfxImpacto.trigger();
  }
  //colisão p2
  float d2 = dist(dX, dY, p2x, p2y);
  if (d2 < dSize/2 + playerSize/2 * 0.75 && d2 > 0) {
    float ax  = dX - p2x;
    float ay  = dY - p2y;
    float len = sqrt(ax*ax + ay*ay);
    dX  = p2x + (ax/len) * (dSize/2 + playerSize/2 * 0.75 + 1);
    dY  = p2y + (ay/len) * (dSize/2 + playerSize/2 * 0.75 + 1);
    dVX = (ax/len) * 8;
    dVY = (ay/len) * 8;
    sfxImpacto.trigger();
  }

  fill(0, 255, 100);
  noStroke();
  image(spriteD, dX, dY, dSize, dSize);

  fill(180, 0, 255);
  noStroke();
  if (keyW) p1y -= 12;
  if (keyS) p1y += 12;
  if (keyA) p1x -= 12;
  if (keyD) p1x += 12;
  if (p1x < 10 + playerSize/2) p1x = 10 + playerSize/2;
  if (p1y < 10 + playerSize/2) p1y = 10 + playerSize/2;
  if (p1y > height - 10 - playerSize/2) p1y = height - 10 - playerSize/2;
  if (p1x > width/2 - playerSize/2) p1x = width/2 - playerSize/2;
  image(spriteP1, p1x, p1y, playerSize, playerSize);

  fill(180, 0, 255);
  noStroke();
  if (keyCima)  p2y -= 12;
  if (keyBaixo) p2y += 12;
  if (keyEsq)   p2x -= 12;
  if (keyDir)   p2x += 12;
  if (p2x < width/2 + playerSize/2) p2x = width/2 + playerSize/2;
  if (p2x > width - 10 - playerSize/2) p2x = width - 10 - playerSize/2;
  if (p2y < 10 + playerSize/2) p2y = 10 + playerSize/2;
  if (p2y > height - 10 - playerSize/2) p2y = height - 10 - playerSize/2;
  image(spriteP2, p2x, p2y, playerSize, playerSize);

  image(numeros[placarP1], width/2 - 80, 50, 60, 60);
  image(numeros[placarP2], width/2 + 80, 50, 60, 60);
}

void telaPausa() {
  fill(0, 0, 0, 180);
  rect(0, 0, width, height);

  fill(57, 255, 20);
  textSize(70);
  text("PAUSADO", width/2, 300);

  fill(180, 0, 255);
  textSize(28);

  text("ESC  -  continuar", width/2, 390);
  text("M    -  menu", width/2, 435);
}

void telaFim() {
  if (!recordeSalvo) {
    salvarRecorde(placarP1, placarP2);
    recordeSalvo = true;
  }

  stroke(57, 255, 20);
  strokeWeight(6);
  noFill();
  line(10, 10, width-10, 10);
  line(10, height-10, width-10, height-10);
  line(10, 10, 10, height-10);
  line(width-10, 10, width-10, height-10);
  noStroke();

  int vencedor = (placarP1 >= 7) ? 1 : 2;
  fill(57, 255, 20);
  textSize(70);
  text("JOGADOR " + vencedor + " VENCEU!", width/2, 270);
  fill(180, 0, 255);
  textSize(40);
  text(placarP1 + "  -  " + placarP2, width/2, 360);
  textSize(26);
  text("ENTER  -  jogar novamente", width/2, 450);
  text("M      -  menu", width/2, 495);
}

void telaRecordes() {
  stroke(57, 255, 20);
  strokeWeight(6);
  noFill();
  line(10, 10, width-10, 10);
  line(10, height-10, width-10, height-10);
  line(10, 10, 10, height-10);
  line(width-10, 10, width-10, height-10);
  noStroke();

  fill(57, 255, 20);
  textSize(60);
  text("RECORDES", width/2, 180);
  fill(180, 0, 255);
  textSize(28);
  text("# 1      " + recP1[0] + " - " + recP2[0], width/2, 300);
  text("# 2      " + recP1[1] + " - " + recP2[1], width/2, 360);
  text("# 3      " + recP1[2] + " - " + recP2[2], width/2, 420);
  textSize(22);
  text("M  -  voltar ao menu", width/2, 560);
}

void salvarRecorde(int s1, int s2) {
  int novo = max(s1, s2);
  for (int i = 0; i < 3; i++) {
    int atual = max(recP1[i], recP2[i]);
    if (novo > atual) {
      for (int j = 2; j > i; j--) {
        recP1[j] = recP1[j-1];
        recP2[j] = recP2[j-1];
      }
      recP1[i] = s1;
      recP2[i] = s2;
      break;
    }
  }
}

void resetBall() {
  dX = width/2;
  dY = height/2;
  dVX = random(4, 6);
  dVY = random(-3, 3);
  if (random(1) < 0.5) dVX *= -1;
  p1x = 300;
  p1y = 360;
  p2x = 980;
  p2y = 360;
}

void resetarJogo() {
  placarP1 = 0;
  placarP2 = 0;
  p1x = 300;
  p1y = 360;
  p2x = 980;
  p2y = 360;
  resetBall();
}

void keyPressed() {
  if (key == 'w' || key =='W') keyW = true;
  if (key == 's' || key =='S') keyS = true;
  if (key == 'a' || key == 'A') keyA = true;
  if (key == 'd' || key == 'D') keyD = true;
  if (keyCode == UP)    keyCima  = true;
  if (keyCode == DOWN)  keyBaixo = true;
  if (keyCode == LEFT)  keyEsq   = true;
  if (keyCode == RIGHT) keyDir   = true;

  if (estado == 0) {
    if (keyCode == ENTER) {
      resetarJogo();
      estado = 1;
    }
    if (key == 'r' || key == 'R') estado = 4;
  }

  if (key == ESC) {
    key = 0;
    if (estado == 1) estado = 2;
    else if (estado == 2) estado = 1;
  }

  if (key == 'm' || key == 'M') {
    if (estado == 2 || estado == 3 || estado == 4) estado = 0;
  }

  if (keyCode == ENTER && estado == 3) {
    resetarJogo();
    estado = 1;
  }
}

void keyReleased() {
  if (key == 'w' || key =='W') keyW = false;
  if (key == 's' || key =='S') keyS = false;
  if (key == 'a' || key == 'A') keyA = false;
  if (key == 'd' || key == 'D') keyD = false;
  if (keyCode == UP)    keyCima  = false;
  if (keyCode == DOWN)  keyBaixo = false;
  if (keyCode == LEFT)  keyEsq   = false;
  if (keyCode == RIGHT) keyDir   = false;
}
