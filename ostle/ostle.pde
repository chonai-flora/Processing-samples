// ルール: https://gamemarket.jp/game/76310

import java.util.Map;
import java.util.Arrays;

final int screenSize = 720;
final float blockSize = screenSize / 5 - 1.25;

// 4方向の変化量
int[] dx = { 1, 0, -1, 0 };
int[] dy = { 0, 1, 0, -1 };

// silver, grey, hole
final int S = +1, G = -1, H = +2;
HashMap<Integer, HashMap<String, Integer>> players = new HashMap<Integer, HashMap<String, Integer>>() {
  {
    put(S, new HashMap<String, Integer>() {
      {
        put("palette", #fffafa);
        put("score", 0);
      }
    });
    put(G, new HashMap<String, Integer>() {
      {
        put("palette", #808080);
        put("score", 0);
      }
    });
  }
};

int[][] board = { // 盤面
  { S, S, S, S, S },
  { 0, 0, 0, 0, 0 },
  { 0, 0, H, 0, 0 },
  { 0, 0, 0, 0, 0 },
  { G, G, G, G, G }
};
int turn = S; //　ターン
int winner = 0; // 勝者
int currentX = -1, currentY = -1; // 現在の座標
int[][] prevBoard = null; // 1つ前の盤面
boolean[][] legalMoves = new boolean[5][5]; // 移動可能かどうか

// 移動可能な位置を初期化
void initLegalMoves() {
  for (boolean[] line : legalMoves) {
    Arrays.fill(line, false);
  }
}

// スコアを取得
int getScore(int player) {
  return players.get(player).get("score");
}

// ターンチェンジ
void changeTurn() {
  turn = -turn;
  currentX = -1; currentY = -1;

  if (getScore(S) >= 2) {
    winner = S;
  } else if (getScore(G) >= 2) {
    winner = G;
  }
}

// 盤面の範囲外かどうか
boolean isOutOfRange(int w, int h) {
  return (w < 0 || h < 0 || w >= 5 || h >= 5);
}

// 指定した座標が穴かどうか
boolean isHole(int w, int h) {
  return (board[h][w] == H);
}

// スコアを追加
void increaseScore(int w, int h) {
  int score = getScore(-board[h][w]);
  players.get(-board[h][w]).put("score", score + 1);
}

// 二次元配列をディープコピー
int[][] structuredClone(int[][] from) {
  int[][] to = new int[5][5];
  for (int i = 0; i < 5; i++) {
    to[i] = from[i].clone();
  }
  return to;
}

// 1つ前の座標と一致しているかどうか判定
boolean isPrevPosition(int fromX, int fromY, int toX, int toY) {
  if (prevBoard == null) return false;

  int[][] b = structuredClone(board);
  shiftPieces(b, fromX, fromY, toX, toY, false);

  return Arrays.deepEquals(b, prevBoard);
}

// 移動可能な位置を更新
void updateMoves(int w, int h) {
  initLegalMoves();
  if (!isHole(w, h) && board[h][w] != turn) return;

  for (int i = 0; i < 4; i++) {
    int p = dx[i] + w;
    int q = dy[i] + h;

    if (isOutOfRange(p, q)) continue;
    if (isHole(p, q)) continue;
    if (isHole(w, h) && board[q][p] != 0) continue;
    if (isPrevPosition(w, h, p, q)) continue;

    legalMoves[q][p] = true;
  }

  currentX = w; currentY = h;
}

// 駒を移動
void shiftPieces(int[][] b, int fromX, int fromY, int toX, int toY, boolean countScore) {
  if (countScore) initLegalMoves();

  if (isOutOfRange(toX, toY)) {
    if (countScore) {
      increaseScore(fromX, fromY);
    }
    return;
  } else if (isHole(toX, toY)) {
    if (countScore) {
      increaseScore(fromX, fromY);
      b[toY][toX] = H;
      b[fromY][fromX] = 0;
    }
    return;
  } else if (b[toY][toX] != 0) {
    shiftPieces(b, toX, toY, 2 * toX - fromX, 2 * toY - fromY, countScore);
  }

  b[toY][toX] = b[fromY][fromX];
  b[fromY][fromX] = 0;
}

// ターンを表示
void showTurn() {
  int player = winner != 0 ? winner : turn;
  fill(players.get(player).get("palette"));
  stroke(#000000);
  strokeWeight(4);
  square(42, 60, blockSize / 4);
  fill(#000000);
  noStroke();
  textSize(blockSize / 4);
  if (winner != 0) {
    text("　の勝利です", 30, blockSize / 2);
  } else {
    text("　のターンです", 30, blockSize / 2);
    text(String.format("あと%d取れば勝利です", 2 - getScore(turn)), 25, blockSize / 1.25);
  }
}

void setup() {
  size(720, 860);
  rectMode(CENTER);
  textAlign(LEFT, BASELINE);
  textFont(createFont("Meiryo", blockSize / 2));
  noLoop();

  initLegalMoves();
}

void draw() {
  background(#ffffff);
  showTurn();

  for (int c = 0; c < 5; c++) {
    for (int r = 0; r < 5; r++) {
      float x = (r + 0.5) * blockSize + 3;
      float y = (c + 1.5) * blockSize + 3;

      fill(legalMoves[c][r] ? #a9a9a9 : #d3d3d3);
      stroke(#000000);
      strokeWeight(5);
      square(x, y, blockSize);

      if (abs(board[c][r]) == 1) {
        fill(players.get(board[c][r]).get("palette"));
        strokeWeight(blockSize / 20);
        rect(x, y, blockSize / 2, blockSize / 2, blockSize / 20);
      } else if (isHole(r, c)) {
        fill(#000000);
        noStroke();
        circle(x, y, blockSize / 1.5);
      }
    }
  }

  fill(#d3d3d3);
  noStroke();
  for (int c = 0; c <= 5; c++) {
    for (int r = 0; r <= 5; r++) {
      float x = r * blockSize + 3;
      float y = (c + 1) * blockSize + 3;
      for (int i = 0; i < 2; i++) {
        square(blockSize / 2 * dx[i] + x, blockSize / 2 * dy[i] + y, 6);
      }
    }
  }
}

void mousePressed() {
  int p = floor(mouseX / blockSize);
  int q = floor(mouseY / blockSize) - 1;
  if (winner != 0 || isOutOfRange(p, q)) return;

  if (legalMoves[q][p]) {
    prevBoard = structuredClone(board);
    shiftPieces(board, currentX, currentY, p, q, true);
    initLegalMoves();
    changeTurn();
  } else {
    updateMoves(p, q);
  }

  redraw();
}
