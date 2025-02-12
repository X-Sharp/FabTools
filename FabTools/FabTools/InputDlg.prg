// InputDlg.prg
using System.Windows.Forms


FUNCTION FabInputBox( 	cCaption AS STRING, ;
						cPrompt AS STRING, ;
						cDefault AS STRING, ;
						lCentered := TRUE AS LOGIC, ;
						cOk := "&Ok" AS STRING, ;
						cCancel := "&Cancel" AS STRING, ;
						oOwner := NIL AS USUAL ) AS STRING
/// <summary> 
/// Provide an Easy-to-use Input box.
/// The function will draw a dialogbox, using the desired string, and return the result of the input.
/// </summary>
/// <params>
/// <cCaption> is a string with the DialogBox Caption\line
/// <cPrompt> is a string with the DialogBox cPrompt \line
/// <cDefault> is a string with the default value \line
/// <lCentered> is a logic value indicating if the DialogBox must be centered\line
/// <cOk> is a string with the caption of the Ok button. ( &Ok per default )\line
/// <cCancel> is a string with the caption of the Cancel button. ( &Cancel per default )\line
/// </params>
/// <return>
/// The TextValue of the SingleLineEdit control if the Ok button has been pressed, the Default value unless.
/// </return>
	LOCAL oDlg	AS	FabTools.FabInputDlg
	LOCAL cRet	AS	STRING
	Local Result as DialogResult
	//
	oDlg := FabTools.FabInputDlg{ cPrompt, cCaption }
	//
	oDlg:txtInput:Text := cDefault
	oDlg:btnOk:Text := cOk
	oDlg:btnCancel:Text := cCancel
	IF lCentered
		FabCenterWindow( oDlg )
	ENDIF
	//
	Result := oDlg:ShowDialog()
	IF ( Result == DialogResult.OK )
		cRet := AllTrim( oDlg:txtInput:Text )
	ELSE
		cRet := cDefault
	ENDIF
RETURN cRet


BEGIN NAMESPACE FabTools

    class FabInputDlg inherit System.Windows.Forms.Form
        // Fields
        export btnCancel as System.Windows.Forms.Button
        export btnOK as System.Windows.Forms.Button
        private lblPrompt as System.Windows.Forms.Label
        export txtInput as System.Windows.Forms.TextBox

        // Methods
        constructor(prompt as string, title as string)
            super()
            //
            self:Init(prompt, title, System.Int32.MinValue, System.Int32.MinValue)


        constructor(prompt as string, title as string, xPos as Long, yPos as Long)
            super()
            //
            self:Init(prompt, title, xPos,  yPos)
            
        private METHOD Init(prompt as string, title as string, xPos as Long, yPos as Long) as void
            local size as System.Drawing.SizeF
            //
            if ((xPos != System.Int32.MinValue) .and. (yPos != System.Int32.MinValue))
                //
                Super:StartPosition := System.Windows.Forms.FormStartPosition.Manual
                Super:Location := System.Drawing.Point{xPos, yPos}
            endif
            // Build Dialog
            self:InitializeComponent()
            //
            self:lblPrompt:Text := prompt
            self:Text := title
            //
            size := Super:CreateGraphics():MeasureString(prompt, self:lblPrompt:Font, self:lblPrompt:Width)
            //
            if (size:Height > self:lblPrompt:Height)
                //
                Super:Height := Super:Height + ((Long)size:Height  - self:lblPrompt:Height)
            endif
            self:txtInput:SelectionStart := 0
            self:txtInput:SelectionLength := self:txtInput:Text:Length
            self:txtInput:Focus()

        private method InitializeComponent() as void
            //
            self:lblPrompt := System.Windows.Forms.Label{}
            self:txtInput := System.Windows.Forms.TextBox{}
            self:btnOK := System.Windows.Forms.Button{}
            self:btnCancel := System.Windows.Forms.Button{}
            Super:SuspendLayout()
            self:lblPrompt:Anchor := (System.Windows.Forms.AnchorStyles.Left | (System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Top))
            self:lblPrompt:BackColor := System.Drawing.SystemColors.Control
            self:lblPrompt:Font := System.Drawing.Font{"Microsoft Sans Serif", Real4(8.25), System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, 0}
            self:lblPrompt:Location := System.Drawing.Point{12, 9}
            self:lblPrompt:Name := "lblPrompt"
            self:lblPrompt:Size := System.Drawing.Size{0x12e, 0x47}
            self:lblPrompt:TabIndex := 3
            self:txtInput:Anchor := (System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Bottom)
            self:txtInput:Location := System.Drawing.Point{8, 0x58}
            self:txtInput:Name := "txtInput"
            self:txtInput:Size := System.Drawing.Size{0x17d, 20}
            self:txtInput:TabIndex := 0
            self:txtInput:Text := ""
            self:btnOK:DialogResult := System.Windows.Forms.DialogResult.OK
            self:btnOK:Location := System.Drawing.Point{0x146, 8}
            self:btnOK:Name := "btnOK"
            self:btnOK:Size := System.Drawing.Size{0x40, 0x18}
            self:btnOK:TabIndex := 1
            self:btnOK:Text := "&OK"
            self:btnCancel:DialogResult := System.Windows.Forms.DialogResult.Cancel
            self:btnCancel:Location := System.Drawing.Point{0x146, 40}
            self:btnCancel:Name := "btnCancel"
            self:btnCancel:Size := System.Drawing.Size{0x40, 0x18}
            self:btnCancel:TabIndex := 2
            self:btnCancel:Text := "&Cancel"
            Super:AcceptButton := self:btnOK
            self:AutoScaleBaseSize := System.Drawing.Size{5, 13}
            Super:CancelButton := self:btnCancel
            Super:ClientSize := System.Drawing.Size{0x18e, 0x75}
            Super:Controls:Add(self:txtInput)
            Super:Controls:Add(self:btnCancel)
            Super:Controls:Add(self:btnOK)
            Super:Controls:Add(self:lblPrompt)
            Super:FormBorderStyle := System.Windows.Forms.FormBorderStyle.FixedDialog
            Super:MaximizeBox := false
            Super:MinimizeBox := false
            Super:Name := "FabInputDlg"
            Super:ResumeLayout(false)


    end class

END NAMESPACE // FabTools