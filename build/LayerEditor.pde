class LayerEditor {
	Toggle rotateControl;
	Toggle rotateAroundCenterControl;
	
	Toggle flipXControl;
	Toggle flipYControl;
	
	ControlP5 cp5;
	Group group;
	PFont font = createFont("DIN", 12 / pixelDensity);
	
	LayerEditor(ControlP5 controlP5, int layerNum) {
		
		cp5 = controlP5;
		
		String groupName = "Layer " + layerNum;
		
		group = cp5.addGroup(groupName)
			.setBarHeight(20)
			.setWidth(250)
			.setBackgroundColor(color(255,100))
			;
		// String name = ;
		rotateControl = cp5.addToggle("Rotate " + layerNum)
			.setLabel("Rotate")
			.setPosition(0,10)
			;
		setOptionsForToggle(rotateControl);
		
			
			
		rotateAroundCenterControl = cp5.addToggle("RAC " + layerNum)
			.setLabel("Rotate Around Center")
			.setPosition(0, 40)
			;
		setOptionsForToggle(rotateAroundCenterControl);
			// .setFont(font)
		
		
	}
	
	void setOptionsForToggle(Toggle t) {
		t
			.setSize(20,20)
			.setGroup(group);
		
		t
			.getCaptionLabel()
			.align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER)
			.setPaddingX(10)
			;
	}
	
	void updateControlsForLayer(Layer l) {
		rotateControl.setValue(l.shouldRotate);
		rotateAroundCenterControl.setValue(l.rotateAroundCenter);
	}
	
	void setValuesOnLayer(Layer l) {
		l.shouldRotate = rotateControl.getState();
		l.rotateAroundCenter = rotateAroundCenterControl.getState();
	}
	
	void destroy() {
		cp5.remove(group.getName());
	}
}