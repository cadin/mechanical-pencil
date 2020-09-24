class Menu {
	
	int textY = 28;
	int textX = 32;
	
	String[][] instructions = { 
		{"E", "TOGGLE SETTINGS EDITOR"},
		{"S", "SAVE PREVIEW IMAGE (+ DATA)"},
		{"SHIFT S", "SAVE FULL SIZE IMAGE"},
		{"L", "LOAD CONFIG"},
		{"SHIFT L", "LOAD IMAGE DATA"},
		{"R", "RELOAD DATA"},
		{"SHIFT R", "START RENDER QUEUE"},
		{"C", "SAVE DATA FILE"},
		{"D", "LOAD FILE AT 2X RESOLUTION"},
		{"X", "CLEAR CANVAS"},
		{"", ""},
		{"M", "TOGGLE MENU"}
	};
	
	Menu() {
	
	}
	
	void draw() {
		pushMatrix();
			fill(0, 225);
			noStroke();
			
			rect(0,0, 400, height);
			stroke(255, 100);
			fill(255);
			textSize(12);
			text("COMMANDS MENU", 32, 48);
			text("[ M ]", 340, 48);
			line(32, 56, 368, 56);
			translate(0, 48);
	
			pushMatrix();
			for(int i = 0; i < instructions.length; i++){
				translate(0, 48);
				drawItem(instructions[i][0], instructions[i][1]);
			}
			popMatrix();
			
		popMatrix();
	}
	
	void drawItem(String key, String desc) {
		fill(255);
		text(key , 32, 0);
		fill(255, 100);
		text(desc, 32, 18);
	}
}