// 評価値CPU

import java.util.Arrays;
import java.util.Collections;

final int screen = 720;
final int block = screen / 8;

final int B = -1, W = +1;

// 8方向の変化量
final int[] dx = {1, 1, 0, -1, -1, -1, 0, 1};
final int[] dy = {0, 1, 1, 1, 0, -1, -1, -1};

// 盤面
int[][] board = {
  {0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, B, W, 0, 0, 0},
  {0, 0, 0, W, B, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0}
};

// 各マスの評価値
int[][] boardEvaluations = {
  { 30, -12,   0,  -1,  -1,   0, -12,  30},
  {-12, -15,  -3,  -3,  -3,  -3, -15, -12},
  {  0,  -3,   0,  -1,  -1,   0,  -3,   0},
  { -1,  -3,  -1,  -1,  -1,  -1,  -3,  -1},
  { -1,  -3,  -1,  -1,  -1,  -1,  -3,  -1},
  {  0,  -3,   0,  -1,  -1,   0,  -3,   0},
  {-12, -15,  -3,  -3,  -3,  -3, -15, -12},
  { 30, -12,   0,  -1,  -1,   0, -12,  30}
};

// ターン, ゲームステータス, パスしたかどうか
int turn = W;
boolean gameEnds = false;
boolean passed = false;

// CPU関連
int timing = 0;
int cpuMod = 60;
int prevX = -1, prevY = -1;

// 反転関連
int flipAngle = 0;
int flipSpeed = 9;
boolean[][] flippings = new boolean[8][8];

// 範囲外かどうか
boolean isOutOfRange(int w, int h) {
  return (w < 0 || h < 0 || w > 7 || h > 7);
}

// 反転している最中かどうか
boolean isFlipping() {
  for (boolean[] line : flippings) {
    for (int i = 0; i < 8; i++) {
      if (line[i]) {
        return true;
      }
    }
  }
  return false;
}

// 反転できる駒のステータスを初期化
void initFlippings() {
  for (boolean[] line : flippings) {
    Arrays.fill(line, false);
  }
}

// ターンを表示
void showTurn() {
  fill(#000000);
  noStroke();
  if (gameEnds) {
    int total = 0;
    for (int[] line : board) {
      total += Arrays.stream(line).sum();
    }
    if (total == 0) {
      text("引き分けです", 12, block / 2);
    } else {
      int diff = abs(total);
      text(String.format("%d枚差で%sの勝利です", diff, total > 0 ? "あなた" : "CPU"), 12, block / 2);
    }
  } else {
    if (turn == W) {
      text("あなたのターンです", 12, block / 2);
    } else {
      int n = frameCount % cpuMod / 20 % 3 + 1;
      String dots = String.join("", Collections.nCopies(n, ". "));
      text("CPUのターンです" + dots, 12, block / 2);
    }
  }
}

// ターンチェンジ
void changeTurn() {
  flipAngle = 0;
  initFlippings();
  turn = -turn;
}

// 反転させる駒を更新
void updateBoard(int w, int h) {
  for (int i = 0; i < 8; i++) {
    ArrayList<int[]> flippableDisks = new ArrayList<int[]>();
    for (int distance = 1; distance < 11; distance++) {
      int p = distance * dx[i] + w;
      int q = distance * dy[i] + h;

      if (isOutOfRange(p, q) || board[q][p] == 0) {
        flippableDisks.clear();
        break;
      } else if (board[q][p] == turn) {
        break;
      } else {
        int[] pos = {p, q};
        flippableDisks.add(pos);
      }
    }

    for (int[] disk : flippableDisks) {
      flippings[disk[1]][disk[0]] = true;
      if (board[h][w] != turn) {
        board[h][w] = turn;
      }
    }
  }
}

// 反転可能かどうか
boolean isFlippable(int w, int h) {
  for (int i = 0; i < 8; i++) {
    int count = 0;
    for (int distance = 1; distance < 11; distance++) {
      int p = distance * dx[i] + w;
      int q = distance * dy[i] + h;

      if (isOutOfRange(p, q) || board[q][p] == 0) {
        count = 0;
        break;
      } else if (board[q][p] == turn) {
        break; 
      } else {
        count++;
      }
    }
    
    if (count > 0) {
      return true;
    }
  }
  return false;
}

// CPU操作
void cpu() {
  int p = -1, q = -1;
  int maxEvaluation = -100;
  for (int y = 0; y < 8; y++) {
    for (int x = 0; x < 8; x++) {
      if (board[y][x] != 0 || !isFlippable(x, y)) {
        continue;
      } 
      
      int boardEvaluation = boardEvaluations[y][x];
      if (maxEvaluation <= boardEvaluation) {
        if (maxEvaluation == boardEvaluation && random(1) < 0.5) {
          continue;
        }

        maxEvaluation = boardEvaluation;
        p = x; q = y;
      }
    }
  }
  
  if (p < 0 || q < 0) {
    changeTurn();
  } else {
    updateBoard(p, q);
    timing = -1;
    prevX = p; prevY = q;
  }
}

void updateCpu() {
  cpuMod = int(random(2, 4)) * 30;
  timing = frameCount % cpuMod;
}

void setup() {
  size(720, 810);
  strokeWeight(2);
  textAlign(LEFT, CENTER);
  textFont(createFont("Meiryo", block / 2));

  initFlippings();
}

void draw() {
  background(#FFFAFA);

  boolean blankExists = false;
  for (int y = 0; y < 8; y++) {
    for (int x = 0; x < 8; x++) {
      float ratio = 1.0;
      fill(x == prevX && y == prevY ? #008000 : #6B8E23);
      stroke(#000000);
      square(x * block, (y + 1) * block, block);

      // 盤面に黒点を描写
      if (sq(x - 4) + sq(y - 4) == 8) {
        fill(#000000);
        noStroke();
        circle(x * block, (y + 1) * block, block / 10);
      }

      // 盤面に何も置かれていなければ continue
      if (board[y][x] == 0) {
        if (!blankExists) {
          blankExists = true;
        }
        continue;
      }

      // 反転アニメーション
      if (flippings[y][x]) {
        ratio = cos(PI / 180 * flipAngle);
        if (flipAngle == 90) {
          board[y][x] = turn;
        } else if (flipAngle == 180) {
          changeTurn();
          passed = false;
        }
      }
      
      // 駒を表示
      noStroke();
      fill(board[y][x] == W ? #FFFFFF : #000000);
      ellipse((x + 0.5) * block, (y + 1.5) * block, ratio * (block / 1.5), block / 1.5);
    }
  }
  
  if (!blankExists && !isFlipping()) {
    gameEnds = true;
  }

  boolean passTurn = true;
  for (int y = 0; y < 8; y++) {
    for (int x = 0; x < 8; x++) {
      if (board[y][x] != 0) continue;

      if (isFlippable(x, y)) {
        if (passTurn) {
          passTurn = false;
        }

        if (turn == W && !isFlipping()) {
          noStroke();
          fill(#C0C0C0);
          circle((x + 0.5) * block, (y + 1.5) * block, block / 5);
        }
      }
    }
  }

  showTurn();

  if (gameEnds) return;

  if (turn == B && frameCount % cpuMod == timing) {
    cpu();
  }

  if (isFlipping()) {
    flipAngle += flipSpeed;
  } else if (passTurn) {
    if (passed) {
      gameEnds = true;
    } else {
      passed = true;
    }
    
    updateCpu();
    changeTurn();
  }
}

void mousePressed() {
  int p = floor(mouseX / block);
  int q = floor(mouseY / block) - 1;

  if (gameEnds || isFlipping() || turn == B || isOutOfRange(p, q) || board[q][p] != 0) {
    return;
  }

  updateBoard(p, q);
  updateCpu();
}
