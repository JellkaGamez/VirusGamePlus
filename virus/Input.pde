// Like half of these can be understood by just looking at the name
void detectMouse(){
  if (mousePressed){
    arrowToDraw = null;
    if(!wasMouseDown) {
      if(mouseX < W_H){
        codonToEdit[0] = codonToEdit[1] = -1;
        clickWorldX = appXtoTrueX(mouseX);
        clickWorldY = appYtoTrueY(mouseY);
        canDrag = true;
        if(selectedCell == UGOcell){
          sfx[8].play();
        }
      }else{
        if(selectedCell != null){
          if(codonToEdit[0] >= 0){
            checkETclick();
          }
          checkGLclick();
        }
        if(selectedCell == UGOcell){
          if(mouseY < 160){
            selectedCell = null;
            sfx[5].play();
          }
        }else if(mouseX > W_W-160 && mouseY < 160){
          selectedCell = UGOcell;
          sfx[5].play();
        }
        if(mouseY >= height-70 && mouseY < height-20){
          if(mouseX >= width-120 && mouseX < width-70){
            ITER_SPEED = max(0,ITER_SPEED-1);
            sfx[4].play();
          }else if(mouseX >= width-70 && mouseX < width-20){
            ITER_SPEED = min(100,ITER_SPEED+1);
            sfx[4].play();
          }
        }
        canDrag = false;
      }
      DQclick = false;
    }else if(canDrag){
      double newCX = appXtoTrueX(mouseX);
      double newCY = appYtoTrueY(mouseY);
      if(newCX != clickWorldX || newCY != clickWorldY){
        DQclick = true;
      }
      if(selectedCell == UGOcell){
        stroke(0,0,0);
        arrowToDraw = new double[]{clickWorldX,clickWorldY,newCX,newCY};
      }else{
        camX -= (newCX-clickWorldX);
        camY -= (newCY-clickWorldY);
      }
    }
  }
  if(!mousePressed){
    if(wasMouseDown){
      if(selectedCell == UGOcell && arrowToDraw != null){
        if(euclidLength(arrowToDraw) > MIN_ARROW_LENGTH_TO_PRODUCE){
          produceUGO(arrowToDraw);
        }
      }
      if(!DQclick && canDrag){
        double[] mCoor = {clickWorldX,clickWorldY};
        Cell clickedCell = getCellAt(mCoor,false);
        if(selectedCell != UGOcell){
          selectedCell = null;
        }
        if(clickedCell != null && clickedCell.type == 2){
          selectedCell = clickedCell;
        }
      }
    }
    clickWorldX = -1;
    clickWorldY = -1;
    arrowToDraw = null;
  }
  wasMouseDown = mousePressed;
}

void mouseWheel(MouseEvent event) {
  double ZOOM_F = 1.05;
  double thisZoomF = 1;
  float e = event.getCount();
  if(e == 1){
    thisZoomF = 1/ZOOM_F;
  }else{
    thisZoomF = ZOOM_F;
  }
  double worldX = mouseX/camS+camX;
  double worldY = mouseY/camS+camY;
  camX = (camX-worldX)/thisZoomF+worldX;
  camY = (camY-worldY)/thisZoomF+worldY;
  camS *= thisZoomF;
}

// Edit tools click (I assume)
void checkETclick(){
  double ex = editListDims[0];
  double ey = editListDims[1];
  double ew = editListDims[2];
  double eh = editListDims[3];
  double rMouseX = ((mouseX-W_H)-ex)/ew;
  double rMouseY = (mouseY-ey)/eh;
  if(rMouseX >= 0 && rMouseX < 1 && rMouseY >= 0 && rMouseY < 1){
    int optionCount = CodonInfo.getOptionSize(codonToEdit[0]);
    int choice = (int)(rMouseY*optionCount);
    if(codonToEdit[0] == 1 && choice >= optionCount-2){
      int diff = 1;
      if(rMouseX < 0.5){
        diff = -1;
      }
      if(choice == optionCount-2){
        codonToEdit[2] = loopCodonInfo(codonToEdit[2]+diff);
      }else{
        codonToEdit[3] = loopCodonInfo(codonToEdit[3]+diff);
      }
      sfx[5].play();
    }else{
      Codon thisCodon = selectedCell.genome.codons.get(codonToEdit[1]);
      if(codonToEdit[0] == 1 && choice == 7){
        if(thisCodon.codonInfo[1] != 7 ||
        thisCodon.codonInfo[2] != codonToEdit[2] || thisCodon.codonInfo[3] != codonToEdit[3]){
          thisCodon.setInfo(1,choice);
          thisCodon.setInfo(2,codonToEdit[2]);
          thisCodon.setInfo(3,codonToEdit[3]);
          if(selectedCell != UGOcell){
            lastEditTimeStamp = frame_count;
            selectedCell.tamper(0); // if you tamper with it yourself, it's considered Team 0.
          }
          sfx[6].play();
        }
      }else{
        if(thisCodon.codonInfo[codonToEdit[0]] != choice){
          thisCodon.setInfo(codonToEdit[0],choice);
          if(selectedCell != UGOcell){
            lastEditTimeStamp = frame_count;
            selectedCell.tamper(0); // if you tamper with it yourself, it's considered Team 0.
          }
          sfx[6].play();
        }
      }
    }
  }else{
    codonToEdit[0] = codonToEdit[1] = -1;
  }
}

// Check Genome List click (maybe)
void checkGLclick(){
  double gx = genomeListDims[0];
  double gy = genomeListDims[1];
  double gw = genomeListDims[2];
  double gh = genomeListDims[3];
  double rMouseX = ((mouseX-W_H)-gx)/gw;
  double rMouseY = (mouseY-gy)/gh;
  if(rMouseX >= 0 && rMouseX < 1 && rMouseY >= 0){
    if(rMouseY < 1){
      codonToEdit[0] = (int)(rMouseX*2);
      codonToEdit[1] = (int)(rMouseY*selectedCell.genome.codons.size());
      sfx[5].play();
    }else if(selectedCell == UGOcell){
      if(rMouseX < 0.5){
        String genomeString = UGOcell.genome.getGenomeStringShortened();
        selectedCell = UGOcell = new Cell(-1,-1,2,0,1,genomeString);
      }else{
        String genomeString = UGOcell.genome.getGenomeStringLengthened();
        selectedCell = UGOcell = new Cell(-1,-1,2,0,1,genomeString);
      }
      sfx[6].play();
    }
  }
}