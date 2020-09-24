class Editor {
	
	ControlP5 cp5;
	color bgColor = color(25);
	
	Numberbox widthControl;
	Numberbox heightControl;
	Toggle transparencyControl;
		
	float printW;
	float printH;
	
	Document document;
	LayerEditor[] layerEditors;
	
	Editor(PApplet app, Document doc) {
		cp5 = new ControlP5(app);
		document = doc;
		
		PFont font = createFont("DIN", 12 / pixelDensity);
		cp5.setFont(font);
		
		widthControl = cp5.addNumberbox("Width")
			.setPosition(100,220)
			.setSize(100,20)
			.setRange(1.0,60.0)
			.setMultiplier(0.125) // set the sensitifity of the numberbox
			.setDirection(Controller.HORIZONTAL) // change the control direction to left/right
			.setValue(PRINT_W_INCHES)
			.setDecimalPrecision(3)
			.setId(1)
			;
			
		heightControl = cp5.addNumberbox("Height")
			.setPosition(100,280)
			.setSize(100,20)
			.setRange(1.0,60.0)
			.setMultiplier(0.125) // set the sensitifity of the numberbox
			.setDirection(Controller.HORIZONTAL) // change the control direction to left/right
			.setValue(PRINT_H_INCHES)
			.setDecimalPrecision(3)
			.setId(2)
			;
		
		transparencyControl = cp5.addToggle("Transparency")
			.setPosition(100,400)
			.setSize(20,20)
			.setValue(TRANSPARENT_BG)
			;
		
		transparencyControl
			.getCaptionLabel()
			.align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER)
			.setPaddingX(10)
			;
		
		hide();
	}
	
	void updateLayerControls() {
		removeLayerEditors();
		createLayerEditors();
	}
	
	void removeLayerEditors() {
		if(layerEditors == null) return;
		
		for(int i = 0; i < layerEditors.length; i++) {
			layerEditors[i].destroy();
			layerEditors[i] = null;
		}
	}
	
	void createLayerEditors() {
		layerEditors = new LayerEditor[layers.length];
		for(int i = 0; i < layerEditors.length; i++){
			LayerEditor l = new LayerEditor(cp5, i);
			l.group.setPosition(100 + (i * 300), 500);
			layerEditors[i] = l;
		}
	}
	
	void show() {
		widthControl.setValue(PRINT_W_INCHES);
		heightControl.setValue(PRINT_H_INCHES);
		transparencyControl.setValue(TRANSPARENT_BG);
		
		if(layers != null){
			for(int i = 0; i < layers.length; i++) {
				layerEditors[i].updateControlsForLayer(layers[i]);
			}
		}
		
		cp5.show();
	}
	
	void hide() {
		PRINT_W_INCHES = widthControl.getValue();
		PRINT_H_INCHES = heightControl.getValue();
		TRANSPARENT_BG = transparencyControl.getState();
		
		if(layers != null){
			for(int i = 0; i < layers.length; i++) {
				layerEditors[i].setValuesOnLayer(layers[i]);
			}
		}
		cp5.hide();
	}
	
	void draw() {
		background(bgColor);
	}
	
	void controlEvent(ControlEvent e) {
		// println(" - got a control event from controller with id " + e.getId());
		// switch(theEvent.getId()) {
		// 	case(1): // numberboxA is registered with id 1
		// 		println((theEvent.getController().getValue()));
		// 	break;
		// 	case(2):  // numberboxB is registered with id 2
		// 		println((theEvent.getController().getValue()));
		// 	break;
		// }
	}
}

public void controlEvent(ControlEvent e) {
	// forward control events to Editor
	if(editor != null){
		editor.controlEvent(e);
	}
}