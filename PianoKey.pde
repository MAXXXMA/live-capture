// 钢琴键类
class PianoKey {

  PVector pos;
  color keyColor;
  float keyLen, keyWid;
  AudioPlayer player;
  int score;

  PianoKey(PVector pos, color keyColor, float keyLen, float keyWid, AudioPlayer player) {
    this.pos=pos;
    this.keyColor=keyColor;
    this.keyLen=keyLen;
    this.keyWid=keyWid;
    this.player=player;
    score=0;
  }

  void press() {
    fill(#FCAD36, 80);
    if (keyColor==color(#FFFFFF)) 
      rect(pos.x, pos.y, keyLen, keyWid, 1, 1, 1, 1);
    else
      rect(pos.x, pos.y, keyLen, keyWid, 1, 8, 8, 1);

    // 播放音频
    player.rewind();
    player.play();
    score=-5000;
  }

  void show() {
    fill(keyColor);
    strokeWeight(2);
    if (keyColor==color(#FFFFFF)) 
      rect(pos.x, pos.y, keyLen, keyWid, 1, 1, 1, 1);
    else
      rect(pos.x, pos.y, keyLen, keyWid, 1, 8, 8, 1);
  }
}
