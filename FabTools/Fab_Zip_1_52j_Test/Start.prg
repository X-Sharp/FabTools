USING VO

CLASS MyStartApp INHERIT App

METHOD Start() 
	LOCAL oMainWindow AS FabShellWindow

	oMainWindow := FabShellWindow{SELF}
	//FabCenterWindow( oMainWindow )
	oMainWindow:Show()
	oMainWindow:HelpAbout()

	SELF:Exec()
return self
END CLASS

