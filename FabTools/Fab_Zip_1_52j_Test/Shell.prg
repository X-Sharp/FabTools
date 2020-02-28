using FabZip
using VO


class FabShellWindow inherit SHELLWINDOW 


  //USER CODE STARTS HERE (do NOT remove this line)

METHOD	FileExit()	
	//
	SELF:EndWindow()
        return self

METHOD	HelpAbout()	
	//
	HelpAbout{ SELF }:Show()
return self

CONSTRUCTOR(oParent)  

self:PreInit(oParent)

super(oParent)

self:Caption := "FabZip Test Shell"
self:HyperLabel := HyperLabel{#FabShellWindow,"FabZip Test Shell",NULL_STRING,NULL_STRING}
self:Menu := MENUSTD{}
self:Icon := ICON_ZIP{}
self:Origin := Point{12, 139}
self:Size := Dimension{800, 600}

self:PostInit(oParent)

return 

METHOD	ZipOpen()	
	LOCAL oWIn 	AS	FabZipTest1
	//
	oWin := FabZipTest1{ SELF }
	oWin:Show()
	//
return self
END CLASS

