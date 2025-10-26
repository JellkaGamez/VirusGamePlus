/**
 * Converts an array of integers to a string
 * param info the array of integers
 * return a string representation of the array
 */
String infoToString(int[] info){
  String result = info[0]+""+info[1];
  if(info[1] == 7){
    result += codonValToChar(info[2])+""+codonValToChar(info[3]);
  }
  return result;
}

/**
 * Converts a string to an array of integers
 * param str the string to convert
 * return an array of integers
 */
int[] stringToInfo(String str){
  int[] info = new int[4];
  for(int i = 0; i < 2; i++){
    info[i] = Integer.parseInt(str.substring(i,i+1));
  }
  if(info[1] == 7){
    for(int i = 2; i < 4; i++){
      char c = str.charAt(i);
      info[i] = codonCharToVal(c);
    }
  }
  return info;
}

