final float CANVAS = 960;
final float HALF_CANVAS = CANVAS / 2;

int turn = +1;
int cardCount = 52;
int cardX = -1, cardY = -1;
int[] score = new int[2];
ArrayList < Trump > trumps = new ArrayList < Trump > ();

// Processingでは構造体が使えないため
// 必要な変数をまとめたTrumpクラスを定義する
class Trump {
  int mark;
  int number, subNumber;
  boolean hidden, subHidden;
  String card;
  float x, y;

  Trump(int mark, int number, boolean hidden, String card, float x, float y) {
    // 0:スペード 1:ハート 2:ダイヤモンド 3:クローバー
    this.mark = mark;
    // A~Kまでの数字
    this.number = number;
    this.subNumber = -1;
    // カードの柄が隠れているかどうか
    this.hidden = hidden;
    this.subHidden = false;
    // トランプの絵文字
    this.card = card;
    // トランプのXY座標
    this.x = x; this.y = y;
  }

  void setNumber() {
    this.number = this.subNumber;
    this.subNumber = -1;
  }

  void setHidden() {
    this.hidden = true;
    this.subHidden = false;
  }

  void draw() {
    fill(this.hidden || this.mark < 1 || this.mark > 2
      ? #000000 : #FF0000
      );
    text(
      this.hidden ? "🂠" : this.card,
      this.x, this.y
      );
  }
}

int toIndex(int r, int c) { // 座標をトランプのインデックスに変換
  return r % 13 + 12 * c + c;
}

int getNumber(int r, int c) { // 指定した座標のトランプのnumberを取得
  return trumps.get(toIndex(r, c)).number;
}

void showScore(int n) { // スコア表示
  push();
  float x = HALF_CANVAS * (10 * n + 1) / 6 + 16;
  float y = HALF_CANVAS * (11 - 10 * n) / 6 + 90;
  fill(n == 1 ? #00C000 : #0000FF);
  textSize(HALF_CANVAS / 8);
  text("🂠", x - HALF_CANVAS / 8, y);
  fill(#000000);
  textSize(HALF_CANVAS / 12);
  text("×" + nf(score[n], 2), x, y);
  pop();
}

void showTurn() { // ターン表示
  push();
  textAlign(LEFT, CENTER);
  textSize(HALF_CANVAS/10);
  boolean gameEnds = cardCount <= 0;
  String message = gameEnds ? "win!" : "'s turn";

  if (gameEnds && score[0] == score[1]) {
    text("Draw", 2, 90 - HALF_CANVAS / 12);
    pop();
    return;
  }
  boolean fillStatus = gameEnds ? score[0] < score[1] : turn == 1;
  fill(#000000);
  text(message, HALF_CANVAS / 6 - 6, 90 - HALF_CANVAS / 12);
  fill(fillStatus ? #00C000: #0000FF);
  textSize(HALF_CANVAS / 6);
  text("🂠", 8, 80 - HALF_CANVAS / 12);
  pop();
}

void setCards() { // トランプをセット
  IntList numbers= new IntList();
  // range() 的なメソッドが使えるならそっちで
  // 今回はforで代用
  for (int i = 0; i < cardCount; i++) {
    numbers.append(i);
  }
  numbers.shuffle();
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j <= 13; j++) {
      if (j == 11) continue;
      int k = j > 11 ? j - 1 : j;
      int n = numbers.get(toIndex(k, i));
      int m = n % 13;
      int o = n / 13;
      // トランプの絵文字をひとつひとつ用意するのは大変なので
      // Character.toChars() を用いてUnicodeコードポイントから生成
      trumps.add(new Trump(
        o,
        m + 1,
        true,
        new String(Character.toChars(
        0x01F0A1 + 16 * o + m + int(m > 10)
        )),
        CANVAS / 13 * k + HALF_CANVAS / 13,
        CANVAS / 8 * (i + k / 3.0 + 0.5) + 90
        ));
    }
  }
}

void setup() {
  size(960, 1080);
  textAlign(CENTER, CENTER);
  textFont(createFont("Segoe UI Symbol", CANVAS / 9));
  setCards();
  noLoop();
}

void draw() {
  background(#FFFFFF);
  showTurn();
  showScore(0);
  showScore(1);

  for (Trump trump : trumps) {
    push();
    if (trump.number > 0) {
      trump.draw();
    }
    pop();

    if (trump.subNumber != -1) {
      trump.setNumber();
    }
    if (trump.subHidden) {
      trump.setHidden();
    }
  }
}

void mousePressed() {
  int p = floor(13 * mouseX / CANVAS);
  int q = floor((12 * (mouseY - 90) - p * HALF_CANVAS) / (3 * HALF_CANVAS));

  if (p < 0 || p > 13 || q < 0 || q > 3) return;

  Trump trump = trumps.get(toIndex(p, q));
  if (trump.number < 1) return;
  trump.hidden = false;

  if (cardX < 0 && cardY < 0) {
    cardX = p; cardY = q;
  } else {
    if (p != cardX || q != cardY) {
      boolean cardsMatched =
        getNumber(p, q) == getNumber(cardX, cardY);
      if (cardsMatched) {
        score[int(turn == 1)] += 2;
        cardCount -= 2;
        trumps.get(toIndex(p, q)).subNumber =
          trumps.get(toIndex(cardX, cardY)).subNumber = 0;
      } else {
        turn = -turn;
        trumps.get(toIndex(p, q)).subHidden =
          trumps.get(toIndex(cardX, cardY)).subHidden = true;
      }
      cardX = cardY = -1;
    }
  }

  redraw();
}
