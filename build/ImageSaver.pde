class ImageSaver {

	HCanvas printCanvas;

	String filenameToSave = "";
	ImageSize imageSizeToSave;
	Layer[] layersToSave;
	SaveState state = SaveState.NONE;
	
	Size printSizePx;
	Frame canvasFrame;

	ImageSaver() {
		
	}
	
	void update() {
		switch (state) {
			case BEGAN:
				state = SaveState.SAVING;
			break;
			case RENDER_BEGAN:
				state = SaveState.RENDERING;
			break;
			case SAVING:
				saveImage(filenameToSave, imageSizeToSave);
			break;
			case RENDERING:
				runRenderQueue();
			break;
			case COMPLETE:
				state = SaveState.NONE;
				noLoop();
			break;	
		}
	}
	
	void saveImage(String filename, ImageSize imgSize) {
		saveImageData(filename, true);
		switch (imgSize) {
			case PREVIEW :
				savePreviewImage(filename, layersToSave);
			break;
			case FULL :
				saveLargeFile(filename, layersToSave);
			break;	
		}
		
		state = SaveState.COMPLETE;
	}

	
	boolean isBusy() {
		return state == SaveState.BEGAN || 
		       state == SaveState.SAVING || 
		       state == SaveState.RENDER_BEGAN || 
		       state == SaveState.RENDERING;
	}
	
	void setCanvasFrame(Frame frame) {
		canvasFrame = frame;
	}
	
	void setImageResolution(int w, int h) {
		printSizePx = new Size(w, h);
	}
	
	void beginSave(String filename, Layer[] layers, ImageSize imgSize) {
		filenameToSave = filename;
		imageSizeToSave = imgSize;
		layersToSave = layers;
		state = SaveState.BEGAN;
		loop();
	}
	
	void savePreviewImage(String filename, Layer[] layers) {
		println("Saving preview file... ");
		PGraphics tmp = createGraphics(canvasFrame.width, canvasFrame.height);
		beginRecord(tmp);
		tmp.background(255);
		for(Layer l : layers) {
			l.removeAllChildren();
			l.canvas.loc(0,0);
			l.canvas.paintAll(tmp, false, 1);
			// l.restoreChildren();
			l.canvas.loc(canvasFrame.x, canvasFrame.y);
		}
		endRecord();
		println("writing image file...");
		tmp.save("output/" + filename + "-sm.png");
		println("");
		println("DONE!");
		println("Nice job. Here's your file:");
		println(filename);
		println("");
	}
	
	void saveLargeFile(String filename, Layer[] layers) {
		println("Saving large file...");
		PGraphics tmp = createGraphics(printSizePx.width, printSizePx.height);
		beginRecord(tmp);
		if(!TRANSPARENT_BG) tmp.background(255);

		printCanvas = H.add(new HCanvas(printSizePx.width, printSizePx.height)).autoClear(false);
		
		int layerNum = 1;
		for(Layer layer : layers){
			println("drawing layer " + layerNum + " of " + layers.length);
			drawLayerToPrintCanvas(layer);
			layerNum++;
		}

		print("rendering graphics... ");
		printCanvas.paintAll(tmp, false, 1); // PGraphics, uses3D, alpha
		endRecord();
		println("done.");

		println("writing image file...");
		tmp.save("output/" + filename + ".png");

		H.remove(printCanvas);

		println("");
		println("ALL DONE!");
		println("Nice job. Here's your file:");
		println(filename);
		println("");

	}
	
	

	void drawLayerToPrintCanvas(Layer layer) {
		HImage[] imgs = new HImage[layer.imageNames.length];
		for (int j = 0; j < imgs.length; ++j) {
			imgs[j] = new HImage(loadImage("images/" + layer.imageNames[j]));
		}
		
		for(int i = 0; i < layer.numImages; i++){
			HImage img = imgs[layer.imageIds.get(i)].createCopy();
			// println("	drawing image " + (i+1) + " of " + layer.numImages);
			
			float sx = layer.xScales.get(i) / pixelDensity;
			float sy = layer.yScales.get(i) / pixelDensity;
			float r = layer.rotations.get(i);
			float xPos = layer.xPositions.get(i) / pixelDensity;
			float yPos = layer.yPositions.get(i) / pixelDensity;
			
			img
				.alpha(layer.imageAlpha)
				.scale(sx, sy)
				.rotate(r)
				.loc( xPos, yPos )
				.anchorAt(H.CENTER)
			;
			printCanvas.add(img);
		}
	}

	void saveImageData(String filename, boolean includeImageData) {
		print("writing data file... ");
		JSONArray layersArray = new JSONArray();

		int layerNum = 0;
		for(Layer layer : layers) {
			JSONObject json = layer.getJSONData(includeImageData);
			json.setInt("id", layerNum);
			layersArray.setJSONObject(layerNum, json);
			layerNum++;
		}

		
		JSONObject obj = new JSONObject();
		obj.setJSONArray("layers", layersArray);
		obj.setFloat("printWidthInches", PRINT_W_INCHES);
		obj.setFloat("printHeightInches", PRINT_H_INCHES);
		obj.setInt("printResolution", PRINT_RESOLUTION);
		saveJSONObject(obj, "output/" + filename + ".json");
		// saveJSONArray(layersArray, "output/" + filename + ".json");
		println("done.");
	}
	
	
}