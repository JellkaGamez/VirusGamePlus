import processing.sound.*;

String[] soundFileNames = {"die.wav","absorb.wav","emit.wav","end.wav","menu1.wav","menu2.wav","menu3.wav","release.wav","plug.wav"};
SoundFile[] sfx;
int WORLD_SIZE = 36;
int W_W = 1728;
int W_H = 972;
Cell[][] cells = new Cell[WORLD_SIZE][WORLD_SIZE];
ArrayList<ArrayList<Particle>> particles = new ArrayList<ArrayList<Particle>>(0);
int foodLimit = 1440;
float BIG_FACTOR = 100;
int ITER_SPEED = 1;
float MOVE_SPEED = 0.6;
double GENE_TICK_TIME = 40.0;
double HISTORY_TICK_TIME = 160.0;
double margin = 4;
int START_LIVING_COUNT = 0;
int[] cellCounts = {0,0,0,0,0,0,0,0,0};
/*
CATEGORIES FOR THE VIRUS SIM CENSUS

0 - Cell - healthy
1 - Cell - tampered by Team 0
2 - Cell - tampered by Team 1
3 - Cell - dead by Team 0, or not by virus
4 - Cell - dead by Team 1
5 - Virus - in blood, Team 0
6 - Virus - in blood, Team 1
7 - Virus - in cells, Team 0
8 - Virus - in cells, Team 1
*/

int frame_count = 0;

double REMOVE_WASTE_SPEED_MULTI = 0.001;
double removeWasteTimer = 1.0;

double GENE_TICK_ENERGY = 0.014;
double WALL_DAMAGE = 0.01;
double CODON_DEGRADE_SPEED = 0.008;
double EPS = 0.00000001;

String starterGenome = "46-11-22-33-11-22-33-45-44-57__-67__";
boolean canDrag = false;
double clickWorldX = -1;
double clickWorldY = -1;
boolean DQclick = false;
int[] codonToEdit = {-1,-1,0,0};
double[] genomeListDims = {70,430,360,450};
double[] editListDims = {550,330,180,450};
double[] arrowToDraw = null;
Cell selectedCell = null;
Cell UGOcell;
int lastEditTimeStamp = 0;
int deathTimeStamp = 0;
color handColor = color(0,128,0);
color TELOMERE_COLOR = color(0,0,0);
color WASTE_COLOR = color(100,65,0);
color HEALTHY_COLOR = color(225,190,225);
color[] TAMPERED_COLOR = {color(205,225,70), color(160,160,255)};
color DEAD_COLOR = color(80,80,80);
color WALL_COLOR = color(170,100,170);
int MAX_CODON_COUNT = 20; // If a cell were to have more codons in its DNA than this number if it were to absorb a cirus particle, it won't absorb it.
int team_produce = 0; // starts as Team 0, but as soon as the first UGO is created, it switches to Team 1.

double SPEED_LOW = 0.01;
double SPEED_HIGH = 0.02;
double MIN_ARROW_LENGTH_TO_PRODUCE = 0.4;

double ZOOM_THRESHOLD = 0;//80;
PFont font;
ArrayList<int[]> history = new ArrayList<int[]>(0);

// Initalization
void setup(){
  sfx = new SoundFile[soundFileNames.length];
  for(int s = 0; s < soundFileNames.length; s++){
    sfx[s] = new SoundFile(this, "audio/"+soundFileNames[s]);
  }
  font = loadFont("Jygquip1-96.vlw");
  for(int j = 0; j < 3; j++){
    ArrayList<Particle> newList = new ArrayList<Particle>(0);
    particles.add(newList);
  }
  for(int y = 0; y < WORLD_SIZE; y++){
    for(int x = 0; x < WORLD_SIZE; x++){
      int t = getTypeFromXY(x,y);
      cells[y][x] = new Cell(x,y,t,0,1,starterGenome);
      if(t == 2){
        START_LIVING_COUNT++;
        cellCounts[0]++;
      }
    }
  }
  size(1728,972);
  noSmooth();
  UGOcell = new Cell(-1,-1,2,0,1,"00-00-00-00-00");
}

/**
 * Returns the type of cell at the given coordinates.
 * The type is determined by the position of the cell in a 3x3 grid.
 * The grid is divided into 9 squares, with the top-left square being type 0, the top-center square being type 1, the top-right square being type 2, and so on.
 * The type of the cell is then determined by its position within the square.
 * If the cell is on the left or right edge of the square, it is type 2.
 * If the cell is on the top or bottom edge of the square, it is type 2.
 * Otherwise, it is type 1.
 * param preX The x-coordinate of the cell.
 * param preY The y-coordinate of the cell.
 * return The type of the cell.
 */
int getTypeFromXY(int preX, int preY){
  int[] weirdo = {0,1,1,2};
  int x = (preX/4)*3;
  x += weirdo[preX%4];
  int y = (preY/4)*3;
  y += weirdo[preY%4];
  int result = 0;
  for(int i = 1; i < WORLD_SIZE; i *= 3){
    if((x/i)%3 == 1 && (y/i)%3 == 1){
      result = 1;
      int xPart = x%i;
      int yPart = y%i;
      boolean left = (xPart == 0);
      boolean right = (xPart == i-1);
      boolean top = (yPart == 0);
      boolean bottom = (yPart == i-1);
      if(left || right || top || bottom){
        result = 2;
      }
    }
  }
  return result;
}

boolean wasMouseDown = false;
double camX = 0;
double camY = 0;
double MIN_CAM_S = ((float)W_H)/WORLD_SIZE;
double camS = MIN_CAM_S;
void draw(){
  for(int i = 0; i < ITER_SPEED; i++){
    iterate();
  }
  detectMouse();
  drawBackground();
  drawCells();
  drawParticles();
  drawExtras();
  drawUI();
}
void drawExtras(){
  boolean valid = false;
  if(arrowToDraw != null){
    if(euclidLength(arrowToDraw) > MIN_ARROW_LENGTH_TO_PRODUCE){
      stroke(0);
      valid = true;
    }else{
      stroke(0,0,0,80);
    }
    drawArrow(arrowToDraw[0],arrowToDraw[1],arrowToDraw[2],arrowToDraw[3]);
  }
  if(selectedCell == UGOcell){
    double newCX = appXtoTrueX(mouseX);
    double newCY = appYtoTrueY(mouseY);
    double[] coor = {newCX, newCY, newCX+1, newCY};
    if(arrowToDraw != null){
      coor = arrowToDraw;
    }
    String genomeString = UGOcell.genome.getGenomeString();
    Particle UGOcursor = new Particle(coor,2,genomeString,-9999,min(1,team_produce));
    UGOcursor.drawParticle(valid);
  }
}

/**
 * Ensure that the number of particles in the simulation is at least foodLimit.
 * 
 * If the number of particles is less than foodLimit, this function will add new particles
 * to the simulation until the number of particles is at least foodLimit.
 * 
 * The new particles are added at random positions in the simulation.
 */
void doParticleCountControl(){
  ArrayList<Particle> foods = particles.get(0);
  while(foods.size() < foodLimit){
    int choiceX = -1;
    int choiceY = -1;
    while(choiceX == -1 || cells[choiceY][choiceX].type >= 1){
      choiceX = (int)random(0,WORLD_SIZE);
      choiceY = (int)random(0,WORLD_SIZE);
    }
    double extraX = random(0.3,0.7);
    double extraY = random(0.3,0.7);
    double x = choiceX+extraX;
    double y = choiceY+extraY;
    double[] coor = {x,y};
    Particle newFood = new Particle(coor,0,frame_count);
    foods.add(newFood);
    newFood.addToCellList();
  }
  
  ArrayList<Particle> wastes = particles.get(1);
  if(wastes.size() > foodLimit){
    removeWasteTimer -= (wastes.size()-foodLimit)*REMOVE_WASTE_SPEED_MULTI;
    if(removeWasteTimer < 0){
      int choiceIndex = -1;
      int iter = 0;
      while(iter < 50 && (choiceIndex == -1 || getCellAt(wastes.get(choiceIndex).coor,true).type == 2)){
        choiceIndex = (int)(Math.random()*wastes.size());
      } // If possible, choose a particle that is NOT in a cell at the moment.
      wastes.get(choiceIndex).removeParticle();
      removeWasteTimer++;
    }
  }
}

double[] getRandomVelo(){
  double sp = Math.random()*(SPEED_HIGH-SPEED_LOW)+SPEED_LOW;
  double ang = random(0,2*PI);
  double vx = sp*Math.cos(ang);
  double vy = sp*Math.sin(ang);
  double[] result = {vx, vy};
  return result;
}


/**
 * Iterate all particles and cells in the simulation.
 * 
 * This function is the main loop of the simulation. It iterates
 * all particles and cells, and records the current state of the
 * simulation.
 */
void iterate(){
  doParticleCountControl();
  for(int z = 0; z < 3; z++){
    ArrayList<Particle> sparticles = particles.get(z);
    for(int i = 0; i < sparticles.size(); i++){
      Particle p = sparticles.get(i);
      p.iterate();
    }
  }
  for(int y = 0; y < WORLD_SIZE; y++){
    for(int x = 0; x < WORLD_SIZE; x++){
      cells[y][x].iterate();
    }
  }
  recordHistory(frame_count);
  frame_count++;
}
/**
 * Returns a color with the given alpha value.
 * 
 * param c the color to modify
 * param a the alpha value to set
 * return the color with the given alpha value
 */
color setAlpha(color c, float a){
  float newR = red(c);
  float newG = green(c);
  float newB = blue(c);
  return color(newR, newG, newB, a);
}

// Codon Info
int loopCodonInfo(int val){
  while(val < -30){
    val += 61;
  }
  while(val > 30){
    val -= 61;
  }
  return val;
}
int codonCharToVal(char c){
  int val = (int)(c) - (int)('A');
  return val-30;
}
String codonValToChar(int i){
  int val = (i+30) + (int)('A');
  return (char)val+"";
}

double euclidLength(double[] coor){
  return Math.sqrt(Math.pow(coor[0]-coor[2],2)+Math.pow(coor[1]-coor[3],2));
}

// Create a UGO
void produceUGO(double[] coor){
  if(getCellAt(coor,false) != null && getCellAt(coor,false).type == 0){
    sfx[7].play();
    int team = min(1,team_produce);
    String genomeString = UGOcell.genome.getGenomeString();
    Particle newUGO = new Particle(coor,2,genomeString,-9999,team);
    particles.get(2).add(newUGO);
    newUGO.addToCellList();
    lastEditTimeStamp = frame_count;
    cellCounts[5+team]++; // one more virus in the bloodstream
    team_produce += 1;
  }
}

void recordHistory(double f){
  double ticks = f/HISTORY_TICK_TIME;
  if(ticks >= history.size()-1){
    int[] datum = new int[cellCounts.length];
    for(int i = 0; i < cellCounts.length; i++){
      datum[i] = cellCounts[i];
    }
    history.add(datum);
  }
}
void removeHistory(){
  history.remove(history.size()-1);
}
String framesToTime(double f){
  double ticks = f/GENE_TICK_TIME;
  String timeStr = nf((float)ticks,0,1);
  if(ticks >= 1000){
    timeStr = (int)(Math.round(ticks))+"";
  }
  return timeStr+"t since";
}
String count(int count, String s){
  if(count == 1){
    return count+" "+s;
  }else{
    return count+" "+s+"s";
  }
}
void twoSizeFont(String str, float s1, float s2, float x, float y){
  String[] parts = str.split(",");
  textAlign(LEFT);
  textFont(font,s1);
  text(parts[0],x,y);
  float x2 = x+textWidth(parts[0]);
  textFont(font,s2);
  text(parts[1],x2,y);
}
int bc(int i){ // basic count
  if(i == 0){
    return cellCounts[0];
  }else{
    return cellCounts[i*2-1]+cellCounts[i*2];
  } 
}

color darken(color c, float fac){
  float newR = red(c)*fac;
  float newG = green(c)*fac;
  float newB = blue(c)*fac;
  return color(newR, newG, newB);
}

void drawUGObutton(boolean drawUGO){
  fill(80);
  noStroke();
  rect(W_W-130,10,120,140);
  fill(255);
  textAlign(CENTER);
  if(drawUGO){
    textFont(font,48);
    text("MAKE",W_W-70,70);
    text("UGO",W_W-70,120);
  }else{
    textFont(font,36);
    text("CANCEL",W_W-70,95);
  }
}

String getMemory(Cell c){
  if(c.memory.length() == 0){
    return "[NOTHING]";
  }else{
    return "\""+c.memory+"\"";
  }
}