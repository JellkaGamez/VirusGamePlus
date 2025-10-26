// A ton of drawing functions that I
// thought were simple enough and you
// can tell what they do by looking at
// the name
void drawBackground(){
  background(255);
}
void drawArrow(double dx1, double dx2, double dy1, double dy2){
  float x1 = (float)trueXtoAppX(dx1);
  float y1 = (float)trueYtoAppY(dx2);
  float x2 = (float)trueXtoAppX(dy1);
  float y2 = (float)trueYtoAppY(dy2);
  strokeWeight((float)(0.03*camS));
  line(x1,y1,x2,y2);
  float angle = atan2(y2-y1,x2-x1);
  float head_size = (float)(0.2*camS);
  float x3 = x2+head_size*cos(angle+PI*0.8);
  float y3 = y2+head_size*sin(angle+PI*0.8);
  line(x2,y2,x3,y3);
  float x4 = x2+head_size*cos(angle-PI*0.8);
  float y4 = y2+head_size*sin(angle-PI*0.8);
  line(x2,y2,x4,y4);
}
void drawSpeedButtons(){
  fill(128);
  rect(width-120,height-70,48,50);
  rect(width-70,height-70,48,50);
  fill(255);
  textFont(font,50);
  textAlign(CENTER);
  text("<",width-96,height-28);
  text(">",width-46,height-28);
  textFont(font,36);
  textAlign(RIGHT);
  text("Play speed: "+ITER_SPEED+"x",width-20,height-80);
}
void drawBar(color col, double stat, String s, double y){
  fill(150);
  rect(25,(float)y,500,60);
  fill(col);
  rect(25,(float)y,(float)(stat*500),60);
  fill(0);
  textFont(font,48);
  textAlign(LEFT);
  text(s+": "+nf((float)(stat*100),0,1)+"%",35,(float)y+47);
}
void daLine(double[] a, double[] b){
  float x1 = (float)trueXtoAppX(a[0]);
  float y1 = (float)trueYtoAppY(a[1]);
  float x2 = (float)trueXtoAppX(b[0]);
  float y2 = (float)trueYtoAppY(b[1]);
  strokeWeight((float)(0.03*camS));
  line(x1,y1,x2,y2);
}
void drawParticles(){
  for(int z = 0; z < 3; z++){
    ArrayList<Particle> sparticles = particles.get(z);
    for(int i = 0; i < sparticles.size(); i++){
      Particle p = sparticles.get(i);
      p.drawParticle(true);
    }
  }
}
void drawCells(){
  for(int y = 0; y < WORLD_SIZE; y++){
    for(int x = 0; x < WORLD_SIZE; x++){
      cells[y][x].drawCell(trueXtoAppX(x),trueYtoAppY(y),trueStoAppS(1));
    }
  }
}