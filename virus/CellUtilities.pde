/**
 * Retrieves the type of a cell at the given coordinates.
 * The function first calculates the integer coordinates `ix` and `iy` based on the input `x` and `y` values.
 * If `allowLoop` is `true`, it loops the coordinates back to the range of `0` to `WORLD_SIZE-1` using modulo arithmetic.
 * If `allowLoop` is `false`, it checks if the calculated coordinates are within the valid range of `0` to `WORLD_SIZE-1`.
 * If the coordinates are out of range, it returns 0.
 * Otherwise, it returns the `type` value of the cell at the calculated coordinates.
 *
 * param x The x-coordinate.
 * param y The y-coordinate.
 * param allowLoop A flag indicating whether to allow looping the coordinates.
 * return The type of the cell at the given coordinates.
 */
int getCellTypeAt(double x, double y, boolean allowLoop){
  int ix = (int)x;
  int iy = (int)y;
  if(allowLoop){
    ix = (ix+WORLD_SIZE)%WORLD_SIZE;
    iy = (iy+WORLD_SIZE)%WORLD_SIZE;
  }else{
    if(ix < 0 || ix >= WORLD_SIZE || iy < 0 || iy >= WORLD_SIZE){
      return 0;
    }
  }
  return cells[iy][ix].type;
}

/**
 * Retrieves the cell object at the given coordinates.
 * The function first calculates the integer coordinates `ix` and `iy` based on the input `x` and `y` values.
 * If `allowLoop` is `true`, it loops the coordinates back to the range of `0` to `WORLD_SIZE-1` using modulo arithmetic.
 * If `allowLoop` is `false`, it checks if the calculated coordinates are within the valid range of `0` to `WORLD_SIZE-1`.
 * If the coordinates are out of range, it returns `null`.
 * Otherwise, it returns the cell object at the calculated coordinates.
 *
 * param x The x-coordinate.
 * param y The y-coordinate.
 * param allowLoop A flag indicating whether to allow looping the coordinates.
 * return The cell object at the given coordinates.
 */
int getCellTypeAt(double[] coor, boolean allowLoop){
  return getCellTypeAt(coor[0],coor[1],allowLoop);
}

/**
 * Retrieves the cell object at the given coordinates.
 * This function is a wrapper for the `getCellAt` function that accepts an array of coordinates.
 * It calls the `getCellAt` function with the first two elements of the input array.
 *
 * param coor An array containing the x and y coordinates.
 * param allowLoop A flag indicating whether to allow looping the coordinates.
 * return The cell object at the given coordinates.
 */
Cell getCellAt(double x, double y, boolean allowLoop){
  int ix = (int)x;
  int iy = (int)y;
  if(allowLoop){
    ix = (ix+WORLD_SIZE)%WORLD_SIZE;
    iy = (iy+WORLD_SIZE)%WORLD_SIZE;
  }else{
    if(ix < 0 || ix >= WORLD_SIZE || iy < 0 || iy >= WORLD_SIZE){
      return null;
    }
  }
  return cells[iy][ix];
}
/**
 * Retrieves the cell object at the given coordinates.
 * This function is a wrapper for the `getCellAt` function that accepts an array of coordinates.
 * It calls the `getCellAt` function with the first two elements of the input array.
 *
 * param coor An array containing the x and y coordinates.
 * param allowLoop A flag indicating whether to allow looping the coordinates.
 * return The cell object at the given coordinates.
 */
Cell getCellAt(double[] coor, boolean allowLoop){
  return getCellAt(coor[0],coor[1],allowLoop);
}

/**
 * Checks if two cells are different based on their coordinates.
 * This function is a wrapper for the `cellTransfer` function that accepts an array of coordinates.
 * It calls the `cellTransfer` function with the first two elements of the input arrays.
 *
 * param coor1 An array containing the x and y coordinates of the first cell.
 * param coor2 An array containing the x and y coordinates of the second cell.
 * return `true` if the cells are different, `false` otherwise.
 */
boolean cellTransfer(double x1, double y1, double x2, double y2){
  int ix1 = (int)Math.floor(x1);
  int iy1 = (int)Math.floor(y1);
  int ix2 = (int)Math.floor(x2);
  int iy2 = (int)Math.floor(y2);
  return (ix1 != ix2 || iy1 != iy2);
}
boolean cellTransfer(double[] coor1, double[] coor2){
  return cellTransfer(coor1[0], coor1[1], coor2[0], coor2[1]);
}