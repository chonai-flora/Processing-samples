final String keyCodes =
  "QWERTYUIOP" +
  "ASDFGHJKL" +
  "\nZXCVBNM\b";
String answer;
String[] words;
color[] keyColors = new color[28];
color[] responceColors = new color[5];
char[][] wordCards = new char[6][5];
color[][] wordColors = new color[6][5];

int score;
boolean gameEnds;
boolean isFlipping;
int flipAngle;
int wordCount;
int wordIndex;
int alertMod;
float alertDelta;

void showKeyBlock() {
  int index = 0;
  for (int i = 0; i < 3; i++) {
    int margin = int(i == 0);
    for (int j = 0; j < margin + 9; j++) {
      String key = str(keyCodes.charAt(index));
      float x = (j + 1.5) * 60 - margin * 30 + 26;
      float y = i * 60 + 740;
      int side = 52;
      if (key.equals("\n")) {
        key = "ENTER";
        x -= 15;
        side += 30;
      } else if (key.equals("\b")) {
        key = "⌫";
        x += 15;
        side += 30;
      }

      fill(keyColors[index]);
      rect(x, y, side, 52);
      fill(#FFFFFF);
      textSize(48 - min(side / 2, 32));
      text(key, x, y);
      index++;
    }
  }
}

void setKeyColors() {
  if (wordCount > 5 || score > 4) {
    showResult();
  } else {
    fill(#000000);
    rect(360, 836, 720, 246);
  }
  showKeyBlock();
}

void setAnswer() {
  answer = words[int(random(words.length))].toUpperCase();
}

void checkAnswer() {
  char[] mismatches = answer.toCharArray();
  for (int i = 0; i < 5; i++) {
    char c = wordCards[wordCount][i];
    int keyIndex = keyCodes.indexOf(c);
    if (c == answer.charAt(i)) {
      score++;
      mismatches[i] = ' ';
      keyColors[keyIndex] =
        responceColors[i] = #538D4E;
    } else {
      responceColors[i] = #3A3A3C;
      if (keyColors[keyIndex] != #538D4E) {
        keyColors[keyIndex] = #3A3A3C;
      }
    }
  }

  for (int i = 0; i < 5; i++) {
    char c = wordCards[wordCount][i];
    int keyIndex = new String(keyCodes).indexOf(c);
    int mismatchIndex = new String(mismatches).indexOf(c);

    if (mismatchIndex != -1) {
      mismatches[mismatchIndex] = ' ';
      responceColors[i] = #B59F3B;
      if (keyColors[keyIndex] != #538D4E) {
        keyColors[keyIndex] = #B59F3B;
      }
    }

    //boolean charExists = false;
    //for (int j = 0; j < mismatches.length; j++) {
    //  if (c == mismatches[j]) {
    //    charExists = true;
    //    break;
    //  }
    //}

    //if (charExists) {
    //  responceColors[i] = #B59F3B;
    //  if (keyColors[index] != #538D4E) {
    //    keyColors[index] = #B59F3B;
    //  }
    //}
  }
}

void setCardColor() {
  wordColors[wordCount][wordIndex] = responceColors[wordIndex];
}

void setGame() {
  score = 0;
  gameEnds = isFlipping = false;
  flipAngle = wordCount = wordIndex = 0;
  alertMod = 60;
  alertDelta = 0;
  for (int i = 0; i < 5; i++) {
    for (int j = 0; j < 6; j++) {
      wordCards[j][i] = ' ';
      wordColors[j][i] = #000000;
    }
  }
  for (int i = 0; i < keyCodes.length(); i++) {
    keyColors[i] = #818384;
  }
  setAnswer();
  setKeyColors();
}

void setup() {
  size(720, 960);
  strokeWeight(3);
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  textFont(createFont("Segoe UI Symbol", 1));
  final String URL =
    "https://gist.githubusercontent.com/cfreshman/" +
    "a03ef2cba789d8cf00c08f767e0fad7b/raw/" + "
    "5d752e5f0702da315298a6bb5a771586d6ff445c/wordle-answers-alphabetical.txt"
    ;
  words = loadStrings(URL);

  setGame();
}

void draw() {
  if (gameEnds) return;

  fill(#000000);
  rect(360, 355, 720, 710);
  for (int i = 0; i < 5; i++) {
    for (int j = 0; j < 6; j++) {
      push();
      translate((i + 1.5) * 102, (j + 1) * 102);
      if (wordIndex == i && wordCount == j) {
        float ratio = abs(cos(PI / 180 * flipAngle));
        scale(1, ratio);
      }
      if (alertMod != 60 && wordCount == j) {
        float theta = PI / 6 * (frameCount % 60 - alertMod);
        translate(max(alertDelta, 0) * sin(theta), 0);
      }
      fill(wordColors[j][i]);
      stroke(#3A3A3C);
      rect(0, 0, 92, 92, 10);
      fill(#FFFFFF);
      noStroke();
      textSize(48);
      text(wordCards[j][i], 0, 0);
      pop();
    }
  }

  if (isFlipping) {
    flipAngle += 9;
    if (flipAngle == 90) {
      setCardColor();
    } else if (flipAngle == 180) {
      wordIndex++;
      flipAngle = 0;
    }
    if (wordIndex > 4) {
      flipAngle = 0;
      isFlipping = false;
      wordCount++;
      wordIndex = 0;
      setKeyColors();
    }
  }

  if (alertMod != 60) {
    alertDelta -= 0.2;

    noStroke();
    fill(#FFFFFF);
    rect(360, 360, 240, 90);
    fill(#000000);
    textSize(24);
    text("Not in word list", 360, 360);

    if (frameCount % 60 == alertMod) {
      alertMod = 60;
    }
  }
}

void showResult() {
  noStroke();
  fill(#FFFFFF);
  rect(360, 360, 360, 180);
  fill(#000000);
  textSize(36);
  text(
    score > 4 ? "Congrats! 🎉" : "Oops!",
    360, 315
    );
  textSize(16);
  text("The word was \"" + answer + "\"", 360, 372);
  textSize(14);
  text("Press Enter to Play Again", 360, 400);
  gameEnds = true;
}

void keyPressed() {
  char c = Character.toUpperCase(key);
  if (gameEnds) {
    if (c == '\n') setGame();
    return;
  }
  for (int i = 0; i < keyCodes.length(); i++) {
    if (c == keyCodes.charAt(i)) {
      if (isFlipping) return;
      if (c == '\b') {
        if (wordIndex > 0) {
          wordIndex--;
          wordCards[wordCount][wordIndex] = ' ';
        }
      } else if (c == '\n') {
        String word = new String(wordCards[wordCount]).toLowerCase();
        if (wordIndex >= 5) {
          boolean wordExists = false;
          for (String s : words) {
            if (s.equals(word)) {
              wordExists = true;
              println(0);
              break;
            }
          }

          if (wordExists) {
            isFlipping = true;
            score = 0;
            wordIndex = 0;
            checkAnswer();
          } else {
            alertMod = frameCount % 60;
            alertDelta = 8;
          }
        }
      } else if (wordIndex < 5) {
        wordCards[wordCount][wordIndex] = c;
        wordIndex++;
      }

      break;
    }
  }
}
