import controlP5.*;
import hype.*;

float MAX_SCREEN_SCALE = 0.245; // % - (0.2456 == macbook 1:1)
float SCREEN_SCALE = 0.245; 

// these will get overwritten when settings load
float PRINT_W_INCHES = 5;
float PRINT_H_INCHES = 5;
int PRINT_RESOLUTION = 600;

boolean EDIT_MODE = false;

RenderQueue renderQ;

int numLayers;
Layer[] layers;

boolean loadImagePositions = false;

int canvasW = int(PRINT_W_INCHES * PRINT_RESOLUTION * SCREEN_SCALE);
int canvasH = int(PRINT_H_INCHES * PRINT_RESOLUTION * SCREEN_SCALE);

int canvasX = 0;
int canvasY = 0;

boolean TRANSPARENT_BG = true;
String SETTINGS_PATH = "config/settings.json";
int resolutionMultiplier = 1;

String configPath = "config/config.json";

color bgColor = color(50);

ImageSaver imgSaver = new ImageSaver();
Editor editor;
Document document = new Document();

Menu menu = new Menu();
boolean showMenu = false;

HRect canvasBG;
HText canvasDimensions;

void settings() {
	// -- use size() instead of fullScreen() to open in draggable window:
	fullScreen();
	// size(displayWidth, displayHeight - 45);
	
	pixelDensity(displayDensity()); // this has to be in settings!
}

void setup(){
	editor = new Editor(this, document);
	
	smooth();
	noLoop();
	
	H.init(this).background(bgColor);
	
	canvasBG = new HRect(canvasW, canvasH);
	canvasDimensions = new HText("", 10);
	canvasDimensions.fill(128);

	H.add(canvasBG);
	H.add(canvasDimensions);
	
	// load the default config
	loadSettings(SETTINGS_PATH);
	loadConfigFile(configPath, ""); 
}

void updateCanvas() {
	PRINT_RESOLUTION *= resolutionMultiplier;
	
	calculateScreenScale();
	canvasBG.size(canvasW, canvasH)
		.loc(canvasX, canvasY);
	
	canvasDimensions.loc(canvasX, canvasY - 12);
	canvasDimensions.text(PRINT_W_INCHES + " × " + PRINT_H_INCHES);
	
	if(layers != null) {
		for(Layer l : layers){
			l.canvasCenter = new PVector(PRINT_W_INCHES/2 * PRINT_RESOLUTION, PRINT_H_INCHES/2 * PRINT_RESOLUTION);
		}
	}
	
	redraw();
}

void draw(){
	if(EDIT_MODE) {
		editor.draw();
	} else {
		H.drawStage();
		for(Layer l : layers){
			if(l != null){
				l.removeAllChildren();
			}
		}
		
		if(imgSaver.isBusy()) drawSaveIndicator();
		imgSaver.update();
		
		if(showMenu){
			menu.draw();
		}
	}
	
}

void drawSaveIndicator() {
	pushMatrix();
		fill(color(200, 0, 0));
		noStroke();
		rect(0,0,width, 4);
	popMatrix();
}

void calculateScreenScale() {
	float maxW = width - 100;
	float maxH = height - 100;
	
	float printW = PRINT_W_INCHES * PRINT_RESOLUTION;
	float printH = PRINT_H_INCHES * PRINT_RESOLUTION;
	SCREEN_SCALE = maxW / printW;
	
	if(printH * SCREEN_SCALE > maxH){
		SCREEN_SCALE = maxH / printH;
	}
	
	if(SCREEN_SCALE > MAX_SCREEN_SCALE){
		SCREEN_SCALE = MAX_SCREEN_SCALE;
	}
	
	canvasW = int(PRINT_W_INCHES * PRINT_RESOLUTION * SCREEN_SCALE);
	canvasH = int(PRINT_H_INCHES * PRINT_RESOLUTION * SCREEN_SCALE);
	
	canvasX = (width - canvasW) /2;
	canvasY = (height - canvasH) /2;
	
	Frame canvasFrame = new Frame(canvasX, canvasY, canvasW, canvasH);
	
	imgSaver.setImageResolution(int(printW / pixelDensity), int(printH / pixelDensity));
	imgSaver.setCanvasFrame(canvasFrame);
	
	println("screen Scale: " + SCREEN_SCALE);
}

void setupLayerMasks() {
	for(int i=0; i < layers.length; i++){
		if(layers[i].shouldOverlapLayer){
			int lto = layers[i].layerToOverlap;
			layers[lto].setUpLayerMask(i);
			layers[i].constrainToLayerMask(layers[lto].layerMask);
		}
	}
}

void createLayersWithData(JSONArray data, Boolean loadPositions) {
	int num = data.size();
	
	createLayers(num);
	for(int i=0; i < num; i++){
		println("loadingLayer: "+i);
		layers[i].loadSettings(data.getJSONObject(i));
		
		if(loadPositions){
			layers[i].loadImageData(data.getJSONObject(i), resolutionMultiplier);
			updateLayer(layers[i], false);
		}
		layers[i].init();
	}
	setupLayerMasks();
	redraw();
	resolutionMultiplier = 1;
}

void createLayers(int num) {
	layers = new Layer[num];

	for(int i=0; i < num; i++){
		layers[i] = new Layer();
		H.add(layers[i].canvas).loc( canvasX, canvasY);
	}
	
	editor.updateLayerControls();
}

void updateLayer(Layer layer, boolean randomize) {
	if(randomize) { layer.randomize(); }
	layer.recordImagePositions();
	if(layer.useLayerMask){
		layers[layer.trackingLayer].maskIsBlank = false;
	}
}


// ### SELECT & LOAD CONFIG ###
void selectConfigFile() {
	selectInput("Load config file", "onConfigSelected", dataFile("config"));
}

void reloadCurrentData() {
	loadConfigFile(configPath, "");
}

void onConfigSelected(File config) {
	shiftIsDown = false;
	if(config == null) return;
	
	String filePath = config.getAbsolutePath();
	String fileName = config.getName();
	String relativePath = new File(sketchPath("")).toURI().relativize(new File(filePath).toURI()).getPath();
	
	// remove extension from filename
	fileName = fileName.substring(0, fileName.length() - 5);
	
	if(filePath.toLowerCase().endsWith(".json")){
		loadConfigFile(relativePath, fileName);
		configPath = relativePath;
		updateSettingsFile();
	}
}

void removeLayers() {
	if(layers == null) return;
	for(Layer l : layers){
		H.remove(l.canvas);
	}
}


void parseConfigObject(JSONObject obj) {
	if(!obj.isNull("printWidthInches")){
		PRINT_W_INCHES = obj.getFloat("printWidthInches");
	}
	
	if(!obj.isNull("printHeightInches")) {
		PRINT_H_INCHES = obj.getFloat("printHeightInches");
	}
	
	if(!obj.isNull("printResolution")) {
		PRINT_RESOLUTION = obj.getInt("printResolution");
	}
}

void clearCanvas() {
	for(Layer l : layers) {
		l.removeAllChildren();
		l.clearImagePositions();
		
		if(l.useLayerMask){
			l.clearLayerMask();
			layers[l.trackingLayer].maskIsBlank = true;
		}
		
		// the only way I get the layer canvas to clear is to remove it and
		// create a new one. Not sure why fill() or background() don't work
		H.remove(l.canvas);
		l.canvas = new HCanvas().autoClear(false); 
		H.add(l.canvas).loc( canvasX, canvasY);
	}
	redraw();
}

void loadConfigFile(String filePath, String fileName) {
	removeLayers();

	JSONObject obj = null;
	JSONArray layerData = null;
	
	try {
		obj = loadJSONObject(filePath);
	} catch(Exception e) {
		println("Error: loaded data is not a JSON object");
	}
	
	if(obj != null) {
		parseConfigObject(obj);
		layerData = obj.getJSONArray("layers");
	} else {
		layerData = loadJSONArray(filePath);
	}
	
	updateCanvas();
	
	numLayers = layerData.size();
	createLayersWithData(layerData, loadImagePositions);
}

void updateSettingsFile() {
	println("Update settings: ");
	println(configPath);
	JSONObject json = new JSONObject();
	json.setString("configPath", configPath);
	saveJSONObject(json, "data/" + SETTINGS_PATH);
}

void loadSettings(String filePath) {

	JSONObject settings = loadJSONObject(filePath);
	if(!settings.isNull("configPath")){
		String path = settings.getString("configPath");
		
		// paths saved in settings should be relative to the sketch folder
		// make sure the listed config file exists
		File f = new File(sketchPath(path));
		if (f.exists()) {
			configPath = path;
		} else {
			println("! ERROR: config file doesn't exist. Using default.");
		}
	}
}



// ### KEYBOARD CONTROL ###
boolean shiftIsDown = false;
void keyReleased() {
	if(keyCode == SHIFT){
		shiftIsDown = false;
	} 
	
	redraw();
}

void keyPressed(){
	if(keyCode == SHIFT){
		shiftIsDown = true;
	}

	if(keyCode >= 49 && keyCode <=57){ // Number keys 1-9
		int layerNum = keyCode - 49;
		if(layerNum < layers.length){
			boolean randomize = !shiftIsDown;
			layers[layerNum].restoreChildren();
			updateLayer(layers[layerNum], randomize);
			redraw();
		}
	} else {
		String filename = getFileName();
		switch(key) {
			case 's':
				imgSaver.beginSave(filename, layers, ImageSize.PREVIEW);
			break;
			case 'S' :
				imgSaver.beginSave(filename, layers, ImageSize.FULL);
			break;
			case 'l':
				loadImagePositions = false;
				selectConfigFile();
			break;
			case 'L' :
				loadImagePositions = true;
				selectConfigFile();
			break;
			case 'r' :
				reloadCurrentData();
			break;
			case 'R' :
				beginRender();
			break;
			case 'c' :
				imgSaver.saveImageData(filename + "-config", false);
			break;
			case 'd' :
				// load a file with doubled resolution
				loadImagePositions = true;
				resolutionMultiplier = 2;
				selectConfigFile();
			break;
			case 'x' :
				clearCanvas();
			break;
			case 'e' :
				EDIT_MODE = !EDIT_MODE;
				if(EDIT_MODE){
					editor.show();
					loop();
				} else {
					editor.hide();
					updateCanvas();
					clearCanvas();
					noLoop();
				}
			break;
			
			case 'm' :
				showMenu = !showMenu;
				redraw();
			break;
		}
	}	
}


void beginRender() {
	imgSaver.state = SaveState.RENDER_BEGAN;
	loop();
}

void runRenderQueue() {
	loadImagePositions = true;
	renderQ = new RenderQueue();
	renderQ.load();
	
	while(renderQ.isActive){
		loadConfigFile(renderQ.currentFilePath, renderQ.currentFilename);
		delay(500);
		imgSaver.saveLargeFile(renderQ.currentFilename, layers);
		delay(500);
		renderQ.next();
	}
	
	imgSaver.state = SaveState.COMPLETE;
}

String getFileName() {
	String d  = str( day()    );  // Values from 1 - 31
	String mo = str( month()  );  // Values from 1 - 12
	String y  = str( year()   );  // 2003, 2004, 2005, etc.
	String s  = str( second() );  // Values from 0 - 59
 	String min= str( minute() );  // Values from 0 - 59
 	String h  = str( hour()   );  // Values from 0 - 23

 	String date = y + "-" + mo + "-" + d + " " + h + "-" + min + "-" + s;
 	String n = date + " " + PRINT_W_INCHES + "x" + PRINT_H_INCHES + "@" + PRINT_RESOLUTION + "ppi";
 	return n;
}
