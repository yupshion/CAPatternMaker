class FuncButton{
  
  int id;
  String name;
  int x, y, w, h;
  color baseColor = color(50, 50, 80);
  color textColor = color(250);
  
  FuncButton(int _id, String _n, int _x, int _y, int _w, int _h){
    id = _id;
    name = _n;
    x = _x;
    y = _y;
    w = _w;
    h = _h;    
  }
  
  
  void draw(){
  
    noStroke();
    fill(baseColor);
    rect(x, y, w, h);
    fill(textColor);
    text(name, x + 10, y + 13);
  
  }
  
  
  void setColor(color baseC, color textC){
    baseColor = baseC;
    textColor = textC;
    
  }
  
  int mouseOver(){
    int hit = -1;
    int _X = mouseX;
    int _Y = mouseY;
    if( _X > x && _X < x + w && _Y > y && _Y < y + h){
      
     hit = 0; 
    }
  
    return hit;
  }
  
  
  
  
  
  
}