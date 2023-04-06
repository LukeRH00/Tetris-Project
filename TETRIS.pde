
final color bkgd = color(60);
final color grid = color(110);
final color blk = color(0);
final color W = color(255);
//LB, B, O, Y, G, P, R
final color[] colArr = {color(0,255,255),color(0,0,255),color(255,191,0),color(255,255,0),color(0,255,0),color(255,0,255),color(255,0,0)};
int[][] gridData = new int[10][20];
int frameCntr = 0;
int toDrop = 40;
//starting at 4,1 from 0, 0
//iD, rotation, block, xy-pair
int[][][][] pos  = {
  {{{0,0},{-1,0},{1,0},{2,0}},
    {{1,-1},{1,0},{1,1},{1,2}},
    {{-1,1},{0,1},{1,1},{2,1}},
    {{0,0},{0,-1},{0,1},{0,2}}},
  {{{0,0},{-1,0},{-1,-1},{1,0}},
    {{0,0},{0,1},{0,-1},{1,-1}},
    {{0,0},{-1,0},{1,0},{1,1}},
    {{0,0},{0,1},{-1,1},{0,-1}}},
  {{{0,0},{-1,0},{1,0},{1,-1}},
    {{0,0},{0,-1},{0,1},{1,1}},
    {{0,0},{1,0},{-1,0},{-1,1}},
    {{0,0},{-1,-1},{0,-1},{0,1}}},
  {{{0,0},{0,-1},{1,-1},{1,0}},
    {{0,0},{0,-1},{1,-1},{1,0}},
    {{0,0},{0,-1},{1,-1},{1,0}},
    {{0,0},{0,-1},{1,-1},{1,0}}},
  {{{0,0},{-1,0},{0,-1},{1,-1}},
    {{0,0},{0,-1},{1,0},{1,1}},
    {{0,0},{1,0},{0,1},{-1,1}},
    {{0,0},{0,1},{-1,0},{-1,-1}}},
  {{{0,0},{-1,0},{1,0},{0,-1}},
    {{0,0},{0,1},{1,0},{0,-1}},
    {{0,0},{-1,0},{1,0},{0,1}},
    {{0,0},{-1,0},{0,1},{0,-1}}},
  {{{0,0},{-1,-1},{0,-1},{1,0}},
    {{0,0},{1,-1},{1,0},{0,1}},
    {{0,0},{-1,0},{0,1},{1,1}},
    {{0,0},{0,-1},{-1,0},{-1,1}}}};

float gridW = 400;
float gridH = 800;
float bSize = 40;
float topX;
float topY;
shape current;
int rowsClear = 0;
int speedCntr = 0;
shape onHold;
ArrayList<shape> shapeArr = new ArrayList<shape>();
boolean gameOver  = false;
boolean paused = false;
boolean wasPaused = false;

void setup() {
  background(blk);
  size(900,900);
  frameRate(60);
  topX = width/2 - (gridW/2);
  topY = height/2 - (gridH/2);
  drawGrid();
  drawHold();
  setArrList();
  drawList();
  current = new shape(rand(7));
  current.fillGrid();
  current.drw();
}

void draw() {
  if(paused) {
    wasPaused = true;
    background(blk);
    fill(color(255,0,0));
    textSize(50);
    text("GAME PAUSED", 300, 400);
  }
  else {
    frameCntr++;
    if(wasPaused && !paused) {
      unPauseGame();
      wasPaused = false;
    }
    if(frameCntr >= toDrop) {
      frameCntr = 0;
      current.down();
    }
    if(current.fails() >= 1) {
      checkRows();
      redrawGrid();
      current = shapeArr.get(0);
      shapeArr.remove(0);
      current.setCurr();
      shapeArr.add(new shape(rand(7)));
      drawList();
      if(!current.checkGrid()) {
        frameRate(0);
        background(blk);
        gameOver = true;
        textSize(50);
        fill(color(255,0,0));
        text("YOU DIED", 300, 400);
        text("Rows cleared:: " + rowsClear, 200, 500);
      }
      else {
        current.fillGrid();
        current.drw();
      }
    }
  }
}
int rand(int n) {
  int r = round(1000 * random(0,1));
  return r%n;
}
void setArrList() {
  for(int i = 0; i < 5; i++) {
    shapeArr.add(new shape(rand(7)));
  }
}
void drawList() {
  stroke(blk);
  fill(bkgd);
  rect(topX + 402, topY, 200, 650);
  for(int i = 0; i < shapeArr.size(); i++) {
    shapeArr.get(i).drwArr(i);
  }
}
void drawHold() {
  stroke(blk);
  fill(bkgd);
  square(topX - 202, topY, 200);
  if(onHold != null) {
    onHold.drw();
  }
}
void redrawGrid() {
  for(int i = 0; i < 20; i++) {
    for(int j = 0; j < 10; j++) {
      if(gridData[j][i] == 0) {
        clearB(j * bSize + topX, i * bSize + topY);
      }
      else {
        drawB(j * bSize + topX, i * bSize + topY, colArr[gridData[j][i] - 1]);
      }
    }
  }
}
void checkRows() {
  boolean compEmpty = false;
  int rowState = 0;
  int currRow = 19;
  while(compEmpty == false && currRow >= 0) {
    rowState = 0;
    for(int i = 0; i < 10; i++) {
      if(rowState == 0) {
        if(gridData[i][currRow] == 0) {
          rowState = -1;
        }
        else {
          rowState = 1;
        }
      }
      else if(rowState > 0 && gridData[i][currRow] == 0) {
        i = 10;
        rowState = 0;
      }
      else if(rowState < 0 && gridData[i][currRow] != 0) {
        i = 10;
        rowState = 0;
      }
    }
    if(rowState == 0) {
      currRow--;
    }
    else if(rowState < 0) {
      compEmpty = true;
    }
    else if(rowState > 0) {
      recDelRow(currRow);
    }
  }
}
void recDelRow(int currRow) {
  rowsClear++;
  speedCntr++;
  if(speedCntr >= 3) {
    speedCntr = 0;
    if(toDrop > 15) {
      toDrop -= 2;
    }
  }
  boolean fullEmpty = false;
  while(fullEmpty == false && currRow > 0) {
    fullEmpty = true;
    for(int i = 0; i < 10; i++) {
      gridData[i][currRow] = gridData[i][currRow - 1];
      if(gridData[i][currRow] != 0) {
        fullEmpty = false;
      }
    }
    currRow--;
  }
  surface.setTitle("Rows Cleared:: " + rowsClear);
}
void drawGrid() {
  fill(bkgd);
  rect(topX, topY, gridW, gridH);
  for(int i = 0; i <= 10; i++) {
    stroke(grid);
    line(topX + i*40, topY, topX + i*40, topY + 800);
  }
  for(int j = 0; j <= 20; j++) {
    stroke(grid);
    line(topX, topY + j*40, topX + 400, topY + j*40);
  }
}
void clearB(float x, float y) {
  stroke(grid);
  fill(bkgd);
  square(x,y,bSize);
}
void drawB(float x, float y, color c) {
  stroke(grid);
  fill(blk);
  square(x,y,bSize);
  stroke(blk);
  fill(c);
  square(x+4,y+4,bSize - 8);
}

class shape {
  int rot = 0; // 0 to 3, reset to 0 at >3
  int iD = 0;
  int rotX = 4;
  int rotY = 1;
  color cc = color(255);
  int[][] xy = new int[4][2];
  int fails = 0;
  shape(int id) {
    iD = id;
    for(int i = 0; i < 4; i++) {
      xy[i][0] = rotX + pos[iD][rot][i][0];
      xy[i][1] = rotY + pos[iD][rot][i][1];
    }
    cc = colArr[id];
  }
  void setHold() {
    rotX = -3;
    rotY = 2;
    rot = 0;
    for(int i = 0; i < 4; i++) {
      xy[i][0] = rotX + pos[iD][rot][i][0];
      xy[i][1] = rotY + pos[iD][rot][i][1];
    }
  }
  void setCurr() {
    rotX = 4;
    rotY = 1;
    rot = 0;
    for(int i = 0; i < 4; i++) {
      xy[i][0] = rotX + pos[iD][rot][i][0];
      xy[i][1] = rotY + pos[iD][rot][i][1];
    }
  }
  void erase() {
    for(int i = 0; i < 4; i++) {
      clearB(xy[i][0] * bSize + topX, xy[i][1] * bSize + topY);
    }
  }
  void drw() {
    for(int i = 0; i < 4; i++) {
      drawB(xy[i][0] * bSize + topX, xy[i][1] * bSize + topY, cc);
    }
  }
  void drwArr(int n) {
    rotX = 12;
    rotY = 2 + (n * 3);
    for(int i = 0; i < 4; i++) {
      xy[i][0] = rotX + pos[iD][rot][i][0];
      xy[i][1] = rotY + pos[iD][rot][i][1];
      drawB(xy[i][0] * bSize + topX, xy[i][1] * bSize + topY, cc);
    }
  }
  void down() {
    this.erase();
    this.clearGrid();
    rotY++;
    for(int i = 0; i < 4; i++) {
      xy[i][1]++;
    }
    if(!this.checkGrid()) {
      rotY--;
      fails++;
      for(int i = 0; i < 4; i++) {
        xy[i][1]--;
      }
    }
    else { fails = 0;}
    this.fillGrid();
    this.drw();
  }
  void left() {
    this.erase();
    this.clearGrid();
    rotX--;
    for(int i = 0; i < 4; i++) {
      xy[i][0]--;
    }
    if(!this.checkGrid()) {
      rotX++;
      for(int i = 0; i < 4; i++) {
        xy[i][0]++;
      }
    }
    else {frameCntr = 0;}
    this.fillGrid();
    this.drw();
  }
  void right() {
    this.erase();
    this.clearGrid();
    rotX++;
    for(int i = 0; i < 4; i++) {
      xy[i][0]++;
    }
    if(!this.checkGrid()) {
      rotX--;
      for(int i = 0; i < 4; i++) {
        xy[i][0]--;
      }
    }
    else {frameCntr = 0;}
    this.fillGrid();
    this.drw();
  }
  void rotF() {
    this.erase();
    this.clearGrid();
    rot++;
    if(rot > 3) {rot = 0;}
    for(int i = 0; i < 4; i++) {
      xy[i][0] = rotX + pos[iD][rot][i][0];
      xy[i][1] = rotY + pos[iD][rot][i][1];
    }
    if(!this.checkGrid()) {
      rot--;
      if(rot < 0) {rot = 3;}
      for(int i = 0; i < 4; i++) {
        xy[i][0] = rotX + pos[iD][rot][i][0];
        xy[i][1] = rotY + pos[iD][rot][i][1];
      }
    }
    else {frameCntr = 0;}
    this.fillGrid();
    this.drw();
  }
  void rotB() {
    this.erase();
    this.clearGrid();    
    rot--;
    if(rot < 0) {rot = 3;}
    for(int i = 0; i < 4; i++) {
      xy[i][0] = rotX + pos[iD][rot][i][0];
      xy[i][1] = rotY + pos[iD][rot][i][1];
    }
    if(!this.checkGrid()) {
      rot++;
      if(rot > 3) {rot = 0;}
      for(int i = 0; i < 4; i++) {
        xy[i][0] = rotX + pos[iD][rot][i][0];
        xy[i][1] = rotY + pos[iD][rot][i][1];
      }
    }
    else {frameCntr = 0;}
    this.fillGrid();
    this.drw();
  }
  void clearGrid() {
    for(int i = 0; i < 4; i++) {
      gridData[xy[i][0]][xy[i][1]] = 0;
    }
  }
  void fillGrid() {
    for(int i = 0; i < 4; i++) {
      gridData[xy[i][0]][xy[i][1]] = iD + 1;
    }
  }
  boolean checkGrid() {
    for(int i = 0; i < 4; i++) {
      if(xy[i][0] < 0 || xy[i][0] > 9 || xy[i][1] < 0 || xy[i][1] > 19) {
        return false;
      }
      if(gridData[xy[i][0]][xy[i][1]] != 0) {return false;}
    }
    return true;
  }
  int fails() {return fails;}
}
void keyPressed() {
  if(!gameOver && !paused) {
    if(keyCode == LEFT) {current.left();}
    else if(keyCode == RIGHT) {current.right();}
    else if(keyCode == DOWN) {frameCntr = 0;current.down();}
    else if(keyCode == UP || key == 'x') {current.rotF();}
    else if(keyCode == SHIFT || key == 'c') {
      current.clearGrid();
      current.erase();
      if(onHold == null) {
        onHold = current;
        onHold.setHold();
        current = shapeArr.get(0);
        shapeArr.remove(0);
        current.setCurr();
        current.drw();
        shapeArr.add(new shape(rand(7)));
        drawList();
      }
      else {
        shape temp = onHold;
        onHold = current;
        onHold.setHold();
        current = temp;
        current.setCurr();
        current.drw();
        temp = null;
      }
      drawHold();
    }
    else if(keyCode == CONTROL || key == 'z') {current.rotB();}
    else if(key == 'p') {
      paused = true;
    }
    else if(key == ' ') {while(current.fails() < 1) {current.down();}}
  }
  else if(paused) {
    if(key == 'p') {
      paused = false;
    }
  }
}
void unPauseGame() {
    background(blk);
    drawGrid();
    redrawGrid();
    drawHold();
    drawList();
    current.drw();
}
