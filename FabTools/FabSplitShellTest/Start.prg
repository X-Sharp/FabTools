#region DEFINES
DEFINE APPVersion := "1.0"
#endregion

[STAThread];
FUNCTION Start() AS INT
	LOCAL oXApp AS XApp
	TRY
		oXApp := XApp{}
		oXApp:Start()
	CATCH oException AS Exception
		ErrorDialog(oException)
	END TRY
RETURN 0

CLASS XApp INHERIT App
METHOD Start() 
	LOCAL oShell AS MainWindow
	//
	oShell := MainWindow{ SELF }
	oShell:Show(SHOWCENTERED)
	//
	SELF:Exec()
	//	
return self

END CLASS
