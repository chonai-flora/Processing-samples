final int CANVAS = 720;
final int BLOCK = CANVAS / 9;

/* 歩:P 香:L 桂:N 銀:S 金:G 飛:R 角:B */
final int P = 1, L = 2, N = 3, S = 4, R = 5, B = 6, G = 7;
/* と:pP 成香:pL 成桂:pN 成銀:pS 竜:pR 馬:pB 王:K 玉:pK */
final int pP = 8, pL = 9, pN = 10, pS = 11, pR = 12, pB = 13, K = 14, pK = 15;

int[][] board = {  // 盤面
  { -L, -N, -S, -G, -pK, -G, -S, -N, -L },
  { 0, -R, 0, 0, 0, 0, 0, -B, 0 },
  { -P, -P, -P, -P, -P, -P, -P, -P, -P },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { +P, +P, +P, +P, +P, +P, +P, +P, +P },
  { 0, +B, 0, 0, 0, 0, 0, +R, 0 },
  { +L, +N, +S, +G, +K, +G, +S, +N, +L }
};
int turn = +1;  // ターン
boolean[][] movable = new boolean[9][9];  // 移動可能かどうか
int[] dx = { 1, 1, 0, -1, -1, -1, 0, 1 };  // x座標の移動位置
int[] dy = { 0, 1, 1, 1, 0, -1, -1, -1 };  // y座標の移動位置
int promoX = 10, promoY = 10;  // 成る際の座標
int pieceX = 10, pieceY = 10;  // 選択中の座標
boolean isPromoting = false;  // 成るかどうかの選択中
boolean gameEnds = false;  // 勝敗がついたかどうか

PImage[] pieces = new PImage[16];  // 駒の画像データ
int[][] stocks = new int[2][8];  // 持ち駒
int[] stockOrder = { 0, P, L, N, S, G, R, B };  //　持ち駒の並び
int stockIndex = 0;  // 持ち駒のインデックス

boolean isOutOfRange(int w, int h) {  // 盤面外かどうか
  return (w < 0 || h < 0 || w >= 9 || h >= 9);
}

int pieceSign(int w, int h) {  // 駒の符号
  return int(Math.signum(board[h][w]));
}

boolean arrayContains(int[] targets, int key) {  // targetsにkeyが含まれるかどうか
  for (int i = 0; i < targets.length; i++) {
    if (targets[i] == key) return true;
  }
  return false;
}

void initMovable() {  // 移動可能な位置の初期化
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      movable[j][i] = false;
    }
  }
}

void setup() {
  size(720, 960);
  strokeWeight(2);
  rectMode(CENTER);
  imageMode(CENTER);
  textSize(BLOCK - 20);
  textAlign(CENTER, CENTER);
  textFont(createFont("Meiryo", 48));

  initMovable();
  for (int i = P; i <= pK; i++) {
    pieces[i] = loadImage("img/" + nf(i, 2) + ".png");
    pieces[i].resize(BLOCK - 10, BLOCK - 10);
  }

  noLoop();
}

void showStock(int n) {  // 持ち駒を表示
  push();
  boolean isSelf = n == 1;
  int pos = isSelf ? CANVAS + 2 * BLOCK : BLOCK;
  image(pieces[isSelf ? K : pK], BLOCK / 2, pos + BLOCK / 2);

  fill(#000000);
  stroke(#FFFFFF);
  textSize(18);
  for (int i = P; i <= G; i++) {
    int j = stockOrder[i];
    int x = (i + 1) * BLOCK + BLOCK / 2;
    int y = pos + BLOCK / 2;
    image(pieces[j], x, y);
    text("×" + stocks[int(isSelf)][j], x + BLOCK / 2 - 20, y + BLOCK / 2 - 10);
  }
  pop();
}

void showTurn() {  // ターンを表示
  push();
  noStroke();
  rectMode(CORNER);
  textAlign(LEFT, TOP);
  fill(#FFFFFF);
  rect(0, 0, CANVAS, BLOCK);
  fill(#000000);
  text((turn == 1 ? "王" : "玉") + "のターンです", 5, 10);
  pop();
}

void draw() {
  background(#008000);
  showStock(1);
  showStock(-1);

  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      push();
      translate(i * BLOCK + BLOCK / 2, (j + 2) * BLOCK + BLOCK / 2);
      fill(
        i == pieceX && j == pieceY || movable[j][i]
        ? #228B22
        : #DAA520
        );
      stroke(#000000);
      rect(0, 0, BLOCK, BLOCK);
      int k = board[j][i];
      if (k == 0) {
        pop();
        continue;
      } else if (k <= 0) {
        rotate(PI);
        k = -k;
      }
      image(pieces[k], 0, 0);
      pop();
    }
  }

  noFill();
  square(
    pieceX * BLOCK + BLOCK / 2,
    (pieceY + 2) * BLOCK + BLOCK / 2,
    BLOCK
    );

  if (gameEnds) {
    rectMode(CORNER);
    noStroke();
    fill(#00C000, 192);
    rect(0, 2 * BLOCK, CANVAS, CANVAS);
    fill(#00FF00, 192);
    rect(BLOCK, 5 * BLOCK, 7 * BLOCK, 3 * BLOCK);
    fill(#000000);
    text((turn == 1 ? "王" : "玉") + "の勝ちです", CANVAS / 2, 6.5 * BLOCK);
  }

  showTurn();

  if (!gameEnds && isPromoting) {
    askPromote();
    turn = -turn;
  }
}

void promote(int w, int h, int sign) {  // 成る
  int type = abs(board[h][w]);
  if (type >= P && type <= B) {
    board[h][w] = -sign * (type + 7);
  }
}

void askPromote() {  // 成るかどうか尋ねる
  push();
  noStroke();
  rectMode(CORNER);
  fill(#00C000, 192);
  square(0, 2*BLOCK, CANVAS);

  fill(#00FF00, 192);
  rect(BLOCK, 5 * BLOCK, 7 * BLOCK, 3 * BLOCK);
  fill(#000000);
  text("成りますか?", CANVAS / 2, CANVAS / 2 + BLOCK);

  textSize(32);
  for (int i = 0; i < 2; i++) {
    float x = CANVAS / 4 + 2.5 * i * BLOCK;
    float y = 6.5 * BLOCK;
    fill(#FFFFFF);
    rect(x, y, 2 * BLOCK, BLOCK);
    fill(#000000);
    text(i == 0 ? "はい" : "いいえ", x + BLOCK, y + BLOCK / 2.25);
  }
  pop();
}

void updatePlacable(int w, int h) {  // 移動可能な位置の更新
  initMovable();

  int type = abs(board[h][w]);
  int sign = pieceSign(w, h);

  if (type == P) {  // 歩
    movable[h - sign][w] = true;
  }

  if (type == L) {  // 香
    for (int i = h - sign; sign == 1 ? i >= 0 : i < 9; i -= sign) {
      if (pieceSign(w, i) == turn) break;
      movable[i][w] = true;
      if (pieceSign(w, i) != 0) break;
    }
  }

  if (type == N) {  // 桂
    for (int i = 1; i <= 3; i += 2) {
      int p = -sign * dx[i] + w;
      int q = -sign * dy[i] * 2 + h;

      if (isOutOfRange(p, q) ||
        pieceSign(p, q) == sign) continue;
      movable[q][p] = true;
    }
  }

  if (type == S) {  // 銀
    for (int i = 1; i < 8; i++) {
      if (i == 4 || i == 6) continue;
      int p = -sign * dx[i] + w;
      int q = -sign * dy[i] + h;

      if (isOutOfRange(p, q) ||
        pieceSign(p, q) == sign) continue;
      movable[q][p] = true;
    }
  }

  int[] a = { R, pR };
  if (arrayContains(a, type)) {  // 飛, 竜
    for (int i = 0; i < 8; i += 2) {
      for (int j = 1; j < 8; j++) {
        int p = j * dx[i] + w;
        int q = j * dy[i] + h;

        if (isOutOfRange(p, q) ||
          pieceSign(p, q) == sign) break;
        movable[q][p] = true;
        if (pieceSign(p, q) != 0) break;
      }
    }
  }

  int[] b = { B, pB };
  if (arrayContains(b, type)) {  // 角, 馬
    for (int i = 1; i < 9; i += 2) {
      for (int j = 1; j < floor(9 * sqrt(2.0)); j++) {
        int p = j * dx[i] + w;
        int q = j * dy[i] + h;

        if (isOutOfRange(p, q) ||
          pieceSign(p, q) == sign) break;
        movable[q][p] = true;
        if (pieceSign(p, q) != 0) break;
      }
    }
  }

  int[] c = { G, pP, pL, pN, pS };
  if (arrayContains(c, type)) {  // 金, と, 成香, 成桂, 成銀
    for (int i = 0; i < 8; i++) {
      if (i == 5 || i == 7) continue;
      int p = -sign * dx[i] + w;
      int q = -sign * dy[i] + h;

      if (isOutOfRange(p, q) ||
        pieceSign(p, q) == sign) continue;
      movable[q][p] = true;
    }
  }

  int[] d = { pR, pB, K, pK };
  if (arrayContains(d, type)) {  // 竜, 馬, 王, 玉
    for (int i = 0; i < 8; i++) {
      int p = dx[i] + w;
      int q = dy[i] + h;

      if (isOutOfRange(p, q) ||
        pieceSign(p, q) == sign) continue;
      movable[q][p] = true;
    }
  }

  pieceX = w;
  pieceY = h;
}

void putStock() {  // 持ち駒の使用
  int piece = stockOrder[stockIndex];
  if (stocks[int(turn == 1)][piece] == 0)
    return;

  initMovable();
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      movable[j][i] = board[j][i] == 0;
    }
  }

  if (piece == P) {
    int[][] b = new int[9][9];
    for (int i = 0; i < 9; i++) {
      b[i] = board[i].clone();
    }
    for (int i = 0; i < 9; i++) {
      for (int j = i; j < 9; j++) {
        int tmp = b[j][i];
        b[j][i] = b[i][j];
        b[i][j] = tmp;
      }
    }
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (arrayContains(b[i], turn * P)) {
          movable[j][i] = false;
        }
      }
      int k = turn == 1 ? 0 : 8;
      movable[k][i] = false;
    }
  } else if (piece == L) {
    for (int i = 0; i < 9; i++) {
      int j = turn == 1 ? 0 : 8;
      movable[j][i] = false;
    }
  } else if (piece == N) {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 2; j++) {
        int k = turn == 1 ? j : 8 - j;
        movable[k][i] = false;
      }
    }
  }

  pieceX = pieceY = 10;
}

boolean buttonPressed(float pos) {  // 成る際の選択ボタン
  return (mouseX >= CANVAS / 4 + pos && mouseX <= CANVAS / 4 + 2 * BLOCK + pos &&
    mouseY >= 6.5 * BLOCK && mouseY <= 7.5 * BLOCK);
}

void mousePressed() {
  if (gameEnds) return;

  if (isPromoting) {
    if (buttonPressed(0)) {
      promote(promoX, promoY, turn);
      promoX = promoY = 10;
      isPromoting = false;
      redraw();
    } else if (buttonPressed(2.5 * BLOCK)) {
      isPromoting = false;
      redraw();
    }
    return;
  }

  int p = floor(mouseX / BLOCK);
  int q = floor(mouseY / BLOCK) - 2;

  if ((turn == 1 && q == 9 ||
    turn == -1 && q == -1) &&
    stocks[int(turn == 1)][stockOrder[p - 1]] > 0) {
    stockIndex = p - 1;
    putStock();
    redraw();
    push();
    noFill();
    stroke(#0000FF);
    square(p * BLOCK + BLOCK / 2, (q + 2) * BLOCK + BLOCK / 2, BLOCK);
    pop();
  }

  if (isOutOfRange(p, q)) return;
  if (board[q][p] != 0 &&
    pieceSign(p, q) == turn) {
    updatePlacable(p, q);
  }

  if (movable[q][p]) {
    if (board[q][p] != 0) {
      int type = abs(board[q][p]);
      if (type >= pP && type <= pB) {
        type -= 7;
      }
      if (type < K) {
        stocks[int(turn == 1)][type]++;
      }
    }

    if (!isOutOfRange(pieceX, pieceY) &&
      board[pieceY][pieceX] != 0) {
      if (abs(board[pieceY][pieceX]) <= B &&
        (turn == +1 && q <= 2 ||
        turn == -1 && q >= 6)) {
        isPromoting = true;
        promoX = p;
        promoY = q;
      }
    }

    gameEnds = abs(board[q][p]) >= K;
    initMovable();

    if (isOutOfRange(pieceX, pieceY)) {
      int piece = turn * stockOrder[stockIndex];
      board[q][p] = piece;
      stocks[int(turn == 1)][abs(piece)]--;
      stockIndex = 0;
    } else {
      board[q][p] = board[pieceY][pieceX];
      board[pieceY][pieceX] = 0;
      pieceX = pieceY = 10;
    }

    int piece = board[q][p];
    int[] a = { +P, +L }, b = { -P, -L };
    if (arrayContains(a, piece) && q == 0 ||
      arrayContains(b, piece) && q == 8 ||
      piece == +N && q <= 1 ||
      piece == -N && q >= 7) {
      promote(p, q, -turn);
      isPromoting = false;
    }

    if (!gameEnds && !isPromoting) turn = -turn;
  }

  redraw();
}
