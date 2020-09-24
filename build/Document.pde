class Document {
	
	float widthInches;
	float heightInches;
	int printResolution;
	
	int printWPixels;
	int printHPixels;
	
	int canvasX;
	int canvasY;
	int canvasW;
	int canvasH;
	
	float screenScale;
}

// String getFileName() {
// 	String d  = str( day()    );  // Values from 1 - 31
// 	String mo = str( month()  );  // Values from 1 - 12
// 	String y  = str( year()   );  // 2003, 2004, 2005, etc.
// 	String s  = str( second() );  // Values from 0 - 59
//  	String min= str( minute() );  // Values from 0 - 59
//  	String h  = str( hour()   );  // Values from 0 - 23

//  	String date = y + "-" + mo + "-" + d + " " + h + "-" + min + "-" + s;
//  	String n = date + " " + widthInches + "x" + heightInches + "@" + printResolution + "ppi";
//  	return n;
// }