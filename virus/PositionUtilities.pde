/**
 * Converts a world coordinate x to an application coordinate x.
 * 
 * param x The world coordinate x.
 * return The application coordinate x.
 */
double trueXtoAppX(double x){
  return (x-camX)*camS;
}

/**
 * Converts a world coordinate y to an application coordinate y.
 * 
 * param y The world coordinate y.
 * return The application coordinate y.
 */
double trueYtoAppY(double y){
  return (y-camY)*camS;
}

/**
 * Converts an application coordinate x to a world coordinate x.
 * 
 * param x The application coordinate x.
 * return The world coordinate x.
 */
double appXtoTrueX(double x){
  return x/camS+camX;
}

/**
 * Converts an application coordinate y to a world coordinate y.
 * 
 * param y The application coordinate y.
 * return The world coordinate y.
 */
double appYtoTrueY(double y){
  return y/camS+camY;
}

/**
 * Converts a world scale s to an application scale s.
 * 
 * param s The world scale s.
 * return The application scale s.
 */
double trueStoAppS(double s){
  return s*camS;
}
