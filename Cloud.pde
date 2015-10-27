class Cloud {
  float x;
  float y;
  float r;

  int alpha;
  float rot;

  PImage img;

  int c = color(fill_red, fill_green, fill_blue);

  Cloud(float x_, float y_, float r_) {
    x = x_;
    y = y_;
    r = r_;
    img = sparkle;
    rot = 0 ;
    alpha = 255;
  }

  public void render() {
    if (!nebula) {
      fill(c, alpha);
      noStroke();
      ellipse(x, y, r, r);
    } else {
      float new_r = r * 2;
      image(img, x - (new_r / 2), y - (new_r / 2), new_r, new_r);
    }
  }

  public void update() {
    if (alpha > 0) {
      alpha -= 10;
    }
    if (r > 0) {
      r -= 0.5;
    }
  }
}

