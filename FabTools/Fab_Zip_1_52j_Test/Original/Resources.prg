CLASS CDROM INHERIT Icon

METHOD Init() CLASS CDROM
   super:init(ResourceID{"CDROM", _GetInst()})
return self
END CLASS

CLASS Close INHERIT Icon

METHOD Init(kLoadoption, iWidth, iHeight) CLASS Close
	SUPER:init(ResourceID{"Close", _GetInst()},kLoadoption, iWidth, iHeight)
RETURN SELF
END CLASS

CLASS DelZip INHERIT Icon

METHOD Init(kLoadoption, iWidth, iHeight) CLASS DelZip
	SUPER:init(ResourceID{"DelZip", _GetInst()},kLoadoption, iWidth, iHeight)
RETURN SELF
END CLASS

CLASS Floppy INHERIT Icon

METHOD Init(kLoadoption, iWidth, iHeight) CLASS Floppy
	SUPER:init(ResourceID{"Floppy", _GetInst()},kLoadoption, iWidth, iHeight)
RETURN SELF
END CLASS

CLASS HardDisk INHERIT Icon

METHOD Init(kLoadoption, iWidth, iHeight) CLASS HardDisk
	SUPER:init(ResourceID{"HardDisk", _GetInst()},kLoadoption, iWidth, iHeight)
RETURN SELF
END CLASS

CLASS ICON_ZIP INHERIT Icon

METHOD Init() CLASS ICON_ZIP
   super:init(ResourceID{"ICON_ZIP", _GetInst()})
return self
END CLASS

CLASS NetWork INHERIT Icon

METHOD Init(kLoadoption, iWidth, iHeight) CLASS NetWork
	SUPER:init(ResourceID{"NetWork", _GetInst()},kLoadoption, iWidth, iHeight)
RETURN SELF
END CLASS

CLASS Open INHERIT Icon

METHOD Init(kLoadoption, iWidth, iHeight) CLASS Open
	SUPER:init(ResourceID{"Open", _GetInst()},kLoadoption, iWidth, iHeight)
RETURN SELF
END CLASS

