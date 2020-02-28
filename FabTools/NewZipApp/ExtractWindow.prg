
#using System.Windows.Forms

CLASS ExtractWindow INHERIT System.Windows.Forms.Form
    
    EXPORT comboToPath AS System.Windows.Forms.ComboBox
    PRIVATE label1 AS System.Windows.Forms.Label
    PRIVATE ExtractToFolderPB AS System.Windows.Forms.Button
    PRIVATE groupBoxOptions AS System.Windows.Forms.GroupBox
    PRIVATE cbOverwrite AS System.Windows.Forms.CheckBox
    PRIVATE cancelPB AS System.Windows.Forms.Button
    PRIVATE ExtractPB AS System.Windows.Forms.Button
    /// <summary>
    /// Required designer variable.
    /// </summary>
    PRIVATE components := NULL AS System.ComponentModel.IContainer
    CONSTRUCTOR()
      SUPER()
      SELF:InitializeComponent()
      RETURN
    
   /// <summary>
   /// Clean up any resources being used.
   /// </summary>
   /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
    PROTECTED VIRTUAL METHOD Dispose( disposing AS System.Boolean ) AS System.Void
      IF disposing && components != NULL
         components:Dispose()
      ENDIF
      SUPER:Dispose( disposing )
      RETURN
    
   /// <summary>
   /// Required method for Designer support - do not modify
   /// the contents of this method with the code editor.
   /// </summary>
    PRIVATE METHOD InitializeComponent() AS System.Void
        SELF:comboToPath := System.Windows.Forms.ComboBox{}
        SELF:label1 := System.Windows.Forms.Label{}
        SELF:ExtractToFolderPB := System.Windows.Forms.Button{}
        SELF:groupBoxOptions := System.Windows.Forms.GroupBox{}
        SELF:cbOverwrite := System.Windows.Forms.CheckBox{}
        SELF:cancelPB := System.Windows.Forms.Button{}
        SELF:ExtractPB := System.Windows.Forms.Button{}
        SELF:groupBoxOptions:SuspendLayout()
        SELF:SuspendLayout()
        // 
        // comboToPath
        // 
        SELF:comboToPath:FormattingEnabled := TRUE
        SELF:comboToPath:Location := System.Drawing.Point{89, 12}
        SELF:comboToPath:Name := "comboToPath"
        SELF:comboToPath:Size := System.Drawing.Size{258, 21}
        SELF:comboToPath:TabIndex := 0
        // 
        // label1
        // 
        SELF:label1:AutoSize := TRUE
        SELF:label1:Location := System.Drawing.Point{12, 15}
        SELF:label1:Name := "label1"
        SELF:label1:Size := System.Drawing.Size{58, 13}
        SELF:label1:TabIndex := 1
        SELF:label1:Text := "Extract to :"
        // 
        // ExtractToFolderPB
        // 
        SELF:ExtractToFolderPB:Location := System.Drawing.Point{353, 10}
        SELF:ExtractToFolderPB:Name := "ExtractToFolderPB"
        SELF:ExtractToFolderPB:Size := System.Drawing.Size{30, 23}
        SELF:ExtractToFolderPB:TabIndex := 2
        SELF:ExtractToFolderPB:Text := "..."
        SELF:ExtractToFolderPB:UseVisualStyleBackColor := TRUE
        SELF:ExtractToFolderPB:Click += System.EventHandler{ SELF, @ExtractToFolderPB_Click() }
        // 
        // groupBoxOptions
        // 
        SELF:groupBoxOptions:Controls:Add(SELF:cbOverwrite)
        SELF:groupBoxOptions:Location := System.Drawing.Point{12, 39}
        SELF:groupBoxOptions:Name := "groupBoxOptions"
        SELF:groupBoxOptions:Size := System.Drawing.Size{371, 117}
        SELF:groupBoxOptions:TabIndex := 3
        SELF:groupBoxOptions:TabStop := FALSE
        SELF:groupBoxOptions:Text := "Options"
        // 
        // cbOverwrite
        // 
        SELF:cbOverwrite:AutoSize := TRUE
        SELF:cbOverwrite:Location := System.Drawing.Point{6, 19}
        SELF:cbOverwrite:Name := "cbOverwrite"
        SELF:cbOverwrite:Size := System.Drawing.Size{128, 17}
        SELF:cbOverwrite:TabIndex := 4
        SELF:cbOverwrite:Text := "Confirm File Overwrite"
        SELF:cbOverwrite:UseVisualStyleBackColor := TRUE
        // 
        // cancelPB
        // 
        SELF:cancelPB:Location := System.Drawing.Point{308, 162}
        SELF:cancelPB:Name := "cancelPB"
        SELF:cancelPB:Size := System.Drawing.Size{75, 23}
        SELF:cancelPB:TabIndex := 4
        SELF:cancelPB:Text := "Cancel"
        SELF:cancelPB:UseVisualStyleBackColor := TRUE
        SELF:cancelPB:Click += System.EventHandler{ SELF, @cancelPB_Click() }
        // 
        // ExtractPB
        // 
        SELF:ExtractPB:Location := System.Drawing.Point{227, 162}
        SELF:ExtractPB:Name := "ExtractPB"
        SELF:ExtractPB:Size := System.Drawing.Size{75, 23}
        SELF:ExtractPB:TabIndex := 5
        SELF:ExtractPB:Text := "Extract"
        SELF:ExtractPB:UseVisualStyleBackColor := TRUE
        SELF:ExtractPB:Click += System.EventHandler{ SELF, @ExtractPB_Click() }
        // 
        // ExtractWindow
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{395, 197}
        SELF:Controls:Add(SELF:ExtractPB)
        SELF:Controls:Add(SELF:cancelPB)
        SELF:Controls:Add(SELF:groupBoxOptions)
        SELF:Controls:Add(SELF:ExtractToFolderPB)
        SELF:Controls:Add(SELF:label1)
        SELF:Controls:Add(SELF:comboToPath)
        SELF:MaximizeBox := FALSE
        SELF:MinimizeBox := FALSE
        SELF:Name := "ExtractWindow"
        SELF:Text := "Extract"
        SELF:groupBoxOptions:ResumeLayout(FALSE)
        SELF:groupBoxOptions:PerformLayout()
        SELF:ResumeLayout(FALSE)
        SELF:PerformLayout()
    
    PRIVATE METHOD ExtractToFolderPB_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        RETURN
    
    PRIVATE METHOD ExtractPB_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        Self:DialogResult := DialogResult.Ok
        Self:Close()
        RETURN
    
    PRIVATE METHOD cancelPB_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        Self:Close()
        RETURN
END CLASS
