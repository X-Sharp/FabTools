// Messages.prg
using System.Windows.Forms

Function FabMessageInfo( ) as void
	FabMessageInfo( NULL, NULL )
	return
	
Function FabMessageInfo( cText as string ) as void
	FabMessageInfo( cText, NULL )
	return 
	
Function FabMessageInfo( cText as string, cTitle as string ) as void
	//
	if ( cText == NULL )
		cText := ""
	endif
	if ( cTitle == NULL )
		cTitle := "Information"
	endif
	//
	MessageBox.Show( cText, cTitle, MessageBoxButtons.OK, MessageBoxIcon.Information )
	Return
	
	
Function FabMessageAlert( ) as void
	FabMessageAlert( NULL, NULL )
	return
	
Function FabMessageAlert( cText as string ) as void
	FabMessageAlert( cText, NULL )
	return 
	
Function FabMessageAlert( cText as string, cTitle as string ) as void
	//
	if ( cText == NULL )
		cText := ""
	endif
	if ( cTitle == NULL )
		cTitle := "Attention"
	endif
	//
	MessageBox.Show( cText, cTitle, MessageBoxButtons.OK, MessageBoxIcon.Exclamation )
	Return
	
	
FUNCTION FabMessageOkCancel( uText , uTitle, nDefButton ) AS LOGIC
	//g Messages,Messages Functions
	//p Show a MessageBox with a question mark icon, and two buttons : Ok & Cancel
	//l Show a MessageBox with a question mark icon, and two buttons : Ok & Cancel
	//x <uText> is the value to show in the text of MessageBox. ( Any types are accepted )\line
	//x <uTitle> is the value to show in the caption of MessageBox. ( Any types are accepted )\line
	//x \tab Default value is "Confirm" \line
	//x <nDefButton> indicate the Default button.\line
	//x \tab 1 mean Ok Button.\line
	//x \tab 2 mean Cancel Button.
	//r A logical value indicating if the Ok button has been pressed.
	LOCAL defaultButton AS MessageBoxDefaultButton
	//
	Default( @nDefButton, 1 )
	defaultButton := MessageBoxDefaultButton.Button1
	IF nDefButton == 2
		defaultButton := MessageBoxDefaultButton.Button2
	ELSEIF nDefButton == 3
		defaultButton := MessageBoxDefaultButton.Button3
	ENDIF
	//
	IF IsNil( uTitle )
		uTitle := "Confirm"
	ENDIF
	IF IsNil( uText )
		uText := ""
	ENDIF
	//
	VAR dr := MessageBox.Show( AsString( uText ), AsString( uTitle ), MessageBoxButtons.OKCancel , MessageBoxIcon.Question, defaultButton  )
	RETURN	( dr == DialogResult.OK )
	
	
	
	
FUNCTION FabMessageRetryCancel( uText , uTitle, nDefButton ) AS LOGIC
	//g Messages,Messages Functions
	//p Show a MessageBox with a stop-sign icon, and two buttons : Retry & Cancel
	//l Show a MessageBox with a stop-sign icon, and two buttons : Retry & Cancel
	//x <uText> is the value to show in the text of MessageBox. ( Any types are accepted )\line
	//x <uTitle> is the value to show in the caption of MessageBox. ( Any types are accepted )\line
	//x \tab Default value is "Confirm" \line
	//x <nDefButton> indicate the Default button.\line
	//x \tab 1 mean Retry Button.\line
	//x \tab 2 mean Cancel Button.
	//r A logical value indicating if the Retry button has been pressed.
	LOCAL defaultButton AS MessageBoxDefaultButton
	//
	Default( @nDefButton, 1 )
	defaultButton := MessageBoxDefaultButton.Button1
	IF nDefButton == 2
		defaultButton := MessageBoxDefaultButton.Button2
	ELSEIF nDefButton == 3
		defaultButton := MessageBoxDefaultButton.Button3
	ENDIF
	//
	IF IsNil( uTitle )
		uTitle := "Confirm"
	ENDIF
	IF IsNil( uText )
		uText := ""
	ENDIF
	//
	VAR dr := MessageBox.Show( AsString( uText ), AsString( uTitle ), MessageBoxButtons.RetryCancel, MessageBoxIcon.Hand, defaultButton  )
	RETURN	( dr == DialogResult.Retry )
	
	
PROCEDURE FabMessageStop( uText, uTitle )
	//g Messages,Messages Functions
	//p Show a MessageBox with a stop-sign icon.
	//l Show a MessageBox with a stop-sign icon.
	//x <uText> is the value to show in the text of MessageBox. ( Any types are accepted )\line
	//x <uTitle> is the value to show in the caption of MessageBox. ( Any types are accepted )\line
	//x \tab Default value is "Stop !"
	//
	IF IsNil( uTitle )
		uTitle := "Stop !"
	ENDIF
	IF IsNil( uText )
		uText := ""
	ENDIF
	//
	MessageBox.Show( AsString( uText ), AsString( uTitle ), MessageBoxButtons.Ok, MessageBoxIcon.Hand )
	RETURN
	
FUNCTION FabMessageYesNo( uText , uTitle, nDefButton ) AS LOGIC
	//g Messages,Messages Functions
	//p Show a MessageBox with a question mark icon, and two buttons : Yes & No
	//l Show a MessageBox with a question mark icon, and two buttons : Yes & No
	//x <uText> is the value to show in the text of MessageBox. ( Any types are accepted )\line
	//x <uTitle> is the value to show in the caption of MessageBox. ( Any types are accepted )\line
	//x \tab Default value is "Choose" \line
	//x <nDefButton> indicate the Default button.\line
	//x \tab 1 mean Yes Button.\line
	//x \tab 2 mean No Button.
	//r A logical value indicating if the Yes button has been pressed.
	LOCAL defaultButton AS MessageBoxDefaultButton
	//
	Default( @nDefButton, 1 )
	defaultButton := MessageBoxDefaultButton.Button1
	IF nDefButton == 2
		defaultButton := MessageBoxDefaultButton.Button2
	ELSEIF nDefButton == 3
		defaultButton := MessageBoxDefaultButton.Button3
	ENDIF
	//
	IF IsNil( uTitle )
		uTitle := "Choose"
	ENDIF
	IF IsNil( uText )
		uText := ""
	ENDIF
	//
	VAR dr := MessageBox.Show( AsString( uText ), AsString( uTitle ), MessageBoxButtons.YesNo , MessageBoxIcon.Question, defaultButton  )
	RETURN	( dr == DialogResult.Yes )
	
	
	
FUNCTION FabMessageYesNoCancel( uText, uTitle, nDefButton ) AS INT
	//g Messages,Messages Functions
	//p Show a MessageBox with a stop-sign icon, and three buttons : Yes, No & Cancel
	//l Show a MessageBox with a stop-sign icon, and three buttons : Yes, No & Cancel
	//x <uText> is the value to show in the text of MessageBox. ( Any types are accepted )\line
	//x <uTitle> is the value to show in the caption of MessageBox. ( Any types are accepted )\line
	//x \tab Default value is "Choose" \line
	//x <nDefButton> indicate the Default button.\line
	//x \tab 1 mean Yes Button.\line
	//x \tab 2 mean No Button.\line
	//x \tab 3 Mean Cancel Button.
	//r A lnumeric value, indicating what button has been pressed.
	LOCAL defaultButton AS MessageBoxDefaultButton
	//
	Default( @nDefButton, 1 )
	defaultButton := MessageBoxDefaultButton.Button1
	IF nDefButton == 2
		defaultButton := MessageBoxDefaultButton.Button2
	ELSEIF nDefButton == 3
		defaultButton := MessageBoxDefaultButton.Button3
	ENDIF
	//
	IF IsNil( uTitle )
		uTitle := "Choose"
	ENDIF
	IF IsNil( uText )
		uText := ""
	ENDIF
	//
	VAR dr := MessageBox.Show( AsString( uText ), AsString( uTitle ), MessageBoxButtons.YesNoCancel , MessageBoxIcon.Hand, defaultButton  )
	RETURN (int) dr
