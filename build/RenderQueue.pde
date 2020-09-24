import java.io.FilenameFilter;

static final FilenameFilter jsonFilter = new FilenameFilter() {
	final String[] exts = {
		".json"
	};

	@Override 
	boolean accept(final File dir, String name) {
		name = name.toLowerCase();
		for (final String ext: exts) {
			if (name.endsWith(ext))  return true;
		}
		return false;
	}
};

class RenderQueue {
		
	String FOLDER_NAME = "renderQueue";
	
	File dir; 
	File[] files;
	int currentIndex = 0;
	File currentFile;
	String currentFilePath;
	String currentFilename;
	
	boolean isActive = false;
	
	RenderQueue() {
		dir = new File(dataPath(FOLDER_NAME));
	}
	
	void setData() {
		currentFile = files[currentIndex];
		currentFilePath = currentFile.getAbsolutePath();
		currentFilename = currentFile.getName();
		currentFilename = currentFilename.substring(0, currentFilename.length() - 5);
		println("rendering: " + currentFile.getName());
	}
	
	void next() {
		currentIndex++;
		if(currentIndex >= files.length){
			isActive = false;
			println("Render Queue finished.");
			return;
		}
		setData();
	}
	
	void load() {
		println("Loading Render Queue...");
		currentIndex = 0;
		
		files = dir.listFiles(jsonFilter);
		println("files to render: " + files.length);
		isActive = files.length > 0;
		if(isActive){
			setData();
		} else {
			println("no files to render.");
		}
		
	}
	
}