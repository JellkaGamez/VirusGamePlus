/**
 * Transforms a color object by adding transparency.
 * The `trans` parameter specifies the transparency level, where 0 is completely transparent and 1 is completely opaque.
 * The function calculates the alpha (transparency) value by multiplying the transparency value by 255.
 * It then creates a new color object with the same RGB values as the input color, but with the calculated alpha value.
 *
 * param col The original color object.
 * param trans The transparency level.
 * return The color object with added transparency.
 */
color transperize(color col, double trans){
  float alpha = (float)(trans*255);
  return color(red(col),green(col),blue(col),alpha);
}

/**
 * Converts an integer array representing RGB color values to a color object.
 * The `c` parameter is an array containing three integers representing the red, green, and blue color values.
 * The function creates a new color object with the RGB values from the input array.
 *
 * param c An array containing three integers representing the RGB color values.
 * return The color object created from the input array.
 */
color intToColor(int[] c){
  return color(c[0],c[1],c[2]);
}

/**
 * Interpolates between two colors.
 * The function calculates the RGB values of the interpolated color by multiplying the difference between the RGB values of the two input colors by the interpolation parameter `x`.
 * The resulting RGB values are then used to create a new color object.
 *
 * param a The first color object.
 * param b The second color object.
 * param x The interpolation parameter, where 0 results in the first color and 1 results in the second color.
 * return The interpolated color object.
 */
color colorInterp(color a, color b, double x){
  float newR = (float)(red(a)+(red(b)-red(a))*x);
  float newG = (float)(green(a)+(green(b)-green(a))*x);
  float newB = (float)(blue(a)+(blue(b)-blue(a))*x);
  return color(newR, newG, newB);
}