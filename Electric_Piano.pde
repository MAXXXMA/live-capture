/*
 * Electric Piano
 *
 * date 18/9/23
 */

import processing.video.*;
import ddf.minim.*;

int numKeys=41;  // 键数，为奇数
float keyWidth;  // 白键宽
PianoKey[] whiteKeys, blackKeys;
AudioPlayer[] players;
PImage lastFrame;
float threshold = 50; // 阈值
Capture captured;
int playWidth=100;  // 弹琴宽度
ParticleSystem ps;
PGraphics pg;

void setup() {
  //fullScreen();

  size(640, 480);
  frameRate(30);

  pg = createGraphics(width, height);
  PImage img = loadImage("texture.png");
  ps = new ParticleSystem(0, new PVector(0, 0), img);

  Minim minim = new Minim(this);
  rectMode(CENTER);
  whiteKeys=new PianoKey[(numKeys+1)/2];
  blackKeys=new PianoKey[(numKeys-1)/2];
  keyWidth=(float)height/whiteKeys.length;

  players=new AudioPlayer[whiteKeys.length+1];

  // 加载音频
  players[0] = minim.loadFile("theAwakening.wav");
  for (int i = 1; i < players.length; i++) {
    players[i] = minim.loadFile(i + ".mp3");
  }

  initKeys();
  players[0].loop();
  captured = new Capture(this, width, height);
  captured.start();
  lastFrame = createImage(captured.width, captured.height, RGB);
}

void initKeys() {
  // 初始化白键
  for (int i=0; i<whiteKeys.length; i++) {
    whiteKeys[i]=new PianoKey(new PVector(keyWidth*144/24/2, keyWidth/2+i*keyWidth), 
      color(#FFFFFF), keyWidth*144/24, keyWidth, players[i+1]);
  }

  // 初始化黑键
  for (int i=0; i<blackKeys.length; i++) {
    blackKeys[i]=new PianoKey(new PVector(keyWidth*86/24/2, (i+1)*keyWidth), 
      color(#000000), keyWidth*86/24, keyWidth*9/24, players[i+1]);
  }
}

void showKeys() {
  // 初始化白键
  for (int i=0; i<whiteKeys.length; i++) {
    whiteKeys[i].show();
  }

  // 初始化黑键
  for (int i=0; i<blackKeys.length; i++) {
    blackKeys[i].show();
  }
}

void draw() {
  liveCapture();
  showKeys();

  PVector pos=new PVector(-100,-100);
  if ( play().score>0) {
    // 弹奏钢琴
    play().press();
    pos=new PVector(play().pos.x+play().keyLen/2+random(30), play().pos.y);
  }

  pg.beginDraw();
  pg.background(0, 10);
  ps.origin=pos;
  PVector wind = new PVector(0, 0);
  ps.applyForce(wind);
  ps.run();
  for (int i = 0; i < 15; i++) {
    ps.addParticle();
  }

  pg.endDraw();
  image(pg, 0, 0);
}

// 实时捕捉
void liveCapture() {
  loadPixels();
  captured.loadPixels();
  lastFrame.loadPixels();

  for (int x = 0; x < captured.width; x++ ) {
    for (int y = 0; y < captured.height; y++ ) {
      int loc = x + y * captured.width;
      // 前后两帧的像素颜色
      color current = captured.pixels[loc];
      color previous = lastFrame.pixels[loc];

      float r1 = red(current); 
      float g1 = green(current); 
      float b1 = blue(current);
      float r2 = red(previous); 
      float g2 = green(previous); 
      float b2 = blue(previous);

      float distance = dist(r1, g1, b1, r2, g2, b2);

      if (distance > threshold) { 
        pixels[loc] = color(255);
        // 统计得分
        PianoKey pk=findKey(x, y);
        if (pk!=null)
          pk.score++;
      } else {
        pixels[loc] = color(0);
      }
    }
  }
  updatePixels();
}

void captureEvent(Capture video) {
  // 保存上一帧
  lastFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height); 
  lastFrame.updatePixels();  // 从相机中读取
  video.read();
}

// 找到最近的钢琴键
PianoKey findKey(int x, int y) {
  for (int i=0; i<whiteKeys.length; i++) {
    if (abs(x-whiteKeys[i].pos.x-whiteKeys.length/2)<playWidth/2
      &&abs(whiteKeys[i].pos.y-y)<whiteKeys[i].keyWid/2) {
      return whiteKeys[i];
    }
  }

  return null;
}

PianoKey play() {
  PianoKey pressKey=whiteKeys[0];
  for (PianoKey pk : whiteKeys) {
    if (pressKey.score<pk.score) {
      pressKey=pk;
    }
  }
  return pressKey;
}
