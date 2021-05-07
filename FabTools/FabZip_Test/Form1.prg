
USING System.Windows.Forms
Using Ionic.Zip


USING FabZip
USING FabZip.WinForms

CLASS Form1 INHERIT System.Windows.Forms.Form
    PRIVATE buttonOpen AS System.Windows.Forms.Button
    PRIVATE listZipFile AS System.Windows.Forms.ListView
    PRIVATE columnFileName AS System.Windows.Forms.ColumnHeader
    PRIVATE components := NULL AS System.ComponentModel.IContainer
    PRIVATE columnTime AS System.Windows.Forms.ColumnHeader
    PRIVATE columnDate AS System.Windows.Forms.ColumnHeader
    PRIVATE buttonExtract AS System.Windows.Forms.Button
    PRIVATE buttonAdd AS System.Windows.Forms.Button
    PRIVATE buttonCreate AS System.Windows.Forms.Button
    PRIVATE ZipCtrl1 AS FabZip.WinForms.FabZipFileCtrl
    PRIVATE groupBox1 AS System.Windows.Forms.GroupBox
    PRIVATE txtPassword AS System.Windows.Forms.TextBox
    PRIVATE checkAES AS System.Windows.Forms.CheckBox
    PRIVATE progressShow AS System.Windows.Forms.ProgressBar
    CONSTRUCTOR()
        SUPER()
        SELF:InitializeComponent()
        //
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
        SELF:buttonOpen := System.Windows.Forms.Button{}
        SELF:listZipFile := System.Windows.Forms.ListView{}
        SELF:columnFileName := System.Windows.Forms.ColumnHeader{}
        SELF:columnTime := System.Windows.Forms.ColumnHeader{}
        SELF:columnDate := System.Windows.Forms.ColumnHeader{}
        SELF:buttonExtract := System.Windows.Forms.Button{}
        SELF:buttonAdd := System.Windows.Forms.Button{}
        SELF:buttonCreate := System.Windows.Forms.Button{}
        SELF:progressShow := System.Windows.Forms.ProgressBar{}
        SELF:ZipCtrl1 := FabZip.WinForms.FabZipFileCtrl{}
        SELF:groupBox1 := System.Windows.Forms.GroupBox{}
        SELF:txtPassword := System.Windows.Forms.TextBox{}
        SELF:checkAES := System.Windows.Forms.CheckBox{}
        SELF:groupBox1:SuspendLayout()
        SELF:SuspendLayout()
        // 
        // buttonOpen
        // 
        SELF:buttonOpen:Location := System.Drawing.Point{12, 12}
        SELF:buttonOpen:Name := "buttonOpen"
        SELF:buttonOpen:Size := System.Drawing.Size{75, 23}
        SELF:buttonOpen:TabIndex := 0
        SELF:buttonOpen:Text := "Open"
        SELF:buttonOpen:UseVisualStyleBackColor := TRUE
        SELF:buttonOpen:Click += System.EventHandler{ SELF, @buttonOpen_Click() }
        // 
        // listZipFile
        // 
        SELF:listZipFile:Columns:AddRange(<System.Windows.Forms.ColumnHeader>{ SELF:columnFileName, SELF:columnTime, SELF:columnDate })
        SELF:listZipFile:FullRowSelect := TRUE
        SELF:listZipFile:Location := System.Drawing.Point{143, 12}
        SELF:listZipFile:Name := "listZipFile"
        SELF:listZipFile:Size := System.Drawing.Size{307, 236}
        SELF:listZipFile:TabIndex := 1
        SELF:listZipFile:UseCompatibleStateImageBehavior := FALSE
        SELF:listZipFile:View := System.Windows.Forms.View.Details
        SELF:listZipFile:SelectedIndexChanged += System.EventHandler{ SELF, @listZipFile_SelectedIndexChanged() }
        // 
        // columnFileName
        // 
        SELF:columnFileName:Text := "File Name"
        SELF:columnFileName:Width := 120
        // 
        // columnTime
        // 
        SELF:columnTime:Text := "Time"
        // 
        // columnDate
        // 
        SELF:columnDate:Text := "Date"
        // 
        // buttonExtract
        // 
        SELF:buttonExtract:Enabled := FALSE
        SELF:buttonExtract:Location := System.Drawing.Point{12, 116}
        SELF:buttonExtract:Name := "buttonExtract"
        SELF:buttonExtract:Size := System.Drawing.Size{75, 23}
        SELF:buttonExtract:TabIndex := 2
        SELF:buttonExtract:Text := "Extract"
        SELF:buttonExtract:UseVisualStyleBackColor := TRUE
        SELF:buttonExtract:Click += System.EventHandler{ SELF, @buttonExtract_Click() }
        // 
        // buttonAdd
        // 
        SELF:buttonAdd:Location := System.Drawing.Point{12, 87}
        SELF:buttonAdd:Name := "buttonAdd"
        SELF:buttonAdd:Size := System.Drawing.Size{75, 23}
        SELF:buttonAdd:TabIndex := 3
        SELF:buttonAdd:Text := "Add"
        SELF:buttonAdd:UseVisualStyleBackColor := TRUE
        SELF:buttonAdd:Click += System.EventHandler{ SELF, @buttonAdd_Click() }
        // 
        // buttonCreate
        // 
        SELF:buttonCreate:Location := System.Drawing.Point{12, 41}
        SELF:buttonCreate:Name := "buttonCreate"
        SELF:buttonCreate:Size := System.Drawing.Size{75, 23}
        SELF:buttonCreate:TabIndex := 4
        SELF:buttonCreate:Text := "Create"
        SELF:buttonCreate:UseVisualStyleBackColor := TRUE
        SELF:buttonCreate:Click += System.EventHandler{ SELF, @buttonCreate_Click() }
        // 
        // progressShow
        // 
        SELF:progressShow:Location := System.Drawing.Point{143, 254}
        SELF:progressShow:Name := "progressShow"
        SELF:progressShow:Size := System.Drawing.Size{307, 23}
        SELF:progressShow:TabIndex := 5
        // 
        // ZipCtrl1
        // 
        SELF:ZipCtrl1:Location := System.Drawing.Point{12, 219}
        SELF:ZipCtrl1:Name := "ZipCtrl1"
        SELF:ZipCtrl1:Size := System.Drawing.Size{49, 48}
        SELF:ZipCtrl1:TabIndex := 6
        // 
        // groupBox1
        // 
        SELF:groupBox1:Controls:Add(SELF:txtPassword)
        SELF:groupBox1:Controls:Add(SELF:checkAES)
        SELF:groupBox1:Location := System.Drawing.Point{12, 148}
        SELF:groupBox1:Name := "groupBox1"
        SELF:groupBox1:Size := System.Drawing.Size{125, 73}
        SELF:groupBox1:TabIndex := 7
        SELF:groupBox1:TabStop := FALSE
        SELF:groupBox1:Text := "Password"
        // 
        // txtPassword
        // 
        SELF:txtPassword:Location := System.Drawing.Point{6, 22}
        SELF:txtPassword:Name := "txtPassword"
        SELF:txtPassword:Size := System.Drawing.Size{113, 20}
        SELF:txtPassword:TabIndex := 1
        // 
        // checkAES
        // 
        SELF:checkAES:AutoSize := TRUE
        SELF:checkAES:Location := System.Drawing.Point{6, 48}
        SELF:checkAES:Name := "checkAES"
        SELF:checkAES:Size := System.Drawing.Size{69, 17}
        SELF:checkAES:TabIndex := 0
        SELF:checkAES:Text := "Use AES"
        SELF:checkAES:UseVisualStyleBackColor := TRUE
        // 
        // Form1
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{462, 279}
        SELF:Controls:Add(SELF:groupBox1)
        SELF:Controls:Add(SELF:ZipCtrl1)
        SELF:Controls:Add(SELF:progressShow)
        SELF:Controls:Add(SELF:buttonCreate)
        SELF:Controls:Add(SELF:buttonAdd)
        SELF:Controls:Add(SELF:buttonExtract)
        SELF:Controls:Add(SELF:listZipFile)
        SELF:Controls:Add(SELF:buttonOpen)
        SELF:Name := "Form1"
        SELF:Text := "DotNetZip Test App"
        SELF:groupBox1:ResumeLayout(FALSE)
        SELF:groupBox1:PerformLayout()
    SELF:ResumeLayout(FALSE)
    PRIVATE METHOD buttonOpen_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        LOCAL oDlg AS OpenFileDialog
        LOCAL cFile AS STRING
        //
        oDlg := OpenFileDialog{ }
        oDlg:Filter := "Archives|*.Zip|Archives and Exe Files|*.Zip;*.Exe|All Files|*.*" 
        oDlg:FilterIndex := 1
        oDlg:CheckFileExists := TRUE
        IF ( oDlg:ShowDialog() == DialogResult.ok )
            cFile := oDlg:FileName
            //
            SELF:ZipCtrl1:ZipFile:FileName := cFile
            SELF:Text := "DotNetZip Test App - " + cFile
            //
            SELF:UpdateList()
        ENDIF 
        RETURN
    
    PRIVATE METHOD UpdateList() AS System.Void
        LOCAL Cpt AS INT
        LOCAL Max AS INT
        LOCAL oTmp AS FabZipDirEntry
        LOCAL oLVI AS ListViewItem
        //
        SELF:listZipFile:Items:Clear()
        //
        Max := SELF:ZipCtrl1:ZipFile:Contents:Count
        FOR Cpt := 1 TO Max
            oTmp := (FabZipDirEntry)SELF:ZipCtrl1:ZipFile:Contents[ Cpt -1]
            //
            oLVI := ListViewItem{ oTmp:FileName }
            oLVI:SubItems:Add( oTmp:FileTime )
            oLVI:SubItems:Add( DToc(oTmp:FileDate ))
            //
            SELF:listZipFile:Items:Add( oLVI )
            
        NEXT
        RETURN
    
    PRIVATE METHOD buttonExtract_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        LOCAL oLVI AS ListViewItem
        LOCAL oFolderDlg AS System.Windows.Forms.FolderBrowserDialog
        LOCAL cExtractHere AS STRING
        LOCAL i AS INT
        //
        oFolderDlg := FolderBrowserDialog{}
        oFolderDlg:ShowNewFolderButton := FALSE
        oFolderDlg:Description:="Please select a folder"
        oFolderDlg:RootFolder:=System.Environment.SpecialFolder.DesktopDirectory
        IF ( oFolderDlg:ShowDialog()== DialogResult.OK )
            cExtractHere := oFolderDlg:SelectedPath
            //
            FOR i := 1 TO SELF:listZipFile:SelectedItems:Count  
                oLVI := SELF:listZipFile:SelectedItems[ i-1]
                //
                SELF:ZipCtrl1:ZipFile:FilesArg:Add( oLVI:Text )
            NEXT
            SELF:ZipCtrl1:ZipFile:ExtractDir := cExtractHere
            SELF:ZipCtrl1:ZipFile:ExtractOptions:Overwrite := TRUE
            SELF:progressShow:Value := 0        
            // DotNetZIp will retrieve the right Encryption used if any
            // BUT, in that case YOU must give the "right" password (at least)
            IF ( SELF:txtPassword:Text:Length > 0 )
                SELF:ZipCtrl1:ZipFile:Password := SELF:txtPassword:Text
                
            ENDIF    
            SELF:ZipCtrl1:ZipFile:Extract()
            //
        ENDIF
        RETURN  
    
    PRIVATE METHOD buttonAdd_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        LOCAL oDlg AS OpenFileDialog
        LOCAL cFile AS STRING
        LOCAL aFiles AS STRING[]
        LOCAL i AS INT
        //
        oDlg := OpenFileDialog{ }
        oDlg:Title := "Choose Files to Add"
        oDlg:Multiselect := TRUE
        oDlg:CheckFileExists := TRUE
        IF ( oDlg:ShowDialog() == DialogResult.ok )
            //
            aFiles := oDlg:FileNames
            //
            FOR i := 1 TO aFiles:Length
                cFile := aFiles[ i ]
                //
                SELF:ZipCtrl1:ZipFile:FilesArg:Add( cFile )
            NEXT
            //
            SELF:progressShow:Value := 0
            //
            IF ( SELF:txtPassword:Text:Length > 0 )
                SELF:ZipCtrl1:ZipFile:Password := SELF:txtPassword:Text
                IF ( SELF:checkAES:Checked )
                    SELF:ZipCtrl1:ZipFile:Encryption := Ionic.Zip.EncryptionAlgorithm.WinZipAes256
                ENDIF
            ENDIF
            SELF:ZipCtrl1:ZipFile:Add()
            //
            SELF:UpdateList()           
        ENDIF     
        RETURN
    
    PRIVATE METHOD listZipFile_SelectedIndexChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:buttonExtract:Enabled := TRUE
        RETURN
    
    PRIVATE METHOD buttonCreate_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        LOCAL oDlg AS SaveFileDialog
        LOCAL cFile AS STRING
        //
        oDlg := SaveFileDialog{ }
        oDlg:DefaultExt := ".zip"
        IF ( oDlg:ShowDialog() == DialogResult.ok )
            cFile := oDlg:FileName
            //
            SELF:ZipCtrl1:ZipFile:FileName := cFile
            SELF:Text := "DotNetZip Test App - " + cFile
            //
            SELF:UpdateList()
        ENDIF 
        
        RETURN
        /*
        VIRTUAL METHOD ExtractProgress( sender AS System.Object, e AS ExtractProgressEventArgs ) AS System.Void
        Self:progressShow:Value := ( e:EntriesExtracted*100 / e:EntriesTotal )
        //
        Return
        VIRTUAL METHOD AddProgress( sender AS System.Object, e AS SaveProgressEventArgs ) AS System.Void
        Self:progressShow:Value := ( e:EntriesSaved*100 / e:EntriesTotal )
        //
        Return    
        */
        // Console.WriteLine("{0} ({1}/{2})", e.NameOfLatestEntry, e.EntriesExtractd, e.EntriesTotal);
    
    METHOD OnFabZipProgress( sender AS System.Object, symEvent AS FabZipEvent, cFile AS STRING, nSize AS INT64 ) AS VOID
        // Put your progress code here
        RETURN 
        
        
END CLASS
