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
	LOCAL oDlg	AS	MainDialog
	//
	oDlg :=	MainDialog{ SELF }
	oDlg:Show()
	//
return self

END CLASS
FUNCTION FabExtractFileExt( FileName AS STRING) AS STRING  PASCAL
//g Files,Files Related Classes/Functions
//p Extract File Extension info from FullPath String
//l Extract File Extension info from FullPath String
//r the File Extension ( always start with a . char )
//e "C:\TEST\TESTFILE.TST"			->	".TST"
//e "C:\TEST\TESTFILE."				->	"."
//e "C:\TEST\TESTFILE"				->	""
	LOCAL wPos		AS	DWORD
	LOCAL cResult	AS	STRING
	//
	wPos := SLen( FileName )
	// Starting at end of String, search for a Path, Drive or extension separator
	WHILE ( wPos > 0 )  .and. !Instr( SubStr3( FileName, wPos, 1 ), "\:." )
		wPos --
	ENDDO
	//
	IF ( wPos > 0 )  .AND. SubStr3( FileName, wPos, 1 ) == "."
		cResult := SubStr2( FileName, wPos )
	ENDIF
RETURN cResult


