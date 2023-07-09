// いのちの輝きくん

void setup() {
  size(640, 640);
  noStroke();
}

void draw() {
  background(#FFFFFF);

  fill(#FF0000);
  ellipse(300.0, 130.0, move(125.0, 2.0, 1), 125.0);
  ellipse(425.0, 150.0, 160.0, move(165.0, 1.0, 0));
  ellipse(480.0, 245.0, move(185.0, 2.0, 0), 75.0);
  ellipse(475.0, 325.0, move(110.0, 3.0, 1), 145.0);
  ellipse(465.0, 455.0, 180.0, move(150.0, 1.0, 1));
  ellipse(355.0, 535.0, move(140.0, 2.0, 1), 145.0);
  ellipse(255.0, 525.0, 100.0, move(100.0, 1.0, 1));
  ellipse(205.0, 455.0, 80.0, move(125.0, 3.0, 0));
  ellipse(160.0, 360.0, move(145.0, 2.0, 0), 140.0);  
  ellipse(220.0, 265.0, move(115.0, 2.0, 1), 120.0);
  ellipse(145.0, 245.0, move(120.0, 1.0, 1), 120.0);
  ellipse(225.0, 185.0, 100.0, move(100.0, 3.0, 0));

  eye(445.0, 120.0, 70.0, 70.0, 35.0);
  eye(495.0, 460.0, 80.0, 70.0, 40.0);
  eye(350.0, 565.0, 50.0, 50.0, 25.0);
  eye(180.0, 370.0, 65.0, 60.0, 30.0);
  eye(130.0, 240.0, 60.0, 60.0, 30.0);
}

float move(float radius, float speed, float theta) {
  theta += PI / 180 * frameCount * speed;
  return map(sin(theta), -1, 1, radius - 15, radius);
}

void eye(float x, float y, float w, float h, float r) {
  // 引数を(y, x)とすると目線が一点に集まり
  // (x, y)とすると目線がバラバラになりやすい
  float theta = atan2(mouseY - y, mouseX - x);

  fill(#FFFFFF);
  ellipse(x, y, w, h);
  fill(#1064AA);
  circle(w / 4.0 * cos(theta) + x, h / 4.0 * sin(theta) + y, r);
}
