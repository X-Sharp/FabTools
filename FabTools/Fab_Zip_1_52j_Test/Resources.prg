USING VO

CLASS CDROM INHERIT Icon

	CONSTRUCTOR() 
		super(ResourceID{"CDROM", _GetInst()})
		return 
END CLASS

CLASS Close INHERIT Icon

	CONSTRUCTOR(kLoadoption, iWidth, iHeight) 
		SUPER(ResourceID{"Close", _GetInst()},kLoadoption, iWidth, iHeight)
		RETURN 
END CLASS

CLASS DelZip INHERIT Icon

	CONSTRUCTOR(kLoadoption, iWidth, iHeight) 
		SUPER(ResourceID{"DelZip", _GetInst()},kLoadoption, iWidth, iHeight)
		RETURN 
END CLASS

CLASS Floppy INHERIT Icon

	CONSTRUCTOR(kLoadoption, iWidth, iHeight) 
		SUPER(ResourceID{"Floppy", _GetInst()},kLoadoption, iWidth, iHeight)
		RETURN 
END CLASS

CLASS HardDisk INHERIT Icon

	CONSTRUCTOR(kLoadoption, iWidth, iHeight) 
		SUPER(ResourceID{"HardDisk", _GetInst()},kLoadoption, iWidth, iHeight)
		RETURN 
END CLASS

CLASS ICON_ZIP INHERIT Icon

	CONSTRUCTOR() 
		super(ResourceID{"ICON_ZIP", _GetInst()})
		return 
END CLASS

CLASS NetWork INHERIT Icon

	CONSTRUCTOR(kLoadoption, iWidth, iHeight) 
		SUPER(ResourceID{"NetWork", _GetInst()},kLoadoption, iWidth, iHeight)
		RETURN 
END CLASS

CLASS Open INHERIT Icon

	CONSTRUCTOR(kLoadoption, iWidth, iHeight) 
		SUPER(ResourceID{"Open", _GetInst()},kLoadoption, iWidth, iHeight)
		RETURN 
END CLASS

CLASS FABTOOLSBAR1 INHERIT Bitmap

	CONSTRUCTOR(kLoadoption, iWidth, iHeight) 
		SUPER(ResourceID{"FabtoolsBar1", _GetInst()},kLoadoption, iWidth, iHeight)
		RETURN 
END CLASS
