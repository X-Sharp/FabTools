// FabOpenDialogEx.prg


BEGIN NAMESPACE FabTools

   CLASS FabOpenDialogEx INHERIT OpenDialog
//g Window, Window/Dialog Related Classes/Functions
//p Enhanced OpenDialog class.
//l Enhanced OpenDialog class.
//d Using this class, you can custom the Windows OpenDialog by setting your own caption for each control in the dialog.
	// Text for the File Listview
	EXPORT	ListboxText		AS	STRING
//s
	// Text for the Open Button
	EXPORT	OkText			AS	STRING
	// Text for the Cancel Button
	EXPORT	CancelText		AS	STRING
	// Text for the Help Button
	EXPORT	HelpText			AS	STRING
	 // Text for the Combobox with drives
	EXPORT ComboDriveText	AS	STRING
	// Text for the SingleLineEdit
	EXPORT EditText			AS	STRING
	// Text for the Combobox with Filters
	EXPORT ComboFiltersText	AS	STRING
	// Text for the Read-Only Checkbox
	EXPORT CheckText		AS	STRING
	


    CONSTRUCTOR(oOwnWnd, cInitPath, dwFlag)  
    SUPER(oOwnWnd, cInitPath, dwFlag)
    RETURN
   	
    METHOD	Dispatch( xoEvent, xhDlg ) as usual
        LOCAL oEvent AS VO.Event
        Local hDlg as void Ptr
        //
        oEvent := (VO.Event) xoEvent
        hDlg := (Ptr) xhDlg
	    //
	    DO CASE
		    CASE ( oEvent:Message == WM_INITDIALOG )
			    //
			    IF !Empty( SELF:OkText )
				    CommDlg_OpenSave_SetControlText( hdlg, IDOK, LONG( _CAST, String2Psz( SELF:OkText ) )  )
			    ENDIF
			    //
			    IF !Empty( SELF:CancelText )
				    CommDlg_OpenSave_SetControlText( hdlg, IDCANCEL, LONG( _CAST, String2Psz( SELF:CancelText ) )  )
			    ENDIF
			    //
			    IF !Empty( SELF:ComboDriveText )
				    CommDlg_OpenSave_SetControlText( hdlg, STC4, LONG( _CAST, String2Psz( SELF:ComboDriveText ) )  )
			    ENDIF
			    //
			    IF !Empty( SELF:ListboxText )
				    CommDlg_OpenSave_SetControlText( hdlg, STC1, LONG( _CAST, String2Psz( SELF:ListboxText ) )  )
			    ENDIF
			    //
			    IF !Empty( SELF:EditText )
				    CommDlg_OpenSave_SetControlText( hdlg, STC3, LONG( _CAST, String2Psz( SELF:EditText ) )  )
			    ENDIF
			    //
			    IF !Empty( SELF:ComboFiltersText )
				    CommDlg_OpenSave_SetControlText( hdlg, STC2, LONG( _CAST, String2Psz( SELF:ComboFiltersText ) )  )
			    ENDIF
			    //
			    IF !Empty( SELF:HelpText )
				    CommDlg_OpenSave_SetControlText( hdlg, pshHelp, LONG( _CAST, String2Psz( SELF:HelpText ) )  )
			    ENDIF
 			    //
			    IF !Empty( SELF:CheckText )
				    CommDlg_OpenSave_SetControlText( hdlg, chx1, LONG( _CAST, String2Psz( SELF:CheckText ) )  )
			    ENDIF
 			    //
	    ENDCASE
	    //
    RETURN	0	

         
   END CLASS
   
END NAMESPACE // FabTools
   