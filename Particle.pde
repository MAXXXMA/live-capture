class Particle {
  PVector loc;
  PVector vel;
  PVector acc;
  float lifespan;
  PImage img;

  Particle(PVector l, PImage img_) {
    acc = new PVector(0, 0);
    float vx = randomGaussian()*0.3;
    float vy = randomGaussian()*0.3 - 1.0;
    vel = new PVector(vx, vy);
    loc = l.copy();
    lifespan = 120.0;
    img = img_;
  }

  void run() {
    update();
    render();
  }

  void applyForce(PVector f) {
    acc.add(f);
  }  

  void update() {
    vel.add(acc);
    loc.add(vel);
    lifespan -= 1.5;
    acc.mult(0);
  }

  void render() {
    pg.imageMode(CENTER);
    pg.tint(255, lifespan);
    pg.image(img, loc.x, loc.y);
  }

  boolean isDead() {
    if (lifespan <= 0.0) {
      return true;
    } else {
      return false;
    }
  }
}
