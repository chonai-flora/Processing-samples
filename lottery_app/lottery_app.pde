import java.util.Map;
import java.util.LinkedHashMap;

final int MI = 0, AC = 1, BC = 2, AP = 3;
final String[] courseNames = {"MI", "AC", "BC", "AP"};

PImage background;
PrintWriter logFile;
PFont emojiFont;
PFont listFont1;
PFont listFont2;
PFont titleFont;

int centerX() {
  return width / 2;
}

int centerY() {
  return height / 2;
}

class Lottery {
  HashMap<Integer, HashMap<Integer, IntList>> students;

  Lottery(int mi1, int ac1, int bc1,
    int mi2, int ac2, int bc2,
    int mi3, int ac3, int bc3,
    int mi4, int ac4, int bc4,
    int mi5, int ac5, int bc5,
    int ap1, int ap2) {
    this.students = new HashMap<Integer, HashMap<Integer, IntList>>() {
      {
        put(MI, new HashMap<Integer, IntList>() {
          {
            put(1, range(1, mi1));
            put(2, range(1, mi2));
            put(3, range(1, mi3));
            put(4, range(1, mi4));
            put(5, range(1, mi5));
          }
        });
        put(AC, new HashMap<Integer, IntList>() {
          {
            put(1, range(1, ac1));
            put(2, range(1, ac2));
            put(3, range(1, ac3));
            put(4, range(1, ac4));
            put(5, range(1, ac5));
          }
        });
        put(BC, new HashMap<Integer, IntList>() {
          {
            put(1, range(1, bc1));
            put(2, range(1, bc2));
            put(3, range(1, bc3));
            put(4, range(1, bc4));
            put(5, range(1, bc5));
          }
        });
        put(AP, new HashMap<Integer, IntList>() {
          {
            put(1, range(1, ap1));
            put(2, range(1, ap2));
          }
        });
      }
    };
  }

  // [start, end] の配列を生成
  IntList range(int start, int end) {
    IntList ids = new IntList();

    for (int id = start; id <= end; id++) {
      ids.append(Integer.valueOf(id));
    }

    return ids;
  }

  // 欠席者等を除外
  void removeStudents(Integer grade, int course, IntList ids) {
    if (!this.students.get(course).containsKey(grade)) return;

    for (Integer id : ids) {
      for (int n : this.students.get(course).get(grade)) {
        if (n == id) {
          this.students.get(course).get(grade).remove(n);
        }
      }
    }
  }
  
  // ランダムに学生を選択
  StringList chooseStudents(int n, String title, boolean insertLineFeed) {
    StringList winners = new StringList();
    if (title.length() > 0) {
      logFile.println(String.format("<%s>", title));
    }

    int chooseCount = 0;
    while (chooseCount < n) {
      int course = int(random(BC) + 1);
      int grade = int(random(1, (course == AP ? 2 : 5) + 1));
      IntList classroom = this.students.get(course).get(grade);
      if (classroom.size() <= 0) continue;

      // 要素を抽出・削除
      int selectedIndex = int(random(classroom.size()));
      String student = toString(grade, course, classroom.get(selectedIndex));
      this.students.get(course).get(grade).remove(selectedIndex);

      winners.append(student);
      logFile.println(student);

      chooseCount++;
    }

    if (insertLineFeed) {
      logFile.println();
    }
    return winners;
  }

  String toString(int grade, int course, int id) {
    String courseName = courseNames[course];

    return String.format("%d%s%02d", grade, courseName, id);
  }
}

class Slide {
  StringList messages;
  PFont textFont;

  Slide(StringList messages, PFont textFont) {
    this.messages = messages;
    this.textFont = textFont;
  }

  void draw() {
    int len = this.messages.size();

    if (len == 0) {
      return;
    } else if (len == 1) {
      String message = this.messages.get(0);

      textWithShadow(message, centerX(), centerY(), #FFFAFA);
    } else if (len == 2) {
      for (int i = 0; i < 2; i++) {
        String message = this.messages.get(i);

        textWithShadow(message, centerX(), centerY() + i * 200 - 100, #FFFAFA);
      }
    } else {
      StringBuilder messageBuilder = new StringBuilder(len == 7 ? "     " : "");
      for (int i = 0; i < len; i++) {
        messageBuilder.append(this.messages.get(i));

        if (i == len / 2 - 1) {
          messageBuilder.append("\n\n");
        } else if (i != len - 1) {
          messageBuilder.append("  ");
        }
      }

      textWithShadow(messageBuilder.toString(), centerX(), centerY(), #FFFAFA);
    }
  }

  void textWithShadow(String message, int x, int y, color textColor) {
    textFont(this.textFont);
    fill(0, 180);
    text(message, x + 5, y + 5);
    fill(textColor);
    text(message, x, y);
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
  }
}

Lottery lottery;
Snowfall[] snowfalls;
ArrayList <Slide> slides;

void setup() {
  fullScreen();
  textAlign(CENTER, CENTER);

  // 背景, フォント, ログファイルを生成
  String path = "https://raw.githubusercontent.com/chonai-flora/Processing-samples/main/lottery_app/img/back1.png";
  background = loadImage(path);
  background.resize(width, height);
  emojiFont = createFont("Segoe UI Emoji", 100);
  listFont1 = createFont("游ゴシック Medium", 120);
  listFont2 = createFont("游ゴシック Medium", 140);
  titleFont = createFont("游ゴシック Medium", 160);
  logFile = createWriter("winners.txt");

  // 1~5年生までの3学科+専攻科2学年の人数を指定
  lottery = new Lottery(43, 42, 45,
    47, 43, 42,
    44, 43, 50,
    44, 44, 38,
    39, 45, 39,
    0, 0);

  // 欠席者等を除外
  //lottery.removeStudents(3, MI, new IntList());

  // 雪を生成
  snowfalls = new Snowfall[250];
  for (int i = 0; i < snowfalls.length; i++) {
    boolean isCrystal = (i % 2 == 0);
    snowfalls[i] = new Snowfall(isCrystal, emojiFont);
  }

  // 抽選・当選画面を生成
  Map<String, Integer> gifts = new LinkedHashMap<String, Integer>() {
    {
      put("カップラーメンセット(60名)", 60);
      put("お菓子セット(60名)", 60);
      put("ハーゲンダッツ(40名)", 40);
      put("ギフトカード(7名)", 7);
      put("3等 手袋(1名)", 1);
      put("3等 トートバッグ(1名)", 1);
      put("3等 ハンカチ(1名)", 1);
      put("2等 yogibo(1名)", 1);
      put("2等 ブランケット(1名)", 1);
      put("1等 ドライヤー(1名)", 1);
      put("1等 プロジェクター(1名)", 1);
      put("1等 スピーカー(1名)", 1);
      put("1等 ワイヤレスイヤフォン(1名)", 1);
    }
  };

  slides = new ArrayList<Slide>();
  slides.add(new Slide(new StringList("クリスマス抽選会"), titleFont));
  gifts.forEach((title, n) -> {
    slides.add(new Slide(new StringList(title.split(" ")), titleFont));

    if (n % 10 == 0) {
      slides.add(new Slide(lottery.chooseStudents(10, title, false), listFont1));
      for (int i = 1; i < n / 10; i++) {
        boolean insertLineFeed = (i == n / 10 - 1);
        slides.add(new Slide(lottery.chooseStudents(10, "", insertLineFeed), listFont1));
      }
    } else {
      slides.add(new Slide(lottery.chooseStudents(n, title, true), listFont2));
    }
  });
  slides.add(new Slide(new StringList("当選者の皆さん", "おめでとうございます！"), titleFont));

  logFile.close();
}

// スライドのインデックス
int slideIndex = 0;

void draw() {
  clear();

  // 背景画像表示
  image(background, 0, 0);

  // 雪を降らせる
  for (Snowfall snowfall : snowfalls) {
    snowfall.update();
    snowfall.draw();
  }

  // スライド表示
  slides.get(slideIndex).draw();

  // 飾り
  if (slideIndex == 0) {
    noStroke();
    textFont(listFont1);
    float ratio = cos(radians(2 * frameCount));
    for (int i = 0; i < 2; i++) {
      push();
      int delta = (i == 0 ? 5 : 0);
      translate(centerX() + delta, centerY() + 300 + delta);
      fill(i == 0 ? #000000 : #FFFFFF);
      push();
      scale(1.0, ratio);
      quad(60 - 300, 0, -300, 30, 15 - 300, 0, -300, -30);
      quad(300 - 60, 0, 300, 30, 300 - 15, 0, 300, -30);
      pop();
      text("START", 0, 0);
      pop();
    }
  }
}

void keyPressed() {
  // 十字キーでスライド切り替え
  if (slideIndex != 0 && keyCode == LEFT) {
    slideIndex--;
  } else if (keyCode == RIGHT) {
    slideIndex++;

    if (slideIndex >= slides.size()) {
      exit();
    }
  }
}
