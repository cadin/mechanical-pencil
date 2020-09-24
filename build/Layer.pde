class Layer {

	HCanvas canvas;
	HDrawablePool pool;

	// String imageName = "";
	String[] imageNames;
	int imageAlpha = 255;

	float minScale = 0.5;
	float maxScale = 2.0;

	boolean avoidCenter = false;
	boolean shouldFlipX = false;
	boolean shouldFlipY = false;
	boolean flipOnBothAxesOnly = false;
	boolean shouldRotate = false;
	boolean rotateAroundCenter = false;
	float rotationOffset = 0;
	float containingCircleRadius = 0;
	float rotationAmount = 0;

	FloatList xScales = new FloatList();
	FloatList yScales = new FloatList();
	FloatList xPositions = new FloatList();
	FloatList yPositions = new FloatList();
	FloatList rotations = new FloatList();
	IntList imageIds = new IntList();

	float edgeMargin = 0;
	float centerMargin = 0;
	boolean bleedMargins = true;

	int numImages = 0;
	int poolSize = 0;

	boolean constrainToImage = false;
	String imageMaskName;
	PImage imageMask;

	float[] _unscaledImageWidths;
	float[] _unscaledImageHeights;
	
	int layerToOverlap = 0;
	int trackingLayer = 0;
	boolean shouldOverlapLayer = false;
	boolean useLayerMask = false;
	boolean maskIsBlank = true;
	
	String imagePrefix = "";

	PVector canvasCenter = new PVector(PRINT_W_INCHES/2 * PRINT_RESOLUTION, PRINT_H_INCHES/2 * PRINT_RESOLUTION);

	Layer() {
		canvas = new HCanvas().autoClear(false);
	}
	
	void constrainToImageNamed(String imgName) {
		imageMaskName = imgName;
		imageMask = loadImage("images/" +imagePrefix + imageMaskName);
		constrainToImage = true;
		maskIsBlank = false;
	}
	
	void constrainToLayerMask(PImage mask) {
		imageMask = mask;
		constrainToImage = true;
	}
	
	void clearLayerMask() {
		color c = color(0,0,0,255);
		layerMask.beginDraw();
			layerMask.background(c);
		layerMask.endDraw();
	}
	
	void setUpLayerMask(int layerNum) {
		trackingLayer = layerNum;
		layerMask = createGraphics(int(PRINT_W_INCHES * PRINT_RESOLUTION * SCREEN_SCALE * displayDensity()), int(PRINT_H_INCHES * PRINT_RESOLUTION * SCREEN_SCALE * displayDensity()));
		useLayerMask = true;
		clearLayerMask();
	}
	
	PImage[] createImageArray(String[] imgNames) {
		int len = imgNames.length;
		PImage[] pImgs = new PImage[len];
		_unscaledImageWidths = new float[len];
		_unscaledImageHeights = new float[len];
		for (int i = 0; i < len; ++i) {
			println("creating image: " + imgNames[i]);
			PImage img = loadImage("images/" + imagePrefix + imgNames[i]);
			pImgs[i] = img;
			_unscaledImageWidths[i] = img.width;
			_unscaledImageHeights[i] = img.height;
		}
		
		return pImgs;
	}
	
	void loadImageData(JSONObject data, int resolutionMultiplier) {
		
		numImages = data.getInt("totalImages");
		
		JSONArray _xScales = data.getJSONArray("xScales");
		JSONArray _yScales = data.getJSONArray("yScales");
		JSONArray _xPositions = data.getJSONArray("xPositions");
		JSONArray _yPositions = data.getJSONArray("yPositions");
		JSONArray _rotations = data.getJSONArray("rotations");
		
		JSONArray _imageIds = null;
		if(data.isNull("imageIds")) {
			_imageIds = new JSONArray();
			for(int j = 0; j < numImages; j++){
				_imageIds.setInt(j, 0);
			}
			
		} else {
			_imageIds = data.getJSONArray("imageIds");
		}
				
		PImage[] pImgs = createImageArray(imageNames);
		
		for(int i = 0; i < numImages; i++){
			println(" image " + (i+1) + " of " + numImages);
			int imgId = 0;
			if(_imageIds != null) {
				imgId = _imageIds.getInt(i);
			}
			
 			HImageWithId img = new HImageWithId(pImgs[imgId], imgId);
 			canvas.add(img)
				.anchorAt(H.CENTER)
				.alpha(imageAlpha)
				.scale(_xScales.getFloat(i) * SCREEN_SCALE * resolutionMultiplier, _yScales.getFloat(i) * SCREEN_SCALE * resolutionMultiplier)
				.rotate( _rotations.getFloat(i) )
				.loc( _xPositions.getFloat(i) * SCREEN_SCALE * resolutionMultiplier, _yPositions.getFloat(i) * SCREEN_SCALE * resolutionMultiplier)
			;
			
			recordImagePosition(img);
		}
		
		println("Layer loaded.");
	}
	
	void removeAllChildren() {
		while(canvas.numChildren() > 0) {
			canvas.remove(canvas.firstChild());
		}
	}
	
	void restoreChildren() {
		for (HDrawable obj : pool) {
			canvas.add(obj);
		}
	}
	
	String[] parseImageNames(JSONArray jsonArray) {
		int len = jsonArray.size();
		String[] arr = new String[len];
		for (int i = 0; i < len; i++) {
			arr[i] = jsonArray.getString(i);
		}
		
		return arr;
	}
	
	void loadSettings(JSONObject settings) {
		
		imagePrefix = "";
		if(!settings.isNull("imagePrefix")){
			imagePrefix = settings.getString("imagePrefix");
		}
	
		if(settings.isNull("imageNames")){
			imageNames = new String[1];
			imageNames[0] = settings.getString("imageName");
		} else {
			imageNames = parseImageNames(settings.getJSONArray("imageNames"));
		}
		
		imageAlpha = settings.getInt("imageAlpha");
		minScale = settings.getFloat("minScale");
		maxScale = settings.getFloat("maxScale");
		
		if(settings.isNull("avoidCenter")){
			avoidCenter = false;
		} else {
			avoidCenter = settings.getBoolean("avoidCenter");
		}
		
		if(settings.isNull("shouldFlipX")){
			// handle typo in older data files
			shouldFlipX = settings.getBoolean("sholdFlipX");
		} else {
			shouldFlipX = settings.getBoolean("shouldFlipX");
		}
		
		if(!settings.isNull("flipOnBothAxesOnly")){
			flipOnBothAxesOnly = settings.getBoolean("flipOnBothAxesOnly");
		}
		
		shouldFlipY = settings.getBoolean("shouldFlipY");
		shouldRotate = settings.getBoolean("shouldRotate");
		rotateAroundCenter = settings.getBoolean("rotateAroundCenter");
		rotationOffset = settings.getFloat("rotationOffset");
		
		if(settings.isNull("rotationAmount")){
			rotationAmount = 360.0;
		} else {
			rotationAmount = settings.getFloat("rotationAmount");
		}
		
		edgeMargin = settings.getFloat("edgeMarginInches");
		centerMargin = settings.getFloat("centerMarginInches");
		bleedMargins = settings.getBoolean("bleedMargins");
		containingCircleRadius = settings.getFloat("containingCircleRadius");
		
		if(settings.isNull("imagePoolSize")){
			int poolMin = settings.getInt("imagePoolMin");
			int poolMax = settings.getInt("imagePoolMax");
			poolSize = (int)random(poolMin, poolMax);
		} else {
			poolSize = settings.getInt("imagePoolSize");
		}
		
		if(!settings.isNull("constrainToImage")){
			constrainToImage = settings.getBoolean("constrainToImage");
			if(constrainToImage) {
				imageMaskName = settings.getString("imageMaskName");
			}
		}
		
		if(!settings.isNull("overlapLayer")) {
			layerToOverlap = settings.getInt("overlapLayer");
			shouldOverlapLayer = true;
		}
	}

	JSONArray encodeFloatList(FloatList props) {
		JSONArray json = new JSONArray();
		int len = props.size();
		for(int i=0; i< len; i++) {
			json.setFloat(i, props.get(i));
		}
		return json;
	}
	
	JSONArray encodeIntList(IntList list) {
		JSONArray json = new JSONArray();
		int len = list.size();
		for(int i=0; i< len; i++) {
			json.setInt(i, list.get(i));
		}
		return json;
	}

	JSONObject getJSONData(boolean includeImageData) {
		JSONObject json = new JSONObject();
		
		JSONArray imgNames = new JSONArray();
		for (int j = 0; j < imageNames.length; j++) {
			imgNames.setString(j, imageNames[j]);
		}
		
		json.setJSONArray("imageNames", imgNames);
		json.setInt("imageAlpha", imageAlpha);
		json.setFloat("minScale", minScale);
		json.setFloat("maxScale", maxScale);
		json.setBoolean("avoidCenter", avoidCenter);
		json.setBoolean("shouldFlipX", shouldFlipX);
		json.setBoolean("shouldFlipY", shouldFlipY);
		json.setBoolean("flipOnBothAxesOnly", flipOnBothAxesOnly);
		json.setBoolean("shouldRotate", shouldRotate);
		json.setBoolean("rotateAroundCenter", rotateAroundCenter);
		json.setFloat("rotationOffset", rotationOffset);
		json.setFloat("edgeMarginInches", edgeMargin);
		json.setFloat("centerMarginInches", centerMargin);
		json.setBoolean("bleedMargins", bleedMargins);
		json.setInt("imagePoolSize", pool.max());
		json.setInt("totalImages", numImages);
		json.setFloat("containingCircleRadius", containingCircleRadius);
		json.setBoolean("constrainToImage", constrainToImage);
		json.setFloat("rotationAmount", rotationAmount);
		if(constrainToImage){
			json.setString("imageMaskName", imageMaskName);
		}
		
		if(includeImageData){
			FloatList[] props = {xScales, yScales, xPositions, yPositions, rotations};
			String[] propNames = {"xScales", "yScales", "xPositions", "yPositions", "rotations"};

			for(int i=0; i < props.length; i++){
				JSONArray propArray = encodeFloatList(props[i]);
				json.setJSONArray(propNames[i], propArray);
			}
			
			json.setJSONArray("imageIds", encodeIntList(imageIds));
		}
		
		return json;
	}

	void rotateAroundCenter(float offset) {
		rotateAroundCenter = true;
		rotationOffset = offset;
	}

	void constrainToCircle(float radius) {
		containingCircleRadius = radius;
	}

	void setMargins(float inches, boolean bleed) {
		edgeMargin = inches;
		bleedMargins = bleed;
	}

	void setScales(float min, float max) {
		minScale = min;
		maxScale = max;
	}

	void init() {
		init(poolSize, poolSize);
	}

	void init(int poolMin, int poolMax) {
		if(constrainToImage){
			imageMask = loadImage("images/" + imagePrefix + imageMaskName);
		}
		
		int poolSize = (int)random(poolMin, poolMax);
		pool = createObjectPool(poolSize);
		pool.autoParent(canvas);
	}

	HDrawablePool createObjectPool(int numItems) {
		
		PImage[] pImgs = createImageArray(imageNames);
		
		HDrawablePool p = new HDrawablePool(numItems);
		// p.autoAddToStage();
		for (int i = 0; i < pImgs.length; ++i) {
			HImage img = new HImageWithId(pImgs[i], i);
			p.add(img);
		}
		p.onCreate(
			new HCallback() {
				public void run(Object obj) {
					positionObject(obj);
				}
			}
		);

		return p;
	}

	PVector randomPointWithinBounds(float xMin, float yMin, float xMax, float yMax) {
		float x = random(xMin, xMax);
		float y = random(yMin, yMax);

		return new PVector(x, y);
	}

	PVector randomPointWithinRadius(float radius) {
		float a = random(1);
		float b = random(1);
		if (b < a) {
			float temp = b;
			b = a;
			a = temp;
		}
		float newPointX = b * radius * cos(2 * PI * a / b);
		float newPointY = b * radius * sin(2 * PI * a / b);

		return new PVector(newPointX, newPointY);
	}

	boolean imageContainsPoint(PImage img, PVector loc) {
		
		float locX = map(loc.x, 0, PRINT_W_INCHES * PRINT_RESOLUTION, 0, img.width);
		float locY = map(loc.y, 0, PRINT_H_INCHES * PRINT_RESOLUTION, 0, img.height);
		
		color c = img.get(int(locX) , int(locY) );
		color blk1 = color(0,0,0,0);
		color blk2 = color(0,0,0,255);
		
		return (c != blk1) && (c != blk2);
	}

	void positionObject(Object obj) { 
		
		int flipX = 1; int flipY = 1;

		if(shouldFlipX) {
			flipX = (int)random(2);
			if(flipX == 0) flipX = -1;
		}

		if(shouldFlipY) {
			flipY = (int)random(2);
			if(flipY == 0) flipY = -1;
		}
		
		if(flipOnBothAxesOnly) {
			flipY = flipX;
		}

		float r = 0;
		if(shouldRotate){ r = random(rotationAmount); }


		HImageWithId d = (HImageWithId) obj;
		d.rotate(-d.rotation());
		
		int imgId = d.id;
		float unscaledWidth = _unscaledImageWidths[imgId];

		float scaleMod = abs(unscaledWidth / d.width());
		float s = scaleMod * random(minScale, maxScale);


		PVector center = new PVector(PRINT_W_INCHES/2 * PRINT_RESOLUTION, PRINT_H_INCHES/2 * PRINT_RESOLUTION);
		PVector loc = new PVector(0,0);

		float minX = edgeMargin * PRINT_RESOLUTION;
		float maxX = (PRINT_W_INCHES * PRINT_RESOLUTION) - (edgeMargin * PRINT_RESOLUTION);
		float minY = edgeMargin * PRINT_RESOLUTION;
		float maxY = (PRINT_H_INCHES * PRINT_RESOLUTION) - (edgeMargin * PRINT_RESOLUTION);

		if(!bleedMargins) {
			PVector bounds = d.boundingSize();

			float w = abs(bounds.x * s * flipX);
			float h = abs(bounds.y * s * flipY);

			minX += w/2;
			maxX -= w/2;

			minY += h/2;
			maxY -= h/2;
		}

		do {
			if(containingCircleRadius > 0){
				do {
					loc = randomPointWithinRadius(containingCircleRadius * PRINT_RESOLUTION);
					loc.x += center.x;
					loc.y += center.y;
				} while (center.dist(loc) < centerMargin * PRINT_RESOLUTION);
			} else {
				do {
					loc = randomPointWithinBounds(minX, minY, maxX, maxY);
				} while (center.dist(loc) < centerMargin * PRINT_RESOLUTION);
			}
		} while (constrainToImage && !imageContainsPoint(imageMask, loc));

		float xPos = loc.x;
		float yPos = loc.y;


		if(rotateAroundCenter){
			PVector locFromCenter = new PVector(xPos - canvasCenter.x, yPos - canvasCenter.y);
			float angle = locFromCenter.heading();

			r = angle * 180 / PI;
			
		}
		r += rotationOffset;
		
		d
			.anchorAt(H.CENTER)
			.alpha(imageAlpha)
			.scale(s * flipX * SCREEN_SCALE, s * flipY * SCREEN_SCALE)
			.rotate( r )
			.loc( xPos * SCREEN_SCALE, yPos * SCREEN_SCALE )
		;
	}

	void randomize() {
		if(constrainToImage && maskIsBlank) return;
		
		pool.requestAll();
		for (HDrawable obj : pool) {
			positionObject(obj);
		}
	}
	
	int[] poolIds;
	
	void clearImagePositions() {
		xScales = new FloatList();
		yScales = new FloatList();
		xPositions = new FloatList();
		yPositions = new FloatList();
		rotations = new FloatList();
		imageIds = new IntList();
		numImages = 0;
	}
	
	void recordImagePosition(HImage img) {
		int id = ((HImageWithId)img).id;
		float unscaledWidth = _unscaledImageWidths[id];
		float unscaledHeight = _unscaledImageHeights[id];
		imageIds.append(id);
		xScales.append(img.width() / unscaledWidth / SCREEN_SCALE);
		yScales.append(img.height() / unscaledHeight / SCREEN_SCALE);
		rotations.append(img.rotation());
		xPositions.append((img.x() / SCREEN_SCALE));
		yPositions.append((img.y() / SCREEN_SCALE));
	}
	
	
	PGraphics layerMask;
	void drawImageToLayerMask(HImage img) {
		PImage pImg = img.image();
		
		layerMask.beginDraw();
			layerMask.imageMode(CENTER);
			layerMask.translate(img.x(), img.y());
			layerMask.rotate(radians(img.rotation()));
			layerMask.image(pImg, 0,0, img.width(), img.height());
		layerMask.endDraw();
	}

	void recordImagePositions() {
		if(pool == null) return;
		
		for (HDrawable obj : pool){
			numImages ++;
			HImage d = (HImage)obj;
			recordImagePosition(d);
			if(useLayerMask){
				drawImageToLayerMask(d);
			}
		}
	}
}