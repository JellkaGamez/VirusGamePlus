/**
 * Loops the given value `x` back and forth within a specific range based on the value of `evenSplit`.
 * If `evenSplit` is `true`, the range is `[-len/2, len/2]`.
 * If `evenSplit` is `false`, the range is `[-0.5, len - 0.5]`.
 * The function returns the final value of `x` after looping.
 *
 * param x The initial value of the loop variable.
 * param len The length of the loop.
 * param evenSplit A flag indicating whether the loop should be split into even intervals.
 * return The final value of `x` after looping.
 */
double loopIt(double x, double len, boolean evenSplit){
  if(evenSplit){
    while(x >= len*0.5){
      x -= len;
    }
    while(x < -len*0.5){
      x += len;
    }
  }else{
    while(x > len-0.5){
      x -= len;
    }
    while(x < -0.5){
      x += len;
    }
  }
  return x;
}

/**
 * Loops the given value `x` by adding `len * 10` and taking the modulo of `len`.
 * This effectively shifts `x` by `len * 10` positions and wraps it back within the range of `0` to `len-1`.
 *
 * param x The initial value of the loop variable.
 * param len The length of the loop.
 * return The final value of `x` after looping.
 */
int loopItInt(int x, int len){
  return (x+len*10)%len;
}

void dRect(double x, double y, double w, double h){
  noStroke();
  rect((float)x, (float)y, (float)w, (float)h);
}
void dText(String s, double x, double y){
  text(s, (float)x, (float)y);
}
void dTranslate(double x, double y){
  translate((float)x, (float)y);
}

/**
 * Draws the UI for the application. This includes the time since the start of the simulation,
 * the time since the last edit, and the counts of each type of cell.
 */
void drawUI(){
  pushMatrix();
  translate(W_H,0);
  fill(0);
  noStroke();
  rect(0,0,W_W-W_H,W_H);
  fill(255);
  textAlign(LEFT);
  textFont(font,36);
  text(framesToTime(frame_count)+" start",20,50);
  text(framesToTime(frame_count-lastEditTimeStamp)+" edit",20,90);
  String[] names = {"Healthy","Tampered","Dead","Viruses in blood", "Viruses in cells"};
  if(selectedCell != null){
    text("H: "+bc(0)+",  T: "+bc(1)+",  D: "+bc(2),330,50);
    for(int i = 3; i < 5; i++){
      String suffix = (i < 3) ? (" / "+START_LIVING_COUNT) : "";
      text(names[i]+": "+bc(i)+suffix,330,50+40*(i-2));
    }
    drawCellStats();
  }else{
    for(int i = 0; i < 5; i++){
      String suffix = (i < 3) ? (" / "+START_LIVING_COUNT) : "";
      text(names[i]+": "+bc(i)+suffix,330,50+40*i);
    }
    drawHistory();
  }
  popMatrix();
  drawUGObutton((selectedCell != UGOcell));
  drawSpeedButtons();
}
