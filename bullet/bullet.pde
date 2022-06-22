// finalをつけて宣言すると定数になります
// 定数は変数と違い値を書き換えることができません
final float screen = 960.0; // ウィンドウサイズ

// Processingは同時キー入力に対応していないので変数で調整します
boolean up, down, left, right; // キー入力用

void keyPressed() {
  if (keyCode == UP) up = true;
  if (keyCode == DOWN) down = true;
  if (keyCode == LEFT) left = true;
  if (keyCode == RIGHT) right = true;
}

void keyReleased() {
  if (keyCode == UP) up = false;
  if (keyCode == DOWN) down = false;
  if (keyCode == LEFT) left = false;
  if (keyCode == RIGHT) right = false;
}

int backColor; // 背景色
int hitCount; // 被弾した回数

Bullet bullet; // 弾幕
Player player; // 自機

void setup() {
  size(960, 960);
  noStroke();
  textFont(createFont("Meiryo", 32));

  up = down = left = right = false;
  backColor = hitCount = 0;
  bullet = new Bullet(0); // 0:タイプ1 1:タイプ2 2:n-way
  player = new Player(1); // 0:マウス操作 1:キー操作
}

void draw() {
  if (backColor > 0) backColor -= 2;
  background(backColor);

  bullet.update(player.getPos());
  bullet.draw();

  player.update();
  player.draw();

  // 弾幕と自機がヒットしたら
  if (bullet.isHit(player.getPos(), player.getRadius())) {
    backColor = 128; // 背景色を灰色にする
    hitCount++; // 被弾回数をインクリメント
  }

  fill(#FFFFFF);
  text("被弾回数 : " + hitCount, 50, 100);
}

// Bulletクラス
class Bullet {
  int type;
  int n;
  int param;
  float theta;
  float radius;
  int hitFrame;
  PVector pos[];

  Bullet(int type) {
    // thisをつけることでメンバ変数とその他の変数を区別することができます
    // thisは省略可能ですが引数名と区別するためにつけています
    int n[] = { 360, 160, 5 };
    this.type = type; // 弾幕のタイプ
    this.n = n[type]; // 弾幕の個数
    this.param = int(random(1, 4)); // 媒介変数(動きの改造に使用)
    this.theta = 0.0; // 角度
    this.radius = 9.0; // 半径
    this.hitFrame = 120; // ヒット後のマージン
    this.pos = new PVector[360]; // 座標
    for (int i = 0; i < this.n; i++) {
      this.pos[i] = new PVector(0.0, 0.0);
    }
  }

  // 媒介変数の値で関数を変更
  float sohcahtoa(float t) { // 1:sin 2:cos 3:tan
    if (param == 1) return sin(t);
    else if (param == 2) return cos(t);
    return tan(t);
  }

  // 値の更新
  void update(PVector pPos) {
    if (type == 0) { // タイプ1
      float t = frameCount % 1080 * PI / 540.0; // frameCountをラジアン角に変換
      for (int i = 0; i < n; i++) {
        // この辺の値を少し改造するだけで動きが大きく変わるので試してみて下さい
        float u = (i / screen) * PI * 360.0; // カウンタをラジアン角に変換
        float v = PI / (param * 90.0 + sin(t) * (cos(t) + 1.0)) * i; // 弾幕を回転させる角度
        float r = sin(i + i / screen + t + u) * 675.0; // 原点からの距離

        // 回転座標の一次変換公式を用いて座標を回転させる
        float p = r * cos(u), q = r * sin(u); // 回転させる前の座標
        pos[i].x = p * cos(v) - q * sin(v) + screen / 2.0; // x' = xcosθ - ysinθ
        pos[i].y = q * cos(v) + p * sin(v) + screen / 2.0; // y' = ycosθ + xsinθ
      }
    } else if (type == 1) { // タイプ2
      int index = 0;
      float t = frameCount % 1080 * PI / 540.0; // frameCountをラジアン角に変換
      for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 20; j++) {
          float u = PI / 45.0 * j - abs(asin(cos(t))); // カウンタをラジアン角に変換
          float v = t + atan(sohcahtoa(t + u * 3.0)); // 弾幕を回転させる角度
          float r = u * 500.0; // 原点からの距離

          // 回転座標の一次変換公式を用いて座標を回転させる
          float p = r * cos(PI / 4.0 * i), q = r * sin(PI / 4.0 * i);
          pos[index].x = p * cos(v) - q * sin(v) + screen / 2.0; // x' = xcosθ - ysinθ
          pos[index].y = q * cos(v) + p * sin(v) + screen / 2.0; // y' = ycosθ + xsinθ
          index++;
        }
      }
    } else if (type == 2) { // おまけ n-way
      int index = 0;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < (i == 0 ? 1 : 2); j++) {
          float r = frameCount * 10 % 675;
          float t = 0.0;
          if (r < 10.0) {
            t = atan2(pPos.y - screen / 2.0, pPos.x - screen / 2.0); // atan2()で自機までの角度を計算
            theta = t;
          } else {
            t = theta;
          }
          float u = t + 0.1 * i * (j == 0 ? -1.0 : 1.0);
          pos[index].x = r * cos(u) + screen / 2.0;
          pos[index].y = r * sin(u) + screen / 2.0;
          index++;
        }
      }
    } else if (type == 4) {} // 数式や物理式などで新しい弾幕を作ってみてください

    if (hitFrame > 0) hitFrame--; // hitFrameをデクリメント
  }

  // 当たり判定
  boolean isHit(PVector pPos, float pRadius) {
    // hitFrameが0でなければfalseを返す
    if (hitFrame > 0) return false;
    for (int i = 0; i < n; i++) {
      // 当たり判定には2点((x1, y1), (x2, y2))間の距離を求める公式
      // √((x2 - x1)² + (y2 - y1)²)を使用します
      // Processingには標準でdist(x1, y1, x2, y2)という関数が用意されており
      // PVectorクラスにも同じものがあるため今回はこの.dist(v)を使用します
      // 2点間の距離がそれぞれの半径より小さくなったらtrueを返す
      if (pos[i].dist(pPos) <= (pRadius + radius) / 2.0) {
        hitFrame = 60; // hitFrameを60に設定
        return true;
      }
    }
    return false;
  }

  // 描画
  void draw() {
    for (int i = 0; i < n; i++) {
      fill(#FFFFFF);
      circle(pos[i].x, pos[i].y, radius);
    }
  }
}

// Playerクラス
class Player {
  float radius;
  float velocity;
  float offset;
  int action;
  PVector pos;

  Player(int action) {
    this.radius = 12.5; // 半径
    this.velocity = 0.0; // 速度
    this.offset = sqrt(2.0); // 斜め移動の速度調整
    this.action = action; // 操作方法
    this.pos = new PVector(screen / 2.0, screen / 1.25); // 座標
  }

  // 座標の取得(.copy()でディープコピーする)
  PVector getPos() { return pos.copy(); }

  // 半径の取得
  float getRadius() { return radius; }

  // 値の更新
  void update() {
    if (action == 0) {
      pos.x = mouseX;
      pos.y = mouseY;
    } else {
      // 斜めに移動させると((設定した速度)*√2)分移動してしまうため
      // 用意したoffsetで速度を調整します
      if (left || right) {
        velocity = (up || down ? 5.0 / offset : 5.0);
      } else if (up || down) {
        velocity = 5.0;
      }
      if (pos.x - radius > 0.0 && left) pos.x -= velocity;
      if (pos.x + radius < screen && right) pos.x += velocity;
      if (pos.y - radius > 0.0 && up) pos.y -= velocity;
      if (pos.y + radius < screen && down) pos.y += velocity;
    }
  }

  // 描画
  void draw() {
    fill(#FFFF00);
    circle(pos.x, pos.y, radius);
  }
}
