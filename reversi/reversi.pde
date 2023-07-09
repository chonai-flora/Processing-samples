import java.util.Arrays;
import java.util.Map;

final int screen = 720;
final int block = screen / 8;

final int B = -1, W = +1;
final HashMap<Integer, String> userName = new HashMap<Integer, String>() {
    { put(W, "兄貴"); put(B, "妹"); }
};

final int[] dx = {1, 1, 0, -1, -1, -1, 0, 1};
final int[] dy = {0, 1, 1, 1, 0, -1, -1, -1};

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

int turn = W;
boolean gameEnds = false;
boolean passed = false;
int prevX = -1, prevY = -1;

int flipAngle = 0;
int flipSpeed = 9;
boolean[][] flippings = new boolean[8][8];

boolean isOutOfRange(int w, int h) {
  return (w < 0 || h < 0 || w > 7 || h > 7);
}

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

void initFlippings() {
  for (boolean[] line : flippings) {
    Arrays.fill(line, false);
  }
}

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
      text(String.format("%d枚差で%sの勝利です", diff, userName.get(int(Math.signum(total)))), 12, block / 2);
    }
  } else {
    text(userName.get(turn) + "のターンです", 12, block / 2);
  }
}

void changeTurn() {
  flipAngle = 0;
  initFlippings();
  turn = -turn;
}

void updateBoard(int w, int h) {
  for (int i = 0; i < 8; i++) {
    ArrayList<int[]> flippableDisks = new ArrayList <int[]>();
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

      if (sq(x - 4) + sq(y - 4) == 8) {
        fill(#000000);
        noStroke();
        circle(x * block, (y + 1) * block, block / 10);
      }

      if (board[y][x] == 0) {
        if (!blankExists) {
          blankExists = true;
        }
        continue;
      }

      if (flippings[y][x]) {
        ratio = cos(PI / 180 * flipAngle);
        if (flipAngle == 90) {
          board[y][x] = turn;
        } else if (flipAngle == 180) {
          changeTurn();
        }
      }

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

        if (!isFlipping()) {
          noStroke();
          fill(#C0C0C0);
          circle((x + 0.5) * block, (y + 1.5) * block, block / 5);
        }
      }
    }
  }

  showTurn();

  if (gameEnds) return;
  
  if (isFlipping()) {
    flipAngle += flipSpeed;
  } else if (passTurn) {
    if (passed) {
      gameEnds = true;
    }
    else {
      passed = true;
    }
    changeTurn();
  }
}

void mousePressed() {
  int p = floor(mouseX / block);
  int q = floor(mouseY / block) - 1;

  if (gameEnds || isFlipping() || isOutOfRange(p, q) || board[q][p] != 0) {
    return;
  }

  updateBoard(p, q);
  prevX = p; prevY = q;
}
