class HImageWithId extends HImage {
	
	int id = -1;
	
	HImageWithId(Object imgArg, int id) {
		image(imgArg);
		this.id = id;
	}
	
	@Override
	public HImageWithId createCopy() {
		HImageWithId copy = new HImageWithId(this.image(), this.id);
		copy.copyPropertiesFrom(this);
		return copy;
	}
	
}