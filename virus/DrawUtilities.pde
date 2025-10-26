// A lot of these can also be understood by just looking at the name
// but they were complicated enough I thought I should probably
// give a explanation

/**
 * Draws two arrows pointing at each other, with the given width and height.
 *
 * param dw The width of the arrows.
 * param dh The height of the arrows.
 */
void drawGenomeArrows(double dw, double dh){
  float w = (float)dw;
  float h = (float)dh;
  fill(255);
  beginShape();
  vertex(-5,0);
  vertex(-45,-40);
  vertex(-45,40);
  endShape(CLOSE);
  beginShape();
  vertex(w+5,0);
  vertex(w+45,-40);
  vertex(w+45,40);
  endShape(CLOSE);
  noStroke();
  rect(0,-h/2,w,h);
}

/**
 * Draws the genome as a list of codons.
 *
 * param g The genome to be drawn.
 * param dims The coordinates and dimensions of the drawing area.
 */
void drawGenomeAsList(Genome g, double[] dims){
  double x = dims[0];
  double y = dims[1];
  double w = dims[2];
  double h = dims[3];
  int GENOME_LENGTH = g.codons.size();
  double appCodonHeight = h/GENOME_LENGTH;
  double appW = w*0.5-margin;
  textFont(font,30);
  textAlign(CENTER);
  pushMatrix();
  dTranslate(x,y);
  pushMatrix();
  dTranslate(0,appCodonHeight*(g.appRO+0.5));
  if(selectedCell != UGOcell){
    drawGenomeArrows(w,appCodonHeight);
  }
  popMatrix();
  for(int i = 0; i < GENOME_LENGTH; i++){
    double appY = appCodonHeight*i;
    Codon codon = g.codons.get(i);
    for(int p = 0; p < 2; p++){
      double extraX = (w*0.5-margin)*p;
      color fillColor = codon.getColor(p);
      color textColor = codon.getTextColor(p);
      fill(0);
      dRect(extraX+margin,appY+margin,appW,appCodonHeight-margin*2);
      if(codon.hasSubstance()){
        fill(fillColor);
        double trueW = appW*codon.codonHealth;
        double trueX = extraX+margin;
        if(p == 0){
          trueX += appW*(1-codon.codonHealth);
        }
        dRect(trueX,appY+margin,trueW,appCodonHeight-margin*2);
      }
      fill(textColor);
      dText(codon.getText(p),extraX+w*0.25,appY+appCodonHeight/2+11);
      
      if(p == codonToEdit[0] && i == codonToEdit[1]){
        double highlightFac = 0.5+0.5*sin(frameCount*0.5);
        fill(255,255,255,(float)(highlightFac*140));
        dRect(extraX+margin,appY+margin,appW,appCodonHeight-margin*2);
      }
      if(codon.altered[p]){
        fill(0,255,0,255);
        pushMatrix();
        double mx = -20;
        if(p == 1){
          mx = w+20;
        }
        dTranslate(mx,appY+margin+appCodonHeight/2-margin);
        rotate(PI/4);
        rect(-7,-7,14,14);
        popMatrix();
      }
    }
  }
  if(selectedCell == UGOcell){
    fill(255);
    textFont(font,60);
    double avgY = (h+height-y)/2;
    dText("( - )",w*0.25,avgY+11);
    dText("( + )",w*0.75-margin,avgY+11);
  }
  popMatrix();
}

/**
 * Draws the edit table that appears when a codon is selected.
 * The edit table is a table of possible values for the selected codon.
 * The table is drawn at the position given by the dims array.
 * param dims The x, y, width, and height of the edit table.
 */
void drawEditTable(double[] dims){
  double x = dims[0];
  double y = dims[1];
  double w = dims[2];
  double h = dims[3];
  
  double appW = w-margin*2;
  textFont(font,30);
  textAlign(CENTER);
  
  int p = codonToEdit[0];
  int s = codonToEdit[2];
  int e = codonToEdit[3];
  if(p >= 0){
    pushMatrix();
    dTranslate(x,y);
    int choiceCount = CodonInfo.getOptionSize(codonToEdit[0]);
    double appChoiceHeight = h/choiceCount;
    for(int i = 0; i < choiceCount; i++){
      double appY = appChoiceHeight*i;
      color fillColor = intToColor(CodonInfo.getColor(p,i));
      color textColor = intToColor(CodonInfo.getTextColor(p,i));
      fill(fillColor);
      dRect(margin,appY+margin,appW,appChoiceHeight-margin*2);
      fill(textColor);
      dText(CodonInfo.getTextSimple(p, i, s, e),w*0.5,appY+appChoiceHeight/2+11);
    }
    popMatrix();
  }
}

/**
 * Draws the information about the currently selected cell.
 * This information includes the name of the cell, the number of particles inside
 * the cell, the energy of the cell, and the wall health of the cell.
 * If the selected cell is not the UGO cell, the memory of the cell is also drawn.
 * see #drawGenomeAsList(Genome, double[])
 * see #drawEditTable(double[])
 */
void drawCellStats(){
  boolean isUGO = (selectedCell.x == -1);
  fill(80);
  noStroke();
  rect(10,160,530,W_H-170);
  if(!isUGO){
    rect(540,160,200,270);
  }
  fill(255);
  textFont(font,96);
  textAlign(LEFT);
  text(selectedCell.getCellName(),25,255);
  if(!isUGO){
    textFont(font,32);
    text("Inside this cell,",555,200);
    text("there are:",555,232);
    text(count(selectedCell.getParticleCount(-1),"particle"),555,296);
    text("("+count(selectedCell.getParticleCount(0),"food")+")",555,328);
    text("("+count(selectedCell.getParticleCount(1),"waste")+")",555,360);
    text("("+count(selectedCell.getParticleCount(2),"UGO")+")",555,392);
    drawBar(color(255,255,0),selectedCell.energy,"Energy",290);
    drawBar(color(210,50,210),selectedCell.wallHealth,"Wall health",360);
  }
  drawGenomeAsList(selectedCell.genome,genomeListDims);
  drawEditTable(editListDims);
  if(!isUGO){
    textFont(font,32);
    textAlign(LEFT);
    text("Memory: "+getMemory(selectedCell),25,940);
  }
}

/**
 * Draws a graph of the history of the game.
 * The graph has a separate section for each team, and each section
 * shows the number of cells of that team over time.
 * The graph is drawn at the position given by the dims array.
 * param dims The x, y, width, and height of the graph.
 */
void drawHistory(){
  recordHistory(frame_count);
  if(team_produce <= 1){
    int[] indices = {0,1,3};
    int[] labels = {0,1,2,3};
    color[] colors = {WALL_COLOR, TAMPERED_COLOR[0], DEAD_COLOR};
    String[] names = {"H","T","D"};
    int[] indices2 = {7,5};
    int[] labels2 = {0,1,2};
    color[] colors2 = {darken(TAMPERED_COLOR[0],0.5),TAMPERED_COLOR[0]};
    String[] names2 = {"C","B"};
    drawGraph(indices,labels,colors,names,20,613,358,true);
    drawGraph(indices2,labels2,colors2,names2,20,835,185,false);
  }else{
    int[] indices = {0,2,4,1,3};
    int[] labels = {0,1,3,5};
    color[] colors = {WALL_COLOR, TAMPERED_COLOR[1], darken(TAMPERED_COLOR[1],0.5), TAMPERED_COLOR[0], darken(TAMPERED_COLOR[0],0.5)};
    String[] names = {"CH","CB","CA"};
    int[] indices2 = {8,6,7,5};
    int[] labels2 = {0,2,4};
    color[] colors2 = {darken(TAMPERED_COLOR[1],0.5),TAMPERED_COLOR[1], darken(TAMPERED_COLOR[0],0.5), TAMPERED_COLOR[0]};
    String[] names2 = {"VB","VA"};
    drawGraph(indices,labels,colors,names,20,613,358,true);
    drawGraph(indices2,labels2,colors2,names2,20,835,185,false);
  }
  removeHistory();
}