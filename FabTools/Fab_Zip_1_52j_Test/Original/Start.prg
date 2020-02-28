CLASS VulcanApp INHERIT App

METHOD Start() CLASS App
	LOCAL oMainWindow AS FabShellWindow

	oMainWindow := FabShellWindow{SELF}
	FabCenterWindow( oMainWindow )
	oMainWindow:Show()
	oMainWindow:HelpAbout()

	SELF:Exec()
return self
END CLASS

