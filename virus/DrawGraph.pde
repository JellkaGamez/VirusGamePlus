void drawGraph(int[] indices, int[] labels, color[] colors, String[] names, float x, float y, float H, boolean SHOW_TIMESPAN){
  int LEN = indices.length;
  pushMatrix();
  translate(x,y);
  textFont(font,24);
  float T_W = 6.3; // width per tick
  float H_C = -H/396; // height per cell
  int MAX_WINDOW = 100;
  int window = min(history.size(),MAX_WINDOW);
  int start_i = history.size()-window;
  if(!SHOW_TIMESPAN){
    int county = 6;
    for(int i = 0; i < window; i++){
      int[] datum = history.get(start_i+i);
      county = max(county,datum[5]+datum[6]+datum[7]+datum[8]);
    }
    H_C = -H/county;
  }
  int[][] runningTotals = new int[window][LEN+1];
  for(int i = 0; i < window; i++){
    int[] datum = history.get(start_i+i);
    runningTotals[i][0] = 0;
    for(int t = 0; t < LEN; t++){
      runningTotals[i][t+1] = runningTotals[i][t]+datum[indices[t]];
    }
    if(i == 0){
      continue;
    }
    float x1 = (i-1)*T_W;
    float x2 = i*T_W;
    for(int t = 0; t < LEN; t++){
      fill(colors[t]);
      beginShape();
      float y1 = runningTotals[i][t]*H_C;
      float y2 = runningTotals[i][t+1]*H_C;
      float py1 = runningTotals[i-1][t]*H_C;
      float py2 = runningTotals[i-1][t+1]*H_C;
      vertex(x1,py1);
      vertex(x1,py2);
      vertex(x2,y2);
      vertex(x2,y1);
      endShape(CLOSE);
    }
    int j = i+start_i;
    if(j > 1 && j < history.size()-1 && j%10 == 0){
      fill(255,255,255,80);
      rect(x1-2,-H,4,H);
      if(SHOW_TIMESPAN){
        textAlign(CENTER);
        fill(255,255,255,130);
        String s = ""+(int)(j*HISTORY_TICK_TIME/GENE_TICK_TIME);
        text(s,x1,27);
      }
    }
  }
  float[] text_coors = new float[names.length];
  int[] r = runningTotals[window-1];
  for(int n = 0; n < names.length; n++){
    text_coors[n] = (r[labels[n]]+r[labels[n+1]])/2;
    text_coors[n] *= H_C;
    if(n == 0){
      continue;
    }
    float gap = text_coors[n-1]-text_coors[n];
    if(gap < 28){
      float smallBy = 28-gap;
      text_coors[n-1] += smallBy/2;
      text_coors[n] -= smallBy/2;
    }
  }
  fill(255,255,255,255);
  textAlign(LEFT);
  int[] d = history.get(history.size()-1);
  for(int n = 0; n < names.length; n++){
    String val = "";
    for(int k = labels[n]; k < labels[n+1]; k++){
      if(k > labels[n]){
        val += ",";
      }
      if(SHOW_TIMESPAN){
        val += d[indices[k]];
      }else{
        int k2 = labels[n+1]+labels[n]-1-k;
        val += d[indices[k2]];
      }
    }
    text(names[n]+": "+val,(window-1)*T_W+10,text_coors[n]+8);
  }
  String title = SHOW_TIMESPAN ? "Number of cells" : "Number of viruses";
  float tY = 31;
  if(SHOW_TIMESPAN){
    tY = -8;
  }
  fill(255,255,255,255);
  textAlign(LEFT);
  text(title,5,tY);
  
  if(SHOW_TIMESPAN && lastEditTimeStamp >= 1){
    int editChunk = (int)(lastEditTimeStamp/HISTORY_TICK_TIME);
    float x_e = (editChunk-start_i+1)*T_W;
    fill(255,255,255);
    if(x_e > 0){
      rect(x_e-2,-H,4,H);
    }else{
      x_e = 0;
    }
    fill(255,0,100);
    float end = (deathTimeStamp == 0) ? frame_count : deathTimeStamp;
    int endChunk = (int)(end/HISTORY_TICK_TIME);
    float x_n = (endChunk-start_i+1)*T_W;
    if(deathTimeStamp != 0){
      x_n += T_W;
    }
    if(x_e > 0){
      rect(x_e-2,-H-30,4,20);
    }
    rect(x_n-2,-H-30,4,20);
    rect(x_e-2,-H-30,x_n-x_e+4,4);
    float midX = min(240,(x_n+x_e)/2);
    textAlign(CENTER);
    text(framesToTime(end-lastEditTimeStamp).split(" ")[0],midX,-H-40);
    
    if(x_n >= 0 && deathTimeStamp != 0){
      rect(x_n-2,-H,4,H);
    }
  }
  popMatrix();
}