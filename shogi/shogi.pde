// あまり綺麗なコードではないので参考にしないでください
// そのうち気が向いたら書き直します

final float screen = 720;
final float halfScreen = screen / 2;
final float block = screen / 9;

// 歩:P 香:L 桂:N 銀:S 金:G 飛:R 角:B
final int P = 1, L = 2, N = 3, S = 4, R = 5, B = 6, G = 7;
// と:pP 成香:pL 成桂:pN 成銀:pS 竜:pR 馬:pB 王:K 玉:pK
final int pP = 8, pL = 9, pN = 10, pS = 11, pR = 12, pB = 13, K = 14, pK = 15;

int[][] board = {
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
boolean[][] isMovable = new boolean[9][9];
IntList checkedPieces = new IntList();
int turn = +1;
int pieceX = 10, pieceY = 10;
int promoX = 10, promoY = 10;
int[] dx = {1, 1, 0, -1, -1, -1, 0, 1};
int[] dy = {0, 1, 1, 1, 0, -1, -1, -1};
int[] stockOrder = {0, P, L, N, S, G, R, B};

boolean isPromoting = false;
boolean gameEnds = false;
PImage[] pieces = new PImage[16];
int[][] stocks = new int[2][8];
int stockIndex = 0;

boolean arrayContains(int[] targets, int key) { // targetsにkeyが含まれるかどうか
  for (int i = 0; i < targets.length; i++) {
    if (targets[i] == key) return true;
  }
  return false;
}

boolean isOutOfRange(int w, int h) { // 配列の範囲内かどうか
  return (w < 0 || h < 0 || w >= 9 || h >= 9);
}

int pieceType(int w, int h) { // 駒の種類
  return abs(board[h][w]);
}

int pieceSign(int w, int h) { // 駒の符号
  return int(Math.signum(board[h][w]));
}

void initMovable() { // 移動可能な範囲を初期化
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      isMovable[j][i] = false;
    }
  }
}

void showStock(int n) { // 持ち駒を表示
  push();
  boolean isSelf = n == 1;
  translate(block / 2, isSelf ? screen + block * 5 / 2 : block * 3 / 2);
  image(pieces[isSelf ? K : pK], 0, 0);
  fill(#000000);
  stroke(#FFFFFF);
  textSize(block / 4);
  for (int i = P; i <= G; i++) {
    int order = stockOrder[i];
    int stock = stocks[int(isSelf)][order];
    if (stock == 0) continue;
    image(pieces[order], (i + 1) * block, 0);
    text("×" + stock, i * block + block * 5 / 4, block / 4);
  }
  pop();
}

void showTurn() { // ターンと勝敗を表示
  String message = (turn == 1 ? "王" : "玉") +
    (gameEnds ? "の勝ちです" : "のターンです");
  push();
  fill(#000000);
  textSize(block / 2.75);
  textAlign(LEFT, TOP);
  text(message, 0, 0);
  if (isChecked()) {
    text("王手されています", 0, block/2);
  }
  pop();
}

void promote (int w, int h, int sign) { // 成る
  int type = pieceType(w, h);
  if (type >= P && type <= B) {
    board[h][w] = sign * (type + 7);
  }
}

void askPromote() { // 成るかどうか尋ねる
  push();
  noStroke();
  rectMode(CORNER);
  fill(#00C000, 192);
  square(0, 2*block, screen);

  fill(#00FF00, 192);
  rect(block, 5 * block, 7 * block, 3 * block);
  fill(#000000);
  text("成りますか?", screen / 2, screen / 2 + block);

  textSize(32);
  for (int i = 0; i < 2; i++) {
    float x = screen / 4 + 2.5 * i * block;
    float y = 6.5 * block;
    fill(#FFFFFF);
    rect(x, y, 2 * block, block);
    fill(#000000);
    text(i == 0 ? "はい" : "いいえ", x + block, y + block / 2.25);
  }
  pop();
}

boolean buttonPressed(float pos) { // 成る際の選択ボタン
  return (mouseX >= screen / 4 + pos && mouseX <= screen / 4 + 2 * block + pos &&
    mouseY >= 6.5 * block && mouseY <= 7.5 * block);
}

void updatePlacable(int w, int h) { // 移動可能な範囲を更新
  initMovable();
  int type = pieceType(w, h);
  int sign = pieceSign(w, h);

  if (type == P) {
    if (pieceSign(w, h - sign) != turn) {
      isMovable[h - sign][w] = true;
    }
  }

  if (type == L) {
    for (int i = h - sign; sign == 1 ? i >= 0 : i < 9; i -= sign) {
      if (pieceSign(w, i) == turn) break;
      isMovable[i][w] = true;
      if (pieceSign(w, i) != 0) break;
    }
  }

  if (type == N) {
    for (int i = 1; i <= 3; i += 2) {
      int r = -sign * dx[i] + w;
      int c = -sign * dy[i] * 2 + h;

      if (isOutOfRange(r, c) || pieceSign(r, c) == sign) continue;
      isMovable[c][r] = true;
    }
  }

  if (type == S) {
    for (int i = 0; i < 8; i++) {
      if (new IntList(0, 4, 6).hasValue(i)) continue;

      if (new IntList(0, 4, 6).hasValue(i)) continue;
      int r = -sign * dx[i] + w;
      int c = -sign * dy[i] + h;

      if (isOutOfRange(r, c) || pieceSign(r, c) == sign) continue;
      isMovable[c][r] = true;
    }
  }

  if (new IntList(R, pR).hasValue(type)) {
    for (int i = 0; i < 8; i += 2) {
      for (int j = 1; j < 9; j++) {
        int r = j * dx[i] + w;
        int c = j * dy[i] + h;

        if (isOutOfRange(r, c) || pieceSign(r, c) == sign) break;
        isMovable[c][r] = true;
        if (pieceSign(r, c) != 0) break;
      }
    }
  }

  if (new IntList(B, pB).hasValue(type)) {
    for (int i = 1; i < 9; i += 2) {
      for (int j = 1; j < floor(9 * sqrt(2)); j++) {
        int r = j * dx[i] + w;
        int c = j * dy[i] + h;

        if (isOutOfRange(r, c) || pieceSign(r, c) == sign) break;
        isMovable[c][r] = true;
        if (pieceSign(r, c) != 0) break;
      }
    }
  }

  if (new IntList(G, pP, pL, pN, pS).hasValue(type)) {
    for (int i = 0; i < 8; i++) {
      if (new IntList(5, 7).hasValue(i)) continue;
      int r = -sign * dx[i] + w;
      int c = -sign * dy[i] + h;

      if (isOutOfRange(r, c) || pieceSign(r, c) == sign) continue;
      isMovable[c][r] = true;
    }
  }

  if (new IntList(pR, pB, K, pK).hasValue(type)) {
    for (int i = 0; i < 8; i++) {
      int r = dx[i] + w;
      int c = dy[i] + h;

      if (isOutOfRange(r, c) || pieceSign(r, c) == sign) continue;
      isMovable[c][r] = true;
    }
  }

  pieceX = w;
  pieceY = h;
}

void checkPiece(int w, int h) { // チェックされている駒を更新
  int type = pieceType(w, h);
  int sign = pieceSign(w, h);

  if (type == P) {
    if (pieceSign(w, h - sign) == turn) {
      checkedPieces.push(board[h - sign][w]);
    }
  }

  if (type == L) {
    for (int i = h - sign; sign == 1 ? i >= 0 : i < 9; i -= sign) {
      if (pieceSign(w, i) != turn) break;
      checkedPieces.push(board[i][w]);
      if (pieceSign(w, i) != 0) break;
    }
  }

  if (type == N) {
    for (int i = 1; i <= 3; i += 2) {
      int r = -sign * dx[i] + w;
      int c = -sign * dy[i] * 2 + h;

      if (isOutOfRange(r, c) || pieceSign(r, c) == sign) continue;
      checkedPieces.push(board[c][r]);
    }
  }

  if (type == S) {
    for (int i = 0; i < 8; i++) {
      if (new IntList(0, 4, 6).hasValue(i)) continue;
      int r = -sign * dx[i] + w;
      int c = -sign * dy[i] + h;

      if (isOutOfRange(r, c) || pieceSign(r, c) == sign) continue;
      checkedPieces.push(board[c][r]);
    }
  }

  if (new IntList(R, pR).hasValue(type)) {
    for (int i = 0; i < 8; i += 2) {
      for (int j = 1; j < 9; j++) {
        int r = j * dx[i] + w;
        int c = j * dy[i] + h;

        if (isOutOfRange(r, c) || pieceSign(r, c) == sign) break;
        checkedPieces.push(board[c][r]);
        if (pieceSign(r, c) != 0) break;
      }
    }
  }

  if (new IntList(B, pB).hasValue(type)) {
    for (int i = 1; i < 9; i += 2) {
      for (int j = 1; j < floor(9 * sqrt(2)); j++) {
        int r = j * dx[i] + w;
        int c = j * dy[i] + h;

        if (isOutOfRange(r, c) || pieceSign(r, c) == sign) break;
        checkedPieces.push(board[c][r]);
        if (pieceSign(r, c) != 0) break;
      }
    }
  }

  if (new IntList(G, pP, pL, pN, pS).hasValue(type)) {
    for (int i = 0; i < 8; i++) {
      if (new IntList(5, 7).hasValue(i)) continue;
      int r = -sign * dx[i] + w;
      int c = -sign * dy[i] + h;

      if (isOutOfRange(r, c) || pieceSign(r, c) == sign) continue;
      checkedPieces.push(board[c][r]);
    }
  }

  if (new IntList(pR, pB, K, pK).hasValue(type)) {
    for (int i = 0; i < 8; i++) {
      int r = dx[i] + w;
      int c = dy[i] + h;

      if (isOutOfRange(r, c) || pieceSign(r, c) == sign) continue;
      checkedPieces.push(board[c][r]);
    }
  }
}

boolean isChecked() { // チェック(王手)されているか判定
  checkedPieces.clear();
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      if (pieceSign(i, j) != turn) {
        checkPiece(i, j);
      }
    }
  }
  return checkedPieces.hasValue(K) || checkedPieces.hasValue(-pK);
}

void putStock() { // 持ち駒を使用
  int piece = stockOrder[stockIndex];

  if (stocks[int(turn == 1)][piece] == 0) return;

  initMovable();
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      isMovable[j][i] = board[j][i] == 0;
    }
  }

  if (piece == P) {
    IntList[] b = new IntList[9];
    for (int i = 0; i < 9; i++) {
      b[i] = new IntList(board[i]);
    }
    for (int i = 0; i < 9; i++) {
      for (int j = i; j < 9; j++) {
        int tmp = b[j].get(i);
        b[j].set(i, b[i].get(j));
        b[i].set(j, tmp);
      }
    }
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (b[i].hasValue(turn * P)) {
          isMovable[j][i] = false;
        }
      }
      int k = turn == 1 ? 0 : 8;
      isMovable[k][i] = false;
    }
  } else if (piece == L) {
    for (int i = 0; i < 9; i++) {
      int j = turn == 1 ? 0 : 8;
      isMovable[j][i] = false;
    }
  } else if (piece == N) {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 2; j++) {
        int k = turn == 1 ? j : 8 - j;
        isMovable[k][i] = false;
      }
    }
  }

  pieceX = pieceY = 10;
}

void setup() {
  size(720, 960);
  rectMode(CENTER);
  imageMode(CENTER);
  textAlign(CENTER, CENTER);
  textFont(createFont("Meiryo", block * 3 / 4));
  initMovable();

  for (int i = P; i <= pK; i++) {
    pieces[i] = loadImage("img/" + nf(i, 2) + ".png");
    pieces[i].resize(int(block - 10), int(block - 10));
  }

  noLoop();
}

void draw() {
  background(#FFFFFF);

  fill(#008000);
  noStroke();
  rect(halfScreen, 1.5 * block, screen + 2, block);
  rect(halfScreen, 11.5 * block, screen + 2, block);
  showStock(1);
  showStock(-1);

  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      push();
      translate(i * block + block / 2, (j + 2) * block + block / 2);
      fill((i == pieceX && j == pieceY) || isMovable[j][i] ?
        #228B22 : #DAA520);
      stroke(#000000);
      rect(0, 0, block, block);
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
  square(pieceX * block + block / 2,
    (pieceY + 2) * block + block / 2, block);

  showTurn();

  if (!gameEnds && isPromoting) {
    askPromote();
    turn = -turn;
  }
}

void mousePressed() {
  if (gameEnds) return;

  if (isPromoting) {
    if (buttonPressed(0)) {
      promote(promoX, promoY, -turn);
      promoX = promoY = 10;
      isPromoting = false;
      redraw();
    } else if (buttonPressed(2.5 * block)) {
      isPromoting = false;
      redraw();
    }
    return;
  }

  int r = floor(mouseX / block);
  int c = floor(mouseY / block) - 2;

  if (((turn == 1 && c == 9) || (turn == -1 && c == -1)) &&
    stocks[int(turn == 1)][stockOrder[r - 1]] > 0) {
    stockIndex = r - 1;
    putStock();
    redraw();
    push();
    noFill();
    stroke(#0000FF);
    square(r * block + block / 2, (c + 2) * block + block / 2, block);
    pop();
  }

  if (isOutOfRange(r, c)) return;

  if (board[c][r] != 0 &&
    pieceSign(r, c) == turn) {
    updatePlacable(r, c);
  }

  if (isMovable[c][r]) {
    if (board[c][r] != 0) {
      int type = pieceType(r, c);
      if (type >= pP && type <= pB) {
        type -= 7;
      }
      if (type < K) {
        stocks[int(turn == 1)][type]++;
      }
    }

    if (!isOutOfRange(pieceX, pieceY) &&
      board[pieceY][pieceX] != 0) {
      if (((turn == 1 && c <= 2) || (turn == -1 && c >= 6)) &&
        pieceType(pieceX, pieceY) <= B) {
        isPromoting = true;
        promoX = r;
        promoY = c;
      }
    }

    gameEnds = pieceType(r, c) >= K;
    initMovable();

    if (isOutOfRange(pieceX, pieceY)) {
      int piece = turn * stockOrder[stockIndex];
      board[c][r] = piece;
      stocks[int(turn == 1)][abs(piece)]--;
    } else {
      board[c][r] = board[pieceY][pieceX];
      board[pieceY][pieceX] = 0;
      pieceX = pieceY = 10;
    }

    int piece = board[c][r];
    if ((new IntList(+P, +L).hasValue(piece) && c == 0) ||
      (new IntList(-P, -L).hasValue(piece) && c == 8) ||
      (piece == +N && c <= 1) || (piece == -N && c >= 7)) {
      promote(r, c, turn);
      isPromoting = false;
    }

    if (!gameEnds && !isPromoting) turn = -turn;
  }

  redraw();
}
