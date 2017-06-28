import controlP5.*; //<>//
import processing.svg.PGraphicsSVG;

ControlP5 controlP5;

// 幅と高さ
int cellWidth = 21;
int cellHeight = 20;
int centerPos = cellWidth/2;

int cellW = 250;

int cellMaxWidth = 40;
int cellMaxHeight = 40;

int exportScale = 1;

// 0と1の色
color posColor = color(255, 0, 255);
color negColor = color(50, 50, 100);
ColorPicker posCP;
ColorPicker negCP;

//起動時の勝手な画像生成防止用
boolean checkSetup =false;

//機能用パラメータ
boolean useLoop = false;  //左右のループをありにするか
boolean useReverseH = false;  //縦方向に反転するか
//boolean useReverseW = false;  //横方向に反転するか
//boolean checkLoopH = false;  // 上下でループになっているかチェックするか
boolean checkLoopW = true;  // 左右でループになっているかチェックするか
boolean usePreview = true;  // マウスオーバーでプレビューするか

int sellMode = 1;  // 四角形モードか、六角形モードか
boolean useEditer = false;  //出力先を編集するか

int function_num = 0;
ArrayList<FuncButton> Functions = new ArrayList<FuncButton>();

float triDegree = 60;
Slider triDeg;

int PolygonNum = 6;
Slider plyNum;

RadioButton r1;
RadioButton triButton;

enum MargeMode {
  Non, //何もしない
    Auto, //自動で決定（色が多い方）
    Zero, //ゼロの色優先
    One    //イチの色優先
};
MargeMode outputMode = MargeMode.Auto;

enum TriangleMode {
  Default, //何もしない
    Triangle, //自動で決定（色が多い方）
    Polygon, //ゼロの色優先
};
TriangleMode triMode = TriangleMode.Default;

int[] init_cells   = new int[cellWidth];
int[][] cells      = new int[cellHeight][cellWidth];
int[][] copyCells  = new int[cellHeight][cellWidth];


Rule[] rule;

/////////////////////////////////////////////////////////////////////////////////////////////////////

int[] cur_cells = new int[init_cells.length];
int[] new_cells = new int[init_cells.length];

int cellsize = round ((cellW) / (init_cells.length + 4)) ;

int counter = 0;
int reset_flag = 1;

int init_row_left_pos = 150;//round(80 + cellsize * 3 + 60);
int init_row_top_pos = 50;//cellsize;

int colortop = 240;
int colorleft = 25;
int celHeight = 20;

void setup() {
  size(600, 600);
  background(30);
  init_rules();
  noStroke();

  PFont font = loadFont("FilsonSoft-Bold-36.vlw");
  font = loadFont("AgencyFB-Reg-15.vlw");
  textFont(font);

  //初期セルの初期化
  for (int i=0; i<cellWidth; i++) {
    init_cells[i] = 0;
    if (i == centerPos) {
      init_cells[i] = 1;
    }
  }

  //左上のコーナーのセル
  int posx=100; 
  int posy=100; 
  int text_x = posx - cellsize - 50;
  int row_y = posy - round(cellsize*1.5);
  fill(0);

  //カラーチャート
  //text("Color", text_x, row_y + 400);
  //text(, 25, 400);
  //colorMode(HSB, 100);
  //for (int i = 0; i < 100; i++) {
  //  for (int j = 0; j < 100; j++) {
  //    stroke(i, 100, 100);
  //    point(text_x+i, colortop+ j);
  //  }
  //}

  controlP5 = new ControlP5(this);
  setControllers();
  checkSetup = true;

  //Functions.add(new FuncButton(++function_num, "Loop", 10, height - 40, 50, 18));
}


void draw() {
  //繰り返しの速さを少しだけ遅らせる
  delay(1);


  drawTriangle();

  if (reset_flag == 1) {
    colorMode(RGB, 255);
    drawCells();
    drawTriangle();
    stroke(255, 0, 0);
    strokeWeight(2);
    noFill();
    rect(init_row_left_pos, init_row_top_pos, cellsize * cellWidth, cellsize);
    noStroke();
    fill(200, 230, 230);
    text("Click!", init_row_left_pos, init_row_top_pos -5);
    text("->  Image for EXPORT", init_row_left_pos + cellsize * (cellWidth +1), init_row_top_pos -5);
    strokeWeight(1);
    reset_flag = 0;
  }

  for (FuncButton func : Functions) {

    func.draw();
  }
}

/////////////////////// cells ///////////////////////////////////////////
ControlP5 cp5;

void setControllers() {

  int posX = 40;
  int posY = /*round(cellsize * 2.5)*/ init_row_top_pos + rule.length * cellsize * 3;
  int defX = posX;
  int defY = posY;
  int ContWidth = 50;
  color textcolor = color(180, 210, 240);

  fill(textcolor);
  textSize(15);
  text("-RULES-", posX, init_row_top_pos-20);

  fill(255);
  text("Color 1", posX+100, posY-10);

  posCP = controlP5.addColorPicker("posColor")
    .setPosition(posX + 100, posY)
    .setColorValue(posColor)
    //.setWidth(ContWidth)
    ;

  posY += posCP.getHeight() * 7 + 20;

  text("Color 0", posX+100, posY-10);
  negCP = controlP5.addColorPicker("negColor")
    .setPosition(posX + 100, posY )
    .setColorValue(negColor)
    //.setWidth(ContWidth)
    ;



  posY -= posCP.getHeight() * 7 +20;
  println(posCP.getHeight());

  /*
  controlP5.addColorWheel("posColor", 250, 10, 200 )
   .setPosition(posX + 300, posY)
   .setRGB(color(255, 0, 255))
   //.setSize(100, 100)
   ;
   
   controlP5.addColorWheel("negColor", 250, 10, 200 )
   .setPosition(posX + 600, posY)
   .setRGB(color(128, 0, 255))
   //.setSize(100, 100)
   ;
   */
  //cp5 = new ControlP5( this );
  //cp5.addColorWheel("c" , 250 , 10 , 200 ).setRGB(color(128,0,255));

  posY += 10;

  fill(textcolor);
  textSize(15);
  text("-SETTING-", posX, posY);

  posY += 10;

  controlP5.addToggle("useLoop")
    .setPosition(posX, posY)
    .setSize(ContWidth, 10)
    .setValue(true)
    .setMode(ControlP5.SWITCH)
    .setStringValue("Loop")
    ;

  posY += 30;

  controlP5.addToggle("useReverseH")
    .setPosition(posX, posY)
    .setSize(ContWidth, 10)
    .setValue(true)
    .setMode(ControlP5.SWITCH)
    ;

  posY += 55;

  fill(textcolor);
  textSize(15);
  text("-EXPORT-", posX, posY-10);
  color saveColor = color(50, 215, 215);
  color saveBGCOlor = color(30, 60, 60);

  controlP5.addButton("export_JPG")
    .setValue(0)
    .setPosition(posX, posY)
    .setSize(ContWidth, 20)
    .setColorActive(saveColor)
    .setColorForeground(saveColor)
    .setColorBackground(saveBGCOlor) 
    ;

  posY += 30;

  controlP5.addButton("export_PNG")
    .setValue(0)
    .setPosition(posX, posY)
    .setSize(ContWidth, 20)
    .setColorActive(saveColor)
    .setColorForeground(saveColor)
    .setColorBackground(saveBGCOlor) 
    ;

  posY += 30;
  
    r1 = controlP5.addRadioButton("radioButton")
    .setPosition(posX, posY) 
    .setSize(ContWidth, 10)
    //.setColorForeground(color(120))
    .setColorActive(saveColor)
    .setColorForeground(saveColor)
    .setColorBackground(saveBGCOlor) 
    .setColorLabel(color(255))
    .setItemsPerRow(1)
    .setSpacingColumn(50)
    .addItem("Non", 1)//何もしない
    .addItem("Auto", 2)//自動で決定（色が多い方）
    .addItem("Zero", 3)//0の色優先
    .addItem("One", 4)//1の色優先
    .activate(1)
    .toUpperCase(true)
    ;
  posY += 50;
  
  controlP5.addButton("export_SVG")
    .setValue(0)
    .setPosition(posX, posY)
    .setSize(ContWidth, 20)
    .setColorActive(saveColor)
    .setColorForeground(saveColor)
    .setColorBackground(saveBGCOlor) 
    ;

  posY += 40;

  fill(textcolor);
  textSize(15);
  int triX = posX + 100 + posCP.getWidth() + 20;
  text("-TRIANGLE-", triX, defY -10);

  int triY = defY + 150;
  triY += 10;

  triDeg = controlP5.addSlider("triDegree")
    .setPosition(triX, triY)
    .setSize(ContWidth *2, 10)
    .setRange(5, 175) // values can range from big to small as well
    .setValue(triDegree)
    //.setNumberOfTickMarks(8)
    .setSliderMode(Slider.FLEXIBLE)
    ;

  triY += 30;

  int rangeMin = 3;
  int rangeMax = 12;
  int deg = rangeMax - rangeMin;

  plyNum = controlP5.addSlider("PolygonNum")
    .setPosition(triX, triY)
    .setSize(ContWidth *3, 10)
    .setRange(rangeMin, rangeMax) // values can range from big to small as well
    .setValue(PolygonNum)
    .setNumberOfTickMarks(deg)
    .setSliderMode(Slider.FLEXIBLE)
    .setStringValue("Polygon")
    ;
  controlP5.getController("PolygonNum").getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);


  triButton = controlP5.addRadioButton("triButton")
    .setPosition(posX, posY) 
    .setSize(ContWidth, 10)
    //.setColorForeground(color(120))
    .setColorActive(saveColor)
    .setColorForeground(saveColor)
    .setColorBackground(saveBGCOlor) 
    .setColorLabel(color(255))
    .setItemsPerRow(1)
    .setSpacingColumn(50)
    .addItem("Default", 1)//使わない
    .addItem("Triangle", 2)//三角形
    .addItem("Polygon", 3)//正多角形
    .activate(0)
    .toUpperCase(true)
    ;
}

public void controlEvent(ControlEvent c) {
  // when a value change from a ColorPicker is received, extract the ARGB values
  // from the controller's array value
  if (c.isFrom(posCP)) {
    reset_flag  =1;

    int r = int(c.getArrayValue(0));
    int g = int(c.getArrayValue(1));
    int b = int(c.getArrayValue(2));
    //int a = int(c.getArrayValue(3));
    posColor = color(r, g, b);
    //println("event\talpha:"+a+"\tred:"+r+"\tgreen:"+g+"\tblue:"+b+"\tcol"+col);
  } else if (c.isFrom(negCP)) {

    reset_flag  =1;
    int r = int(c.getArrayValue(0));
    int g = int(c.getArrayValue(1));
    int b = int(c.getArrayValue(2));
    //int a = int(c.getArrayValue(3));
    negColor = color(r, g, b);
    //println("event\talpha:"+a+"\tred:"+r+"\tgreen:"+g+"\tblue:"+b+"\tcol"+col);
  } else if (c.isFrom(r1)) {

    reset_flag  =1;
    print("got an event from "+c.getName()+"\t");
    for (int i=0; i<c.getGroup().getArrayValue().length; i++) {
      print(int(c.getGroup().getArrayValue()[i]));
    }
    println("\t "+c.getValue());

    int val = (int)c.getValue();

    switch(val) {
    case 1:
      outputMode = MargeMode.Non;
      break;
    case 2:
      outputMode = MargeMode.Auto;
      break;
    case 3:
      outputMode = MargeMode.Zero;
      break;
    case 4:
      outputMode = MargeMode.One;
      break;
    }
  } else if (c.isFrom(plyNum)) {
    float deg = 360 / PolygonNum;
    triDegree = deg;
    triDeg.setValue(triDegree);
  } else if (c.isFrom(triButton)) {

    reset_flag  =1;
    /*
    print("got an event from "+c.getName()+"\t");
     for (int i=0; i<c.getGroup().getArrayValue().length; i++) {
     print(int(c.getGroup().getArrayValue()[i]));
     }
     println("\t "+c.getValue());*/

    int val = (int)c.getValue();

    switch(val) {
    case 1:
      triMode = TriangleMode.Default;
      break;
    case 2:
      triMode = TriangleMode.Triangle;
      break;
    case 3:
      triMode = TriangleMode.Polygon;
      break;
    }
  }
}



/////////////////////// cells ///////////////////////////////////////////


void drawCells() {

  //最初の状態が変更されたら、はじめから書き直す
  if (reset_flag ==1) { 
    arrayCopy(init_cells, cur_cells); // initialize
    arrayCopy(init_cells, new_cells); // initialize
    counter = 0;
  }
  // セルの行を描きます
  draw_cell_row (init_cells, init_row_left_pos, init_row_top_pos, false, true); 
  textSize(17);
  draw_rules();
  arrayCopy(init_cells, cells[0]);

  updateCells();


  drawCopyCells();
}


void updateCells() {


  for (int j=1; j<celHeight; j++) {
    counter++;

    int l = cur_cells.length;
    // 次のセルを描く
    for (int i = 0; i < cur_cells.length; i++) {

      int lid = i-1;
      int mid = i;
      int rid = i+1;
      if (useLoop) {
        lid = (l + i-1)%l;
        rid = (i+1)%l;
      } else {
        if (i == 0 || i == cur_cells.length - 1) {
          continue;
        }
      }

      int left   = cur_cells[lid];
      int middle = cur_cells[mid];
      int right  = cur_cells[rid];

      // 新しい状態をセット
      new_cells[i] = apply_rule(left, middle, right);

      //println("(" + j + ", " + i + ") = (" + left + ", " + middle + ", " + right + ") -> " +  new_cells[i]);
    }

    // 新しいセルを現在のセルに転写
    arrayCopy(new_cells, cur_cells); // initialize
    arrayCopy(new_cells, cells[j]);

    draw_cell_row (cur_cells, init_row_left_pos, init_row_top_pos + cellsize *j, true, false) ;
  }
}


void drawCopyCells() {

  int posX = init_row_left_pos + cellsize * (cellWidth + 2);
  int posY = init_row_top_pos;  
  int revPoint = 100;

  if (useReverseH) {
    //boolean kisuu = false;
    revPoint = (cellHeight - 1) / 2;
    //if(cellHeight % 2 == 0){
    //  kisuu = true;
    //}else{
    //  kisuu = false;
    //}
  }

  for (int i = 0; i < cellHeight; i++) {

    if (useReverseH && i > revPoint ) {

      arrayCopy(cells[(cellHeight - 1) - i], copyCells[i]);
    } else {
      arrayCopy(cells[i], copyCells[i]);
    }


    draw_cell_row (copyCells[i], posX, posY + cellsize *i, false, false) ;
  }
}

// これはセルの行を描画する the row is x=top, y=left.
void draw_cell_row(int[] cells, int left, int top, Boolean show_counter, Boolean hilite_mouse_over) {
  if (show_counter) {
    fill(255);
    text(counter, left + cellsize * cellWidth +10, top + cellsize );
  }

  for (int i = 0; i < cells.length; i++) {
    draw_one_cell(left + i*cellsize, top, cells[i], hilite_mouse_over);
  }
}

// 位置ごとに白と黒を塗る
void draw_one_cell(int posx, int posy, int state, Boolean hilite_mouse_over) {
  if (state == 1) {
    fill(posColor);//fill(255,0,0, 50); // white cell if the state is 1
  } else {
    fill(negColor); //fill(255, 255, 0, 50); // black cell if the state is 0
  }

  stroke(0); // Default black frame for each cell
  if (hilite_mouse_over) {
    if (mouseOverCell(posx, posy)) {
      stroke(color(250, 0, 0));
    }
  }
  rect( posx, posy, cellsize, cellsize );
}


int[] copy_row(int[] from, int[] to) {
  int l = to.length;
  for (int i=0; i<l; i++) {
    if (i < from.length) {
      to[i] = from[i];
      //println("length: " + l + ", i: " + i + ", To:" + to.length);
    } else {
      //to[i] =0;
      println("Error: Can not copy array.");
      return to;
    }
  }
  return to;
}

int[] copy_row_fromNum(int[] from, int[] to) {
  int l = from.length;
  int t[] = new int[l];
  for (int i=0; i<l; i++) {
    if (i < to.length) {

      //println("length: " + l + ", i: " + i + ", To:" + to.length);
      to[i] = from[i];
      //print
    } else {
      println("Error: Can not copy array.");
      return t;
    }
  }
  return t;
}

/////////////////////// Triangles ///////////////////////////////////////////

void drawTriangle() {



  float topX = 500;
  float topY = 300;
  float topDegree = triDegree;
  float theta = radians(topDegree / 2);
  float triW_2 = cellsize * sin(theta);
  float triH = cellsize * cos(theta);

  fill(30);
  rect(topX-200, topY, 500, 500);

  noStroke();
  fill(150);
  int[][] triangles = new int[cellHeight][cellHeight * 2 + 1];
  int firstVal = 1;
  int[] cur_tri_cells;
  int[] new_tri_cells;

  triangles[0][0] = (firstVal + 1)%2;
  triangles[0][1] = firstVal;
  triangles[0][2] = (firstVal + 1)%2;
  //triangle(topX, topY, topX -10, topY +10, topX + 10, topY +10);

  int defidx = centerPos;
  int itrNum = (cellWidth +1) / 2;

  for (int j = 1; j < itrNum+1; j++) {


    int startidx = defidx - (j-1);
    int triWidth = j*2 -1;
    if (startidx < 0) {
      break;
    }
    //int triNum = (j-1) * 2 + 1;
    //cur_tri_cells = new int[triNum + 2];
    //new_tri_cells = new int[triNum + 4];

    //new_tri_cells[0] = firstVal;
    //new_tri_cells[triNum + 3] = firstVal;

    //int t[] = copy_row(triangles[j-1], cur_tri_cells);
    //arrayCopy(t, cur_tri_cells);


    //if ( j < 3) {
    //  println("j: " + j + "  cur_tri_cells");
    //  println(cur_tri_cells);
    //}
    float startPosX = - triW_2 * (j - 1);
    float startPosY = triH * (j - 1);
    //println(startPosX, startPosY);


    //    for (int i = 1; i < triNum+1; i++) {
    for (int i = 1; i < triWidth+1; i++) {  

      int cellVal = copyCells[j-1][startidx + i-1];
      if (cellVal == 0) {
        fill(negColor);
      } else {
        fill(posColor);
      }

      /*
      int lid = i -1;
       int mid = i ;
       int rid = i+1 ;
       
       if ( j < 3) {
       println("その１ lid:" + lid + ", mid:"  + mid + ", rid: " + rid);
       }
       
       if (useLoop) {
       lid = (triNum + 2 + lid) % (triNum +2);
       mid = (triNum + 2 + mid) % (triNum +2);
       rid = (triNum + 2 + rid) % (triNum +2);
       } else {
       if (i == 1 || i == cur_cells.length +1 - 1 ) {
       continue;
       }
       }
       
       
       int left   = cur_tri_cells[lid];
       int middle = cur_tri_cells[mid];
       int right  = cur_tri_cells[rid];
       
       if ( j < 3) {
       println("その２　lid:" + lid + ", mid:"  + mid + ", rid: " + rid);
       println("j: " + j + "  Second  cur_tri_cells");
       println(cur_tri_cells);
       }
       
       // 新しい状態をセット
       new_tri_cells[i] = apply_rule(left, middle, right);     
       
       if ( j < 3) {
       println("(" + j + ", " + i + ") = (" + left + ", " + middle + ", " + right + ") -> " +  new_tri_cells[i]);
       }
       
       if (triangles[j-1][i] == 0) {
       fill(negColor);
       } else {
       fill(posColor);
       }
       */

      if (i % 2 == 1) {

        //fill(100, 100, 100);
        float triTop_x = startPosX + triW_2 * (i-1)+ topX;
        float triTop_y = startPosY + topY;
        float triBotL_x = triTop_x - triW_2;
        float triBotL_y = triTop_y + triH;
        float triBotR_x = triTop_x + triW_2;  
        float triBotR_y = triTop_y + triH;       

        triangle(triTop_x, triTop_y, triBotL_x, triBotL_y, triBotR_x, triBotR_y);
      } else if (i % 2 == 0) {

        //fill(200, 200, 200);
        float triBot_x = startPosX + triW_2 * (i-1)+ topX;
        float triBot_y = startPosY + topY + triH;
        float triTopL_x = triBot_x - triW_2;
        float triTopL_y = triBot_y - triH;
        float triTopR_x = triBot_x + triW_2;  
        float triTopR_y = triBot_y - triH;    

        triangle(triBot_x, triBot_y, triTopL_x, triTopL_y, triTopR_x, triTopR_y);
      }
    }
    /*
    if (j < cellHeight) {
     int[] _t = copy_row(new_tri_cells, triangles[j]);
     arrayCopy(_t, triangles[j]);
     }
     */
  }
}



/////////////////////// rules ///////////////////////////////////////////

class Rule {
  String label;
  int state_new = 0;  // 0 is black, 1 is white
  int state_left;
  int state_mid;
  int state_right;

  // 結果を呼ぶ時のインタラクティブディスプレイの場所表示に使われる
  int posx=100; // positions are used for interactive display of the resulting cell state
  // 新しい状態を表示する
  int posy=500; // (posx, posy) is the topleft corner of the cell showing the new state

  // Contructor コンストラクタ
  Rule(String name, int left, int mid, int right, int newstat) {
    label=name;
    state_left=left;
    state_mid=mid;
    state_right=right;
    state_new=newstat;
  }

  void draw() {
    int text_x = posx - cellsize - 50;
    int row_y = posy - round(cellsize*1.5) ;
    fill(255);
    textSize(15);
    text(label, text_x, row_y + 15);
    draw_one_cell(posx-cellsize, row_y, state_left, false);
    draw_one_cell(posx, row_y, state_mid, false);
    draw_one_cell(posx+cellsize, row_y, state_right, false);
    draw_one_cell(posx, posy, state_new, true);
  }
}

//８個のルールがある
// Here we have 8 rules.
void init_rules() {
  rule = new Rule[8];
  rule[0]=new Rule("Rule 01", 1, 1, 1, 0);
  rule[1]=new Rule("Rule 02", 1, 1, 0, 1);
  rule[2]=new Rule("Rule 03", 1, 0, 1, 0);
  rule[3]=new Rule("Rule 04", 1, 0, 0, 1);
  rule[4]=new Rule("Rule 05", 0, 1, 1, 1);
  rule[5]=new Rule("Rule 06", 0, 1, 0, 0);
  rule[6]=new Rule("Rule 07", 0, 0, 1, 1);
  rule[7]=new Rule("Rule 08", 0, 0, 0, 0);
  for (int i = 0; i < rule.length; i++) {
    rule[i].posy =  i * cellsize * 3 + init_row_top_pos + round(cellsize * 0.5);
  }
}

// 前回の状態から新しい状態をセット
// Computes the new state of a cell from its previous state and two adjacent cells
int apply_rule (int a, int b, int c) {
  int result=0;
  for (int i = 0; i < rule.length; i++) {
    if (rule[i].state_left == a && rule[i].state_mid == b && rule[i].state_right == c) {
      result = rule[i].state_new;
    }
  }
  return result;
}

void draw_rules () {
  textSize(15);
  fill(255);
  for (int i = 0; i < rule.length; i++) {
    rule[i].draw();
  }
}


/////////////////////// mouse ///////////////////////////////////////////

// 
// 何もクリックされなければ-1を返す
int mouseOverRule() {
  int hit=-1;
  for (int i = 0; i < rule.length; i++) {
    if (mouseOverCell(rule[i].posx, rule[i].posy)) {
      hit = i;
    }
  }
  return hit;
}

// マウスがセルの中にあった時、最初のセルが設置されているところでクリックしたところのセルの行番号を返す
// 何もなければ-1を返す.ハードコードの位置を使っている
int mouseOverInitCell() {
  int hit=-1;
  int left;
  int top;
  for (int i = 0; i < init_cells.length; i++) {
    if (mouseOverCell(init_row_left_pos + i*cellsize, init_row_top_pos)) {
      hit = i;
    }
  }
  return hit;
}

//セルの上にあるか
Boolean mouseOverCell(int xloc, int yloc) {
  int x=mouseX;
  int y=mouseY;
  return x>xloc && x<xloc+cellsize && y>yloc && y<yloc + cellsize;
}

//カラーチャートの上にあるか
int mouseOverColor() {
  int hit = -1;
  int x = mouseX;
  int y = mouseY;

  if (x>colorleft && x< colorleft+100 && y > colortop && y < colortop +100) {
    int colorn = x - colorleft;
    println(colorn);
    colorMode(HSB, 100);  
    posColor = color(colorn, 100, 100, 50);
    negColor = color((50 + colorn)%100, 100, 100, 50);
    hit = 0;
  }
  return hit;
}


void mousePressed() {

  reset_flag = 1;

  //ルール変更のところのセット
  int hit = mouseOverRule();
  if (hit!=-1) {
    rule[hit].state_new=(rule[hit].state_new + 1) % 2;  // flip the state
    reset_flag =1;
  }

  //最初のセルのセット
  hit = mouseOverInitCell();
  if (hit!=-1) {
    init_cells[hit]=(init_cells[hit] + 1) % 2;  // flip the state
    reset_flag =1;
  }

  //色のセット
  //hit = mouseOverColor();
  if (hit != -1) {
    //posColor = color();
    reset_flag =1;
  }

  /*
  for (FuncButton func : Functions) {
   func.mouseOver();
   switch(func.name) {
   case "Loop":
   useLoopToggle();
   break;
   
   case "ReverseH":
   useReverseHToggle();
   break;
   
   case "ReverseW":
   useReverseWToggle();
   break;
   
   case "LoopW":
   
   break;
   }
   }
   */
}

void keyPressed() {

  if (!checkSetup) {
    checkSetup = true;
  }

  if (key == ENTER) {        
    export_SVG();
  }
}


void export_JPG() {

  if (!checkSetup) {
    return;
  }

  int w = cellWidth * cellsize * exportScale;
  int h = cellHeight * cellsize * exportScale;
  float cell_w = cellsize * exportScale;
  float cell_h = cellsize * exportScale;

  PGraphics pg;

  if (triMode == TriangleMode.Default) {
    pg = createGraphics(w, h);
    pg.beginDraw();
    pg.noStroke();

    /*
  for (int i=0; i<cellWidth; i++) {
     if (init_cells[i] == 0) {
     pg.fill(negColor);
     } else if (init_cells[i] == 1) {
     pg.fill(posColor);
     }    
     pg.rect(cell_w * i, 0, cell_w, cell_h);
     }
     */
    for (int j=0; j<cellHeight; j++) {
      for (int i=0; i<cellWidth; i++) {
        if (copyCells[j][i] == 0) {
          pg.fill(negColor);
        } else if (copyCells[j][i] == 1) {
          pg.fill(posColor);
        }
        pg.rect(cell_w * i, cell_h * j, cell_w, cell_h);
      }
    }

    //pg.ellipse(pg.width/2, pg.height/2, 100, 100);
    pg.endDraw();
    pg.save("CAPattern-" + cellWidth +  "x" + cellHeight + ".jpg");
  } 



  ///三角形出力
  else if (triMode == TriangleMode.Triangle || triMode == TriangleMode.Polygon) {


    float topDegree = triDegree;
    
    int loop = 1;
    if(triMode == TriangleMode.Polygon){
      
      loop = PolygonNum;
      topDegree = 360 /PolygonNum;
    }
    
    float theta = radians(topDegree / 2);
    float triW_2 = cellsize * sin(theta);
    float triH = cellsize * cos(theta);

    int defidx = centerPos;
    int itrNum = (cellWidth +1) / 2;

    float topX = (triW_2 *2* itrNum + 1) /2;
    float topY = 0;
    pg = createGraphics((int)(triW_2 * 2 * (itrNum)), (int)(triH * itrNum));
    
    float axisX = topX;
    float axisY = topY;
    
    float loopdeg = 0;
    if(triMode == TriangleMode.Polygon){
      pg = null;
      int _w = (int)(10 * itrNum * 2) + 100;//(triW_2 * 2 * (itrNum) * 2);
      int _h = (int)(triH * itrNum * 2) + 250;
      topX = _w/2;
      topY = _h/2;
      axisX = topX;
      axisY = topY;
      topX = 0;
      topY = 0;
      pg = createGraphics(_w, _h);
      loopdeg = radians(topDegree);
    }
    

    // pg = createGraphics((int)(100),(int)(100));
    pg.beginDraw();
    pg.noStroke();
    pg.translate(axisX, axisY);
    


    for(int k=0; k < loop; k++){
    
      pg.pushMatrix(); //(0, 0)を原点とする座標軸をスタックに格納
      //pg.translate(axisX, axisY);
    

    for (int j = 1; j < itrNum+1; j++) {


      int startidx = defidx - (j-1);
      int triWidth = j*2 -1;
      if (startidx < 0) {
        break;
      }
      float startPosX = - triW_2 * (j - 1);
      float startPosY = triH * (j - 1);

      for (int i = 1; i < triWidth+1; i++) {  

        int cellVal = copyCells[j-1][startidx + i-1];
        if (cellVal == 0) {
          pg.fill(negColor);
        } else {
          pg.fill(posColor);
        }


        if (i % 2 == 1) {

          //fill(100, 100, 100);
          float triTop_x = startPosX + triW_2 * (i-1)+ topX;
          float triTop_y = startPosY + topY;
          float triBotL_x = triTop_x - triW_2;
          float triBotL_y = triTop_y + triH;
          float triBotR_x = triTop_x + triW_2;  
          float triBotR_y = triTop_y + triH;       

          pg.triangle(triTop_x, triTop_y, triBotL_x, triBotL_y, triBotR_x, triBotR_y);
        } else if (i % 2 == 0) {

          //fill(200, 200, 200);
          float triBot_x = startPosX + triW_2 * (i-1)+ topX;
          float triBot_y = startPosY + topY + triH;
          float triTopL_x = triBot_x - triW_2;
          float triTopL_y = triBot_y - triH;
          float triTopR_x = triBot_x + triW_2;  
          float triTopR_y = triBot_y - triH;    

          pg.triangle(triBot_x, triBot_y, triTopL_x, triTopL_y, triTopR_x, triTopR_y);
        }
      }
    }
      pg.rotate(loopdeg);
  }
  
      pg.endDraw();
    pg.save("CAPatternTri-" + cellWidth +  "x" + cellHeight + ".jpg");
        if(triMode == TriangleMode.Polygon){
          
          pg.save("CAPatternPoly" + triDegree + "-"+ cellWidth +  "x" + cellHeight + ".png");
        }
    
  }
}


void export_PNG() {

  if (!checkSetup) {
    return;
  }
  PGraphics pg;
  int w = cellWidth * cellsize * exportScale;
  int h = cellHeight * cellsize * exportScale;
  float cell_w = cellsize * exportScale;
  float cell_h = cellsize * exportScale;

  if (triMode == TriangleMode.Default) {




    pg = createGraphics(w, h);
    pg.beginDraw();
    pg.noStroke();
    /*
  for (int i=0; i<cellWidth; i++) {
     if (init_cells[i] == 0) {
     pg.fill(negColor);
     } else if (init_cells[i] == 1) {
     pg.fill(posColor);
     }    
     pg.rect(cell_w * i, 0, cell_w, cell_h);
     }*/
    for (int j=0; j<cellHeight; j++) {
      for (int i=0; i<cellWidth; i++) {
        if (copyCells[j][i] == 0) {
          pg.fill(negColor);
        } else if (copyCells[j][i] == 1) {
          pg.fill(posColor);
        }
        pg.rect(cell_w * i, cell_h * j, cell_w, cell_h);
      }
    }

    //pg.ellipse(pg.width/2, pg.height/2, 100, 100);
    pg.endDraw();
    pg.save("CAPattern-" + cellWidth +  "x" + cellHeight + ".png");
  }
  ///三角形出力
  else if (triMode == TriangleMode.Triangle) {


    float topDegree = triDegree;
    float theta = radians(topDegree / 2);
    float triW_2 = cellsize * sin(theta);
    float triH = cellsize * cos(theta);

    int defidx = centerPos;
    int itrNum = (cellWidth +1) / 2;

    float topX = (triW_2 *2* itrNum + 1) /2;
    float topY = 0;
    pg = createGraphics((int)(triW_2 * 2 * (itrNum)), (int)(triH * itrNum));
    // pg = createGraphics((int)(100),(int)(100));
    pg.beginDraw();
    pg.noStroke();

    for (int j = 1; j < itrNum+1; j++) {


      int startidx = defidx - (j-1);
      int triWidth = j*2 -1;
      if (startidx < 0) {
        break;
      }
      float startPosX = - triW_2 * (j - 1);
      float startPosY = triH * (j - 1);

      for (int i = 1; i < triWidth+1; i++) {  

        int cellVal = copyCells[j-1][startidx + i-1];
        if (cellVal == 0) {
          pg.fill(negColor);
        } else {
          pg.fill(posColor);
        }


        if (i % 2 == 1) {

          //fill(100, 100, 100);
          float triTop_x = startPosX + triW_2 * (i-1)+ topX;
          float triTop_y = startPosY + topY;
          float triBotL_x = triTop_x - triW_2;
          float triBotL_y = triTop_y + triH;
          float triBotR_x = triTop_x + triW_2;  
          float triBotR_y = triTop_y + triH;       

          pg.triangle(triTop_x, triTop_y, triBotL_x, triBotL_y, triBotR_x, triBotR_y);
        } else if (i % 2 == 0) {

          //fill(200, 200, 200);
          float triBot_x = startPosX + triW_2 * (i-1)+ topX;
          float triBot_y = startPosY + topY + triH;
          float triTopL_x = triBot_x - triW_2;
          float triTopL_y = triBot_y - triH;
          float triTopR_x = triBot_x + triW_2;  
          float triTopR_y = triBot_y - triH;    

          pg.triangle(triBot_x, triBot_y, triTopL_x, triTopL_y, triTopR_x, triTopR_y);
        }
      }
    }
    pg.endDraw();
    pg.save("CAPatternTri-" + cellWidth +  "x" + cellHeight + ".png");
  }
}





/////////////////////// export_svg ///////////////////////////////////////////

void export_SVG() {

  if (!checkSetup) {
    return;
  }

  int w = cellWidth * cellsize * exportScale;
  int h = cellHeight * cellsize * exportScale;
  float cell_w = cellsize * exportScale;
  float cell_h = cellsize * exportScale;

  String name = "CAPattern-" + cellWidth +  "x" + cellHeight + ".svg";

  boolean count = false;
  int Num0=0, Num1=0;
  int BGVal = -1;

  switch(outputMode) {

  case Non:
    break;

  case Auto:
    count = true;
    break;

  case Zero:
    BGVal = 0;
    break;

  case One:
    BGVal = 1;
    break;
  }

  if (count) {
    for (int j=0; j<cellHeight; j++) {
      for (int i=0; i<cellWidth; i++) {
        if ( copyCells[j][i] == 0 ) {
          Num0++;
        } else if ( copyCells[j][i] == 1 ) {
          Num1++;
        }
      }
    }
    if (Num0 >= Num1) {
      BGVal = 0;
    } else if (Num0 < Num1) {
      BGVal = 1;
    }
  }

  PGraphics pg;

  if (triMode == TriangleMode.Default) {

    pg = createGraphics(w, h, SVG, name);
    pg.beginDraw();
    pg.noStroke();
    /*
  for (int i=0; i<cellWidth; i++) {
     if (init_cells[i] == 0) {
     pg.fill(negColor);
     } else if (init_cells[i] == 1) {
     pg.fill(posColor);
     }    
     pg.rect(cell_w * i, 0, cell_w, cell_h);
     }*/

    if (BGVal != -1) {
      if (BGVal == 0) {
        pg.fill(negColor);
      } else if (BGVal == 1) {
        pg.fill(posColor);
      }
      pg.rect(0, 0, w, h);
    }

    for (int j=0; j<cellHeight; j++) {
      for (int i=0; i<cellWidth; i++) {

        if (copyCells[j][i] == 0) {
          pg.fill(negColor);
        } else if (copyCells[j][i] == 1) {
          pg.fill(posColor);
        }

        if (copyCells[j][i] != BGVal) {
          pg.rect(cell_w * i, cell_h * j, cell_w, cell_h);
        }
      }
    }

    //pg.ellipse(pg.width/2, pg.height/2, 100, 100);
    pg.endDraw();
  } else if (triMode == TriangleMode.Triangle) {


    float topDegree = triDegree;
    float theta = radians(topDegree / 2);
    float triW_2 = cellsize * sin(theta);
    float triH = cellsize * cos(theta);

    int defidx = centerPos;
    int itrNum = (cellWidth +1) / 2;

    float topX = (triW_2 *2* itrNum + 1) /2;
    float topY = 0;
    String _name = "CAPatternTri-" + cellWidth +  "x" + cellHeight + ".svg";

    // pg = createGraphics((int)(triW_2 * 2 * (itrNum)),(int)(triH * itrNum));
    pg = createGraphics(w, h, SVG, _name);
    // pg = createGraphics((int)(100),(int)(100));
    pg.beginDraw();
    pg.noStroke();

    for (int j = 1; j < itrNum+1; j++) {


      int startidx = defidx - (j-1);
      int triWidth = j*2 -1;
      if (startidx < 0) {
        break;
      }
      float startPosX = - triW_2 * (j - 1);
      float startPosY = triH * (j - 1);

      for (int i = 1; i < triWidth+1; i++) {  

        int cellVal = copyCells[j-1][startidx + i-1];
        if (cellVal == 0) {
          pg.fill(negColor);
        } else {
          pg.fill(posColor);
        }


        if (i % 2 == 1) {

          //fill(100, 100, 100);
          float triTop_x = startPosX + triW_2 * (i-1)+ topX;
          float triTop_y = startPosY + topY;
          float triBotL_x = triTop_x - triW_2;
          float triBotL_y = triTop_y + triH;
          float triBotR_x = triTop_x + triW_2;  
          float triBotR_y = triTop_y + triH;       

          pg.triangle(triTop_x, triTop_y, triBotL_x, triBotL_y, triBotR_x, triBotR_y);
        } else if (i % 2 == 0) {

          //fill(200, 200, 200);
          float triBot_x = startPosX + triW_2 * (i-1)+ topX;
          float triBot_y = startPosY + topY + triH;
          float triTopL_x = triBot_x - triW_2;
          float triTopL_y = triBot_y - triH;
          float triTopR_x = triBot_x + triW_2;  
          float triTopR_y = triBot_y - triH;    

          pg.triangle(triBot_x, triBot_y, triTopL_x, triTopL_y, triTopR_x, triTopR_y);
        }
      }
    }
    pg.endDraw();
  }
}