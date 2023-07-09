int slideIndex;
StringList slides;
PImage backImage;
Snowfall[] snowfalls;

void textWithShadow(String message) {
  push();
  int x = width / 2, y = height / 2;

  fill(0, 180);
  text(message, x + 5, y + 5);
  fill(#FFFAFA);
  text(message, x, y);
  pop();
}

void setup() {
  fullScreen();
  textAlign(CENTER, CENTER);
  textFont(createFont("游ゴシック Medium", 250));

  IntList cards = new IntList();
  for (int card = 1; card <= 50; card++) {
    cards.append(card);
  }
  cards.shuffle();
  
  slideIndex = 0;
  slides = new StringList();
  slides.append("はじめます！");
  for (Integer card : cards) {
    slides.append(nf(card, 2));
  }
  slides.append("おわりです！");

  backImage = loadImage("img/back.png");
  backImage.resize(width, height);

  snowfalls = new Snowfall[200];
  PFont emojiFont = createFont("Segoe UI Emoji", 100);
  for (int i = 0; i < 200; i++) {
    boolean isCrystal = (i % 2 == 0);
    snowfalls[i] = new Snowfall(isCrystal, emojiFont);
  }
}

void draw() {
  clear();
  image(backImage, 0, 0);

  for (Snowfall snowfall : snowfalls) {
    snowfall.update();
    snowfall.draw();
  }

  textWithShadow(slides.get(slideIndex));
}

void keyPressed() {
  if (keyCode == LEFT) {
    slideIndex--;
  } else if (keyCode == RIGHT) {
    slideIndex++;

    if (slideIndex >= slides.size()) {
      exit();
    }
  }
}

class Snowfall {
  PVector pos;
  PVector delta;
  float size;
  float alpha;
  boolean isCrystal;
  PFont emojiFont;

  Snowfall(boolean isCrystal, PFont emojiFont) {
    this.pos = new PVector(random(width), random(height));
    this.delta = new PVector(-random(3.0), random(2.0, 4.0));
    this.size = random(15.0, 40.0);
    this.alpha = random(192);
    this.isCrystal = isCrystal;
    this.emojiFont = emojiFont;
  }

  void update() {
    this.pos.add(this.delta);
    if (-this.size > this.pos.x) {
      this.pos.x = this.size + width;
    }
    if (this.pos.y > this.size + height) {
      this.pos.y = -this.size;
    }
  }

  void draw() {
    push();
    if (this.isCrystal) {
      textFont(this.emojiFont);
      textSize(this.size);
      fill(255, this.alpha);
      text("❄", this.pos.x, this.pos.y);
    } else {
      fill(255, this.alpha);
      noStroke();
      circle(this.pos.x, this.pos.y, this.size);
    }
    pop();
  }
}
