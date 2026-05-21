//Imports do minim (responsavel pelos audios do game, quando for testar é necessário instalar a biblioteca)
import ddf.minim.*;
Minim minim;
AudioSample sfxImpacto;
AudioSample sfxGol;
AudioSample sfxLaterais;

//Sprites do disco e dos jogadores
PImage spriteP1;
PImage spriteP2;
PImage spriteD;

//placar do jogo
int placarP1 = 0;
int placarP2 = 0;

//posição do jogador 1
float p1x = 300;
float p1y = 360;

// pos do jogador2
float p2x = 980;
float p2y = 360;

//movimentação (binds)
boolean keyA, keyD, keyW, keyS = false;
boolean keyCima, keyBaixo, keyDir, keyEsq = false;

//tamanho dos players
float playerSize = 85;

// disco
float dX = 640;
float dY = 360;
float dVX = 5;
float dVY = 5;
float dSize = 40;
float golTopo  = 720/2 - 100;
float golBaixo = 720/2 + 100;

// estados: 0=menu 1=jogando 2=pausado 3=fim 4=recordes
int estado = 0;

// recordes
int[] recP1 = {0, 0, 0};
int[] recP2 = {0, 0, 0};
boolean recordeSalvo = false;

//Carregando os efeitos sonoros e os sprites.
void setup() {
  size(1280, 720);
  textAlign(CENTER);
  minim      = new Minim(this);
  sfxImpacto = minim.loadSample("impacto.wav");
  sfxGol     = minim.loadSample("gol.wav");
  sfxLaterais = minim.loadSample("Laterais.wav");

  spriteP1 = loadImage("player1.png");
  spriteP2 = loadImage("player2.png");
  spriteD = loadImage("disco.png");
}

void draw() {
  background(0);

//estados
  if      (estado == 0) telaMenu();
  else if (estado == 1) telaJogo();
  else if (estado == 2) telaPausa();
  else if (estado == 3) telaFim();
  else if (estado == 4) telaRecordes();
}

// Menu principal
void telaMenu() {
  stroke(0, 255, 100);
  strokeWeight(6);
  noFill();
  line(10, 10, width-10, 10);
  line(10, height-10, width-10, height-10);
  line(10, 10, 10, height-10);
  line(width-10, 10, width-10, height-10);
  noStroke();

  fill(0, 255, 100);
  textSize(80);
  text("NEON AIR HOCKEY", width/2, 220);

  fill(200, 100, 255);
  textSize(30);
  text("ENTER  -  JOGAR", width/2, 360);
  text("R      -  RECORDES", width/2, 410);
  text("ESC    -  PAUSAR (durante o jogo)", width/2, 460);

  if ((frameCount / 30) % 2 == 0) {
    fill(0, 255, 100);
    textSize(20);
    text("pressione ENTER para comecar", width/2, 560);
  }
}

// MESA
void telaJogo() {
  // mesa do jogo
  stroke(0, 255, 100);
  strokeWeight(6);
  noFill();
  line(10, 10, width - 10, 10);
  line(10, height - 10, width - 10, height - 10);
  line(10, 10, 10, golTopo);
  line(10, golBaixo, 10, height - 10);
  line(width - 10, 10, width - 10, golTopo);
  line(width - 10, golBaixo, width - 10, height - 10);
  stroke(200, 100, 255);
  line(width/2, 10, width/2, height - 10);
  noStroke();

  //disco (movimentação)
  dX += dVX;
  dY += dVY;

  // paredes topo e baixo
  if (dY - dSize/2 < 10) {
    dY = 10 + dSize/2;
    dVY *= -1;
    sfxImpacto.trigger();
  }
  if (dY + dSize/2 > height - 10) {
    dY = height - 10 - dSize/2;
    dVY *= -1;
    sfxLaterais.trigger();
  }

  // paredes laterais
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

  // colisão do disco com players
  float c1x = p1x + playerSize/2;
  float c1y = p1y + playerSize/2;
  float d1  = dist(dX, dY, c1x, c1y);
  if (d1 < dSize/2 + playerSize/2 * 0.75 && d1 > 0) {
    float ax  = dX - c1x;
    float ay  = dY - c1y;
    float len = sqrt(ax*ax + ay*ay);
    dX  = c1x + (ax/len) * (dSize/2 + playerSize/2 * 0.75 + 1);
    dY  = c1y + (ay/len) * (dSize/2 + playerSize/2 * 0.75 + 1);
    dVX = (ax/len) * 8;
    dVY = (ay/len) * 8;
    sfxImpacto.trigger();
  }

  float c2x = p2x + playerSize/2;
  float c2y = p2y + playerSize/2;
  float d2  = dist(dX, dY, c2x, c2y);
  if (d2 < dSize/2 + playerSize/2 * 0.75 && d2 > 0) {
    float ax  = dX - c2x;
    float ay  = dY - c2y;
    float len = sqrt(ax*ax + ay*ay);
    dX  = c2x + (ax/len) * (dSize/2 + playerSize/2 * 0.75 + 1);
    dY  = c2y + (ay/len) * (dSize/2 + playerSize/2 * 0.75 + 1);
    dVX = (ax/len) * 8;
    dVY = (ay/len) * 8;
    sfxImpacto.trigger();
  }

  // desenha disco
  fill(0, 255, 100);
  noStroke();
  image(spriteD, dX, dY, dSize, dSize);

  //jogador 1
  fill(200, 100, 255);
  noStroke();
  image(spriteP1, p1x, p1y, playerSize, playerSize);
  if (keyW) p1y -= 9;
  if (keyS) p1y += 9;
  if (keyA) p1x -= 9;
  if (keyD) p1x += 9;
  if (p1x < 10) p1x = 10;
  if (p1y < 10) p1y = 10;
  if (p1y > height - playerSize - 10) p1y = height - playerSize - 10;
  if (p1x > width/2 - playerSize) p1x = width/2 - playerSize;

  //jogador 2
  fill(200, 100, 255);
  noStroke();
  image(spriteP2, p2x, p2y, playerSize, playerSize);
  if (keyCima)  p2y -= 9;
  if (keyBaixo) p2y += 9;
  if (keyEsq)   p2x -= 9;
  if (keyDir)   p2x += 9;
  if (p2x < width/2) p2x = width/2;
  if (p2x > width - playerSize - 10) p2x = width - playerSize - 10;
  if (p2y < 10) p2y = 10;
  if (p2y > height - playerSize - 10) p2y = height - playerSize - 10;

  //placar
  fill(0, 255, 100);
  textSize(40);
  textAlign(CENTER);
  text(placarP1 + "  -  " + placarP2, width/2, 60);
}

// Tela de Pausa
void telaPausa() {
  stroke(0, 255, 100);
  strokeWeight(6);
  noFill();
  line(10, 10, width-10, 10);
  line(10, height-10, width-10, height-10);
  line(10, 10, 10, golTopo);
  line(10, golBaixo, 10, height-10);
  line(width-10, 10, width-10, golTopo);
  line(width-10, golBaixo, width-10, height-10);
  stroke(200, 100, 255);
  line(width/2, 10, width/2, height-10);
  noStroke();
  fill(0, 255, 100);
  ellipse(dX, dY, dSize, dSize);
  fill(200, 100, 255);
  square(p1x, p1y, playerSize);
  square(p2x, p2y, playerSize);
  fill(0, 255, 100);
  textSize(40);
  text(placarP1 + "  -  " + placarP2, width/2, 60);

  fill(0, 0, 0, 180);
  rect(0, 0, width, height);

  fill(0, 255, 100);
  textSize(70);
  text("PAUSADO", width/2, 300);
  fill(200, 100, 255);
  textSize(28);
  text("ESC  -  continuar", width/2, 390);
  text("M    -  menu", width/2, 435);
}

//
void telaFim() {
  if (!recordeSalvo) {
    salvarRecorde(placarP1, placarP2);
    recordeSalvo = true;
  }

  stroke(0, 255, 100);
  strokeWeight(6);
  noFill();
  line(10, 10, width-10, 10);
  line(10, height-10, width-10, height-10);
  line(10, 10, 10, height-10);
  line(width-10, 10, width-10, height-10);
  noStroke();

  int vencedor = (placarP1 >= 7) ? 1 : 2;
  fill(0, 255, 100);
  textSize(70);
  text("JOGADOR " + vencedor + " VENCEU!", width/2, 270);
  fill(200, 100, 255);
  textSize(40);
  text(placarP1 + "  -  " + placarP2, width/2, 360);
  textSize(26);
  text("ENTER  -  jogar novamente", width/2, 450);
  text("M      -  menu", width/2, 495);
}

// Recordes
void telaRecordes() {
  stroke(0, 255, 100);
  strokeWeight(6);
  noFill();
  line(10, 10, width-10, 10);
  line(10, height-10, width-10, height-10);
  line(10, 10, 10, height-10);
  line(width-10, 10, width-10, height-10);
  noStroke();

  fill(0, 255, 100);
  textSize(60);
  text("RECORDES", width/2, 180);
  fill(200, 100, 255);
  textSize(28);
  text("# 1      " + recP1[0] + " - " + recP2[0], width/2, 300);
  text("# 2      " + recP1[1] + " - " + recP2[1], width/2, 360);
  text("# 3      " + recP1[2] + " - " + recP2[2], width/2, 420);
  textSize(22);
  text("M  -  voltar ao menu", width/2, 560);
}

// recordes
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

// posição da bola (sempre resetar)
void resetBall() {
  dX = width/2;
  dY = height/2;
  dVX = random(4, 6);
  dVY = random(-3, 3);
  if (random(1) < 0.5) dVX *= -1;
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

//inputs do jogo
void keyPressed() {
  if (key == 'w' || key =='W') keyW = true;
  if (key == 's' || key =='S') keyS = true;
  if (key == 'a' || key == 'A') keyA = true;
  if (key == 'd' || key == 'D') keyD = true;
  if (keyCode == UP)    keyCima  = true;
  if (keyCode == DOWN)  keyBaixo = true;
  if (keyCode == LEFT)  keyEsq   = true;
  if (keyCode == RIGHT) keyDir   = true;

  // menu
  if (estado == 0) {
    if (keyCode == ENTER) {
      resetarJogo();
      estado = 1;
    }
    if (key == 'r' || key == 'R') estado = 4;
  }

  // pausa
  if (key == ESC) {
    key = 0;
    if (estado == 1) estado = 2;
    else if (estado == 2) estado = 1;
  }

  // voltar ao menu
  if (key == 'm' || key == 'M') {
    if (estado == 2 || estado == 3 || estado == 4) estado = 0;
  }

  // reiniciar após fim
  if (keyCode == ENTER && estado == 3) {
    resetarJogo();
    estado = 1;
  }
}

//Teclas voltam para false ao soltar.
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
