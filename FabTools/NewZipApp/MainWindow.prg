USING System.Windows.Forms
using FabZip
USING FabZip.WinForms

CLASS MainWindow INHERIT System.Windows.Forms.Form
    
    PRIVATE ribbonSeparator1 AS System.Windows.Forms.RibbonSeparator
    PRIVATE ribbonOrbOptionButton1 AS System.Windows.Forms.RibbonOrbOptionButton
    PRIVATE ribbonSeparator2 AS System.Windows.Forms.RibbonSeparator
    PRIVATE ribbonOrbButton_Close AS System.Windows.Forms.RibbonOrbOptionButton
    PRIVATE ribbonOrbMenuItemNew AS System.Windows.Forms.RibbonOrbMenuItem
    PRIVATE ribbonOrbMenuItemOpen AS System.Windows.Forms.RibbonOrbMenuItem
    PRIVATE ribbonOrbMenuItemSave AS System.Windows.Forms.RibbonOrbMenuItem
    PRIVATE ribbonButtonHelp AS System.Windows.Forms.RibbonButton
    PRIVATE ribbonButtonAdd AS System.Windows.Forms.RibbonButton
    PRIVATE ribbonButtonExtract AS System.Windows.Forms.RibbonButton
    PRIVATE ribbonFabZip AS System.Windows.Forms.Ribbon
    PRIVATE ribbonOrbMenuItemSFX AS System.Windows.Forms.RibbonOrbMenuItem
    PRIVATE ribbonTab_FabZip AS System.Windows.Forms.RibbonTab
    PRIVATE ribbonPanel_Operation AS System.Windows.Forms.RibbonPanel
    PRIVATE ribbonButtonAdd_File AS System.Windows.Forms.RibbonButton
    PRIVATE ribbonButtonAdd_Folder AS System.Windows.Forms.RibbonButton
    PRIVATE ribbonButtonExtract_Selected AS System.Windows.Forms.RibbonButton
    PRIVATE ribbonButtonExtract_All AS System.Windows.Forms.RibbonButton
    PRIVATE panel1 AS System.Windows.Forms.Panel
    PRIVATE colCrypted AS System.Windows.Forms.ColumnHeader
    PRIVATE colName AS System.Windows.Forms.ColumnHeader
    PRIVATE colDate AS System.Windows.Forms.ColumnHeader
    PRIVATE colTime AS System.Windows.Forms.ColumnHeader
    PRIVATE colSize AS System.Windows.Forms.ColumnHeader
    PRIVATE colRatio AS System.Windows.Forms.ColumnHeader
    PRIVATE colPacked AS System.Windows.Forms.ColumnHeader
    PRIVATE colAttributes AS System.Windows.Forms.ColumnHeader
    PRIVATE colPath AS System.Windows.Forms.ColumnHeader
    PRIVATE ZipList AS System.Windows.Forms.ListView
    PRIVATE ZipCtrl AS FabZip.WinForms.FabZipFileCtrl
    PRIVATE components := NULL AS System.ComponentModel.IContainer
    PRIVATE statusStrip1 AS System.Windows.Forms.StatusStrip
    PRIVATE toolStripStatusLabel1 AS System.Windows.Forms.ToolStripStatusLabel
    PRIVATE toolStripProgressBar1 AS System.Windows.Forms.ToolStripProgressBar
    PRIVATE ribbonPanel_MultiPart AS System.Windows.Forms.RibbonPanel
    // 
    PROTECTED ZipFileName AS System.String
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
        LOCAL resources := System.ComponentModel.ComponentResourceManager{typeof(MainWindow)} AS System.ComponentModel.ComponentResourceManager
        SELF:ribbonFabZip := System.Windows.Forms.Ribbon{}
        SELF:ribbonOrbMenuItemNew := System.Windows.Forms.RibbonOrbMenuItem{}
        SELF:ribbonOrbMenuItemOpen := System.Windows.Forms.RibbonOrbMenuItem{}
        SELF:ribbonOrbMenuItemSave := System.Windows.Forms.RibbonOrbMenuItem{}
        SELF:ribbonSeparator2 := System.Windows.Forms.RibbonSeparator{}
        SELF:ribbonOrbMenuItemSFX := System.Windows.Forms.RibbonOrbMenuItem{}
        SELF:ribbonOrbButton_Close := System.Windows.Forms.RibbonOrbOptionButton{}
        SELF:ribbonButtonHelp := System.Windows.Forms.RibbonButton{}
        SELF:ribbonTab_FabZip := System.Windows.Forms.RibbonTab{}
        SELF:ribbonPanel_Operation := System.Windows.Forms.RibbonPanel{}
        SELF:ribbonButtonAdd := System.Windows.Forms.RibbonButton{}
        SELF:ribbonButtonAdd_File := System.Windows.Forms.RibbonButton{}
        SELF:ribbonButtonAdd_Folder := System.Windows.Forms.RibbonButton{}
        SELF:ribbonButtonExtract := System.Windows.Forms.RibbonButton{}
        SELF:ribbonButtonExtract_Selected := System.Windows.Forms.RibbonButton{}
        SELF:ribbonButtonExtract_All := System.Windows.Forms.RibbonButton{}
        SELF:ribbonPanel_MultiPart := System.Windows.Forms.RibbonPanel{}
        SELF:ribbonSeparator1 := System.Windows.Forms.RibbonSeparator{}
        SELF:ribbonOrbOptionButton1 := System.Windows.Forms.RibbonOrbOptionButton{}
        SELF:ZipCtrl := FabZip.WinForms.FabZipFileCtrl{}
        SELF:panel1 := System.Windows.Forms.Panel{}
        SELF:ZipList := System.Windows.Forms.ListView{}
        SELF:colCrypted := System.Windows.Forms.ColumnHeader{}
        SELF:colName := System.Windows.Forms.ColumnHeader{}
        SELF:colDate := System.Windows.Forms.ColumnHeader{}
        SELF:colTime := System.Windows.Forms.ColumnHeader{}
        SELF:colSize := System.Windows.Forms.ColumnHeader{}
        SELF:colRatio := System.Windows.Forms.ColumnHeader{}
        SELF:colPacked := System.Windows.Forms.ColumnHeader{}
        SELF:colAttributes := System.Windows.Forms.ColumnHeader{}
        SELF:colPath := System.Windows.Forms.ColumnHeader{}
        SELF:statusStrip1 := System.Windows.Forms.StatusStrip{}
        SELF:toolStripStatusLabel1 := System.Windows.Forms.ToolStripStatusLabel{}
        SELF:toolStripProgressBar1 := System.Windows.Forms.ToolStripProgressBar{}
        SELF:panel1:SuspendLayout()
        SELF:statusStrip1:SuspendLayout()
        SELF:SuspendLayout()
        // 
        // ribbonFabZip
        // 
        SELF:ribbonFabZip:Font := System.Drawing.Font{"Segoe UI", ((Single) 9)}
        SELF:ribbonFabZip:Location := System.Drawing.Point{0, 0}
        SELF:ribbonFabZip:Minimized := FALSE
        SELF:ribbonFabZip:Name := "ribbonFabZip"
        // 
        // 
        // 
        SELF:ribbonFabZip:OrbDropDown:BorderRoundness := 8
        SELF:ribbonFabZip:OrbDropDown:Location := System.Drawing.Point{0, 0}
        SELF:ribbonFabZip:OrbDropDown:MenuItems:Add(SELF:ribbonOrbMenuItemNew)
        SELF:ribbonFabZip:OrbDropDown:MenuItems:Add(SELF:ribbonOrbMenuItemOpen)
        SELF:ribbonFabZip:OrbDropDown:MenuItems:Add(SELF:ribbonOrbMenuItemSave)
        SELF:ribbonFabZip:OrbDropDown:MenuItems:Add(SELF:ribbonSeparator2)
        SELF:ribbonFabZip:OrbDropDown:MenuItems:Add(SELF:ribbonOrbMenuItemSFX)
        SELF:ribbonFabZip:OrbDropDown:Name := ""
        SELF:ribbonFabZip:OrbDropDown:OptionItems:Add(SELF:ribbonOrbButton_Close)
        SELF:ribbonFabZip:OrbDropDown:Size := System.Drawing.Size{227, 251}
        SELF:ribbonFabZip:OrbDropDown:TabIndex := 0
        SELF:ribbonFabZip:OrbImage := ((System.Drawing.Image)(resources:GetObject("ribbonFabZip.OrbImage")))
        // 
        // 
        // 
        SELF:ribbonFabZip:QuickAcessToolbar:AltKey := NULL
        SELF:ribbonFabZip:QuickAcessToolbar:Image := NULL
        SELF:ribbonFabZip:QuickAcessToolbar:Items:Add(SELF:ribbonButtonHelp)
        SELF:ribbonFabZip:QuickAcessToolbar:Tag := NULL
        SELF:ribbonFabZip:QuickAcessToolbar:Text := NULL
        SELF:ribbonFabZip:QuickAcessToolbar:ToolTip := NULL
        SELF:ribbonFabZip:QuickAcessToolbar:ToolTipImage := NULL
        SELF:ribbonFabZip:QuickAcessToolbar:ToolTipTitle := NULL
        SELF:ribbonFabZip:Size := System.Drawing.Size{704, 138}
        SELF:ribbonFabZip:TabIndex := 0
        SELF:ribbonFabZip:Tabs:Add(SELF:ribbonTab_FabZip)
        SELF:ribbonFabZip:TabSpacing := 6
        SELF:ribbonFabZip:Text := "ribbon1"
        // 
        // ribbonOrbMenuItemNew
        // 
        SELF:ribbonOrbMenuItemNew:AltKey := NULL
        SELF:ribbonOrbMenuItemNew:DropDownArrowDirection := System.Windows.Forms.RibbonArrowDirection.Left
        SELF:ribbonOrbMenuItemNew:DropDownArrowSize := System.Drawing.Size{5, 3}
        SELF:ribbonOrbMenuItemNew:Image := ((System.Drawing.Image)(resources:GetObject("ribbonOrbMenuItemNew.Image")))
        SELF:ribbonOrbMenuItemNew:SmallImage := ((System.Drawing.Image)(resources:GetObject("ribbonOrbMenuItemNew.SmallImage")))
        SELF:ribbonOrbMenuItemNew:Style := System.Windows.Forms.RibbonButtonStyle.Normal
        SELF:ribbonOrbMenuItemNew:Tag := NULL
        SELF:ribbonOrbMenuItemNew:Text := "New"
        SELF:ribbonOrbMenuItemNew:ToolTip := NULL
        SELF:ribbonOrbMenuItemNew:ToolTipImage := NULL
        SELF:ribbonOrbMenuItemNew:ToolTipTitle := NULL
        SELF:ribbonOrbMenuItemNew:Click += System.EventHandler{ SELF, @ribbonOrbMenuItemNew_Click() }
        // 
        // ribbonOrbMenuItemOpen
        // 
        SELF:ribbonOrbMenuItemOpen:AltKey := NULL
        SELF:ribbonOrbMenuItemOpen:DropDownArrowDirection := System.Windows.Forms.RibbonArrowDirection.Left
        SELF:ribbonOrbMenuItemOpen:DropDownArrowSize := System.Drawing.Size{5, 3}
        SELF:ribbonOrbMenuItemOpen:Image := ((System.Drawing.Image)(resources:GetObject("ribbonOrbMenuItemOpen.Image")))
        SELF:ribbonOrbMenuItemOpen:SmallImage := ((System.Drawing.Image)(resources:GetObject("ribbonOrbMenuItemOpen.SmallImage")))
        SELF:ribbonOrbMenuItemOpen:Style := System.Windows.Forms.RibbonButtonStyle.Normal
        SELF:ribbonOrbMenuItemOpen:Tag := NULL
        SELF:ribbonOrbMenuItemOpen:Text := "Open"
        SELF:ribbonOrbMenuItemOpen:ToolTip := NULL
        SELF:ribbonOrbMenuItemOpen:ToolTipImage := NULL
        SELF:ribbonOrbMenuItemOpen:ToolTipTitle := NULL
        SELF:ribbonOrbMenuItemOpen:Click += System.EventHandler{ SELF, @ribbonOrbMenuItemOpen_Click() }
        // 
        // ribbonOrbMenuItemSave
        // 
        SELF:ribbonOrbMenuItemSave:AltKey := NULL
        SELF:ribbonOrbMenuItemSave:DropDownArrowDirection := System.Windows.Forms.RibbonArrowDirection.Left
        SELF:ribbonOrbMenuItemSave:DropDownArrowSize := System.Drawing.Size{5, 3}
        SELF:ribbonOrbMenuItemSave:Image := ((System.Drawing.Image)(resources:GetObject("ribbonOrbMenuItemSave.Image")))
        SELF:ribbonOrbMenuItemSave:SmallImage := ((System.Drawing.Image)(resources:GetObject("ribbonOrbMenuItemSave.SmallImage")))
        SELF:ribbonOrbMenuItemSave:Style := System.Windows.Forms.RibbonButtonStyle.Normal
        SELF:ribbonOrbMenuItemSave:Tag := NULL
        SELF:ribbonOrbMenuItemSave:Text := "Save"
        SELF:ribbonOrbMenuItemSave:ToolTip := NULL
        SELF:ribbonOrbMenuItemSave:ToolTipImage := NULL
        SELF:ribbonOrbMenuItemSave:ToolTipTitle := NULL
        // 
        // ribbonSeparator2
        // 
        SELF:ribbonSeparator2:AltKey := NULL
        SELF:ribbonSeparator2:Image := NULL
        SELF:ribbonSeparator2:Tag := NULL
        SELF:ribbonSeparator2:Text := NULL
        SELF:ribbonSeparator2:ToolTip := NULL
        SELF:ribbonSeparator2:ToolTipImage := NULL
        SELF:ribbonSeparator2:ToolTipTitle := NULL
        // 
        // ribbonOrbMenuItemSFX
        // 
        SELF:ribbonOrbMenuItemSFX:AltKey := NULL
        SELF:ribbonOrbMenuItemSFX:DropDownArrowDirection := System.Windows.Forms.RibbonArrowDirection.Left
        SELF:ribbonOrbMenuItemSFX:DropDownArrowSize := System.Drawing.Size{5, 3}
        SELF:ribbonOrbMenuItemSFX:Image := ((System.Drawing.Image)(resources:GetObject("ribbonOrbMenuItemSFX.Image")))
        SELF:ribbonOrbMenuItemSFX:SmallImage := ((System.Drawing.Image)(resources:GetObject("ribbonOrbMenuItemSFX.SmallImage")))
        SELF:ribbonOrbMenuItemSFX:Style := System.Windows.Forms.RibbonButtonStyle.Normal
        SELF:ribbonOrbMenuItemSFX:Tag := NULL
        SELF:ribbonOrbMenuItemSFX:Text := "Save as SFX"
        SELF:ribbonOrbMenuItemSFX:ToolTip := NULL
        SELF:ribbonOrbMenuItemSFX:ToolTipImage := NULL
        SELF:ribbonOrbMenuItemSFX:ToolTipTitle := NULL
        // 
        // ribbonOrbButton_Close
        // 
        SELF:ribbonOrbButton_Close:AltKey := NULL
        SELF:ribbonOrbButton_Close:DropDownArrowDirection := System.Windows.Forms.RibbonArrowDirection.Down
        SELF:ribbonOrbButton_Close:DropDownArrowSize := System.Drawing.Size{5, 3}
        SELF:ribbonOrbButton_Close:Image := ((System.Drawing.Image)(resources:GetObject("ribbonOrbButton_Close.Image")))
        SELF:ribbonOrbButton_Close:SmallImage := ((System.Drawing.Image)(resources:GetObject("ribbonOrbButton_Close.SmallImage")))
        SELF:ribbonOrbButton_Close:Style := System.Windows.Forms.RibbonButtonStyle.Normal
        SELF:ribbonOrbButton_Close:Tag := NULL
        SELF:ribbonOrbButton_Close:Text := "Close FabZip"
        SELF:ribbonOrbButton_Close:ToolTip := NULL
        SELF:ribbonOrbButton_Close:ToolTipImage := NULL
        SELF:ribbonOrbButton_Close:ToolTipTitle := NULL
        SELF:ribbonOrbButton_Close:Click += System.EventHandler{ SELF, @ribbonOrbButton_Close_Click() }
        // 
        // ribbonButtonHelp
        // 
        SELF:ribbonButtonHelp:AltKey := NULL
        SELF:ribbonButtonHelp:DropDownArrowDirection := System.Windows.Forms.RibbonArrowDirection.Down
        SELF:ribbonButtonHelp:DropDownArrowSize := System.Drawing.Size{5, 3}
        SELF:ribbonButtonHelp:Image := ((System.Drawing.Image)(resources:GetObject("ribbonButtonHelp.Image")))
        SELF:ribbonButtonHelp:MaxSizeMode := System.Windows.Forms.RibbonElementSizeMode.Compact
        SELF:ribbonButtonHelp:SmallImage := ((System.Drawing.Image)(resources:GetObject("ribbonButtonHelp.SmallImage")))
        SELF:ribbonButtonHelp:Style := System.Windows.Forms.RibbonButtonStyle.Normal
        SELF:ribbonButtonHelp:Tag := NULL
        SELF:ribbonButtonHelp:Text := "About..."
        SELF:ribbonButtonHelp:ToolTip := NULL
        SELF:ribbonButtonHelp:ToolTipImage := NULL
        SELF:ribbonButtonHelp:ToolTipTitle := NULL
        // 
        // ribbonTab_FabZip
        // 
        SELF:ribbonTab_FabZip:Panels:Add(SELF:ribbonPanel_Operation)
        SELF:ribbonTab_FabZip:Panels:Add(SELF:ribbonPanel_MultiPart)
        SELF:ribbonTab_FabZip:Tag := NULL
        SELF:ribbonTab_FabZip:Text := "FabZip"
        // 
        // ribbonPanel_Operation
        // 
        SELF:ribbonPanel_Operation:Items:Add(SELF:ribbonButtonAdd)
        SELF:ribbonPanel_Operation:Items:Add(SELF:ribbonButtonExtract)
        SELF:ribbonPanel_Operation:Tag := NULL
        SELF:ribbonPanel_Operation:Text := "Zip Operation"
        // 
        // ribbonButtonAdd
        // 
        SELF:ribbonButtonAdd:AltKey := NULL
        SELF:ribbonButtonAdd:DropDownArrowDirection := System.Windows.Forms.RibbonArrowDirection.Down
        SELF:ribbonButtonAdd:DropDownArrowSize := System.Drawing.Size{5, 3}
        SELF:ribbonButtonAdd:DropDownItems:Add(SELF:ribbonButtonAdd_File)
        SELF:ribbonButtonAdd:DropDownItems:Add(SELF:ribbonButtonAdd_Folder)
        SELF:ribbonButtonAdd:Image := ((System.Drawing.Image)(resources:GetObject("ribbonButtonAdd.Image")))
        SELF:ribbonButtonAdd:SmallImage := ((System.Drawing.Image)(resources:GetObject("ribbonButtonAdd.SmallImage")))
        SELF:ribbonButtonAdd:Style := System.Windows.Forms.RibbonButtonStyle.DropDown
        SELF:ribbonButtonAdd:Tag := NULL
        SELF:ribbonButtonAdd:Text := "Add"
        SELF:ribbonButtonAdd:ToolTip := NULL
        SELF:ribbonButtonAdd:ToolTipImage := NULL
        SELF:ribbonButtonAdd:ToolTipTitle := NULL
        // 
        // ribbonButtonAdd_File
        // 
        SELF:ribbonButtonAdd_File:AltKey := NULL
        SELF:ribbonButtonAdd_File:DropDownArrowDirection := System.Windows.Forms.RibbonArrowDirection.Left
        SELF:ribbonButtonAdd_File:DropDownArrowSize := System.Drawing.Size{5, 3}
        SELF:ribbonButtonAdd_File:Image := ((System.Drawing.Image)(resources:GetObject("ribbonButtonAdd_File.Image")))
        SELF:ribbonButtonAdd_File:SmallImage := ((System.Drawing.Image)(resources:GetObject("ribbonButtonAdd_File.SmallImage")))
        SELF:ribbonButtonAdd_File:Style := System.Windows.Forms.RibbonButtonStyle.Normal
        SELF:ribbonButtonAdd_File:Tag := NULL
        SELF:ribbonButtonAdd_File:Text := "File"
        SELF:ribbonButtonAdd_File:ToolTip := NULL
        SELF:ribbonButtonAdd_File:ToolTipImage := NULL
        SELF:ribbonButtonAdd_File:ToolTipTitle := NULL
        // 
        // ribbonButtonAdd_Folder
        // 
        SELF:ribbonButtonAdd_Folder:AltKey := NULL
        SELF:ribbonButtonAdd_Folder:DropDownArrowDirection := System.Windows.Forms.RibbonArrowDirection.Left
        SELF:ribbonButtonAdd_Folder:DropDownArrowSize := System.Drawing.Size{5, 3}
        SELF:ribbonButtonAdd_Folder:Image := ((System.Drawing.Image)(resources:GetObject("ribbonButtonAdd_Folder.Image")))
        SELF:ribbonButtonAdd_Folder:SmallImage := ((System.Drawing.Image)(resources:GetObject("ribbonButtonAdd_Folder.SmallImage")))
        SELF:ribbonButtonAdd_Folder:Style := System.Windows.Forms.RibbonButtonStyle.Normal
        SELF:ribbonButtonAdd_Folder:Tag := NULL
        SELF:ribbonButtonAdd_Folder:Text := "Folder"
        SELF:ribbonButtonAdd_Folder:ToolTip := NULL
        SELF:ribbonButtonAdd_Folder:ToolTipImage := NULL
        SELF:ribbonButtonAdd_Folder:ToolTipTitle := NULL
        // 
        // ribbonButtonExtract
        // 
        SELF:ribbonButtonExtract:AltKey := NULL
        SELF:ribbonButtonExtract:DropDownArrowDirection := System.Windows.Forms.RibbonArrowDirection.Down
        SELF:ribbonButtonExtract:DropDownArrowSize := System.Drawing.Size{5, 3}
        SELF:ribbonButtonExtract:DropDownItems:Add(SELF:ribbonButtonExtract_Selected)
        SELF:ribbonButtonExtract:DropDownItems:Add(SELF:ribbonButtonExtract_All)
        SELF:ribbonButtonExtract:Image := ((System.Drawing.Image)(resources:GetObject("ribbonButtonExtract.Image")))
        SELF:ribbonButtonExtract:SmallImage := ((System.Drawing.Image)(resources:GetObject("ribbonButtonExtract.SmallImage")))
        SELF:ribbonButtonExtract:Style := System.Windows.Forms.RibbonButtonStyle.DropDown
        SELF:ribbonButtonExtract:Tag := NULL
        SELF:ribbonButtonExtract:Text := "Extract"
        SELF:ribbonButtonExtract:ToolTip := NULL
        SELF:ribbonButtonExtract:ToolTipImage := NULL
        SELF:ribbonButtonExtract:ToolTipTitle := NULL
        // 
        // ribbonButtonExtract_Selected
        // 
        SELF:ribbonButtonExtract_Selected:AltKey := NULL
        SELF:ribbonButtonExtract_Selected:DropDownArrowDirection := System.Windows.Forms.RibbonArrowDirection.Left
        SELF:ribbonButtonExtract_Selected:DropDownArrowSize := System.Drawing.Size{5, 3}
        SELF:ribbonButtonExtract_Selected:Image := ((System.Drawing.Image)(resources:GetObject("ribbonButtonExtract_Selected.Image")))
        SELF:ribbonButtonExtract_Selected:SmallImage := ((System.Drawing.Image)(resources:GetObject("ribbonButtonExtract_Selected.SmallImage")))
        SELF:ribbonButtonExtract_Selected:Style := System.Windows.Forms.RibbonButtonStyle.Normal
        SELF:ribbonButtonExtract_Selected:Tag := NULL
        SELF:ribbonButtonExtract_Selected:Text := "Selected"
        SELF:ribbonButtonExtract_Selected:ToolTip := NULL
        SELF:ribbonButtonExtract_Selected:ToolTipImage := NULL
        SELF:ribbonButtonExtract_Selected:ToolTipTitle := NULL
        SELF:ribbonButtonExtract_Selected:Click += System.EventHandler{ SELF, @ribbonButtonExtract_Selected_Click() }
        // 
        // ribbonButtonExtract_All
        // 
        SELF:ribbonButtonExtract_All:AltKey := NULL
        SELF:ribbonButtonExtract_All:DropDownArrowDirection := System.Windows.Forms.RibbonArrowDirection.Left
        SELF:ribbonButtonExtract_All:DropDownArrowSize := System.Drawing.Size{5, 3}
        SELF:ribbonButtonExtract_All:Image := ((System.Drawing.Image)(resources:GetObject("ribbonButtonExtract_All.Image")))
        SELF:ribbonButtonExtract_All:SmallImage := ((System.Drawing.Image)(resources:GetObject("ribbonButtonExtract_All.SmallImage")))
        SELF:ribbonButtonExtract_All:Style := System.Windows.Forms.RibbonButtonStyle.Normal
        SELF:ribbonButtonExtract_All:Tag := NULL
        SELF:ribbonButtonExtract_All:Text := "All"
        SELF:ribbonButtonExtract_All:ToolTip := NULL
        SELF:ribbonButtonExtract_All:ToolTipImage := NULL
        SELF:ribbonButtonExtract_All:ToolTipTitle := NULL
        // 
        // ribbonPanel_MultiPart
        // 
        SELF:ribbonPanel_MultiPart:Tag := NULL
        SELF:ribbonPanel_MultiPart:Text := "MultiPart"
        // 
        // ribbonSeparator1
        // 
        SELF:ribbonSeparator1:AltKey := NULL
        SELF:ribbonSeparator1:Image := NULL
        SELF:ribbonSeparator1:Tag := NULL
        SELF:ribbonSeparator1:Text := NULL
        SELF:ribbonSeparator1:ToolTip := NULL
        SELF:ribbonSeparator1:ToolTipImage := NULL
        SELF:ribbonSeparator1:ToolTipTitle := NULL
        // 
        // ribbonOrbOptionButton1
        // 
        SELF:ribbonOrbOptionButton1:AltKey := NULL
        SELF:ribbonOrbOptionButton1:DropDownArrowDirection := System.Windows.Forms.RibbonArrowDirection.Down
        SELF:ribbonOrbOptionButton1:DropDownArrowSize := System.Drawing.Size{5, 3}
        SELF:ribbonOrbOptionButton1:Image := ((System.Drawing.Image)(resources:GetObject("ribbonOrbOptionButton1.Image")))
        SELF:ribbonOrbOptionButton1:SmallImage := ((System.Drawing.Image)(resources:GetObject("ribbonOrbOptionButton1.SmallImage")))
        SELF:ribbonOrbOptionButton1:Style := System.Windows.Forms.RibbonButtonStyle.Normal
        SELF:ribbonOrbOptionButton1:Tag := NULL
        SELF:ribbonOrbOptionButton1:Text := "ribbonOrbOptionButton1"
        SELF:ribbonOrbOptionButton1:ToolTip := NULL
        SELF:ribbonOrbOptionButton1:ToolTipImage := NULL
        SELF:ribbonOrbOptionButton1:ToolTipTitle := NULL
        // 
        // ZipCtrl
        // 
        SELF:ZipCtrl:Location := System.Drawing.Point{342, 296}
        SELF:ZipCtrl:Name := "ZipCtrl"
        SELF:ZipCtrl:Size := System.Drawing.Size{81, 67}
        SELF:ZipCtrl:TabIndex := 1
        // 
        // panel1
        // 
        SELF:panel1:Controls:Add(SELF:ZipList)
        SELF:panel1:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:panel1:Location := System.Drawing.Point{0, 138}
        SELF:panel1:Name := "panel1"
        SELF:panel1:Size := System.Drawing.Size{704, 310}
        SELF:panel1:TabIndex := 2
        // 
        // ZipList
        // 
        SELF:ZipList:Columns:AddRange(<System.Windows.Forms.ColumnHeader>{ SELF:colCrypted, SELF:colName, SELF:colDate, SELF:colTime, SELF:colSize, SELF:colRatio, SELF:colPacked, SELF:colAttributes, SELF:colPath })
        SELF:ZipList:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:ZipList:FullRowSelect := TRUE
        SELF:ZipList:Location := System.Drawing.Point{0, 0}
        SELF:ZipList:Name := "ZipList"
        SELF:ZipList:Size := System.Drawing.Size{704, 310}
        SELF:ZipList:TabIndex := 0
        SELF:ZipList:UseCompatibleStateImageBehavior := FALSE
        SELF:ZipList:View := System.Windows.Forms.View.Details
        // 
        // colCrypted
        // 
        SELF:colCrypted:Text := "Crypted"
        SELF:colCrypted:Width := 10
        // 
        // colName
        // 
        SELF:colName:Text := "File Name"
        SELF:colName:Width := 150
        // 
        // colDate
        // 
        SELF:colDate:Text := "Date"
        SELF:colDate:Width := 70
        // 
        // colTime
        // 
        SELF:colTime:Text := "Time"
        SELF:colTime:Width := 68
        // 
        // colSize
        // 
        SELF:colSize:Text := "Size"
        SELF:colSize:TextAlign := System.Windows.Forms.HorizontalAlignment.Right
        // 
        // colRatio
        // 
        SELF:colRatio:Text := "Ratio"
        SELF:colRatio:TextAlign := System.Windows.Forms.HorizontalAlignment.Right
        SELF:colRatio:Width := 40
        // 
        // colPacked
        // 
        SELF:colPacked:Text := "Packed"
        SELF:colPacked:TextAlign := System.Windows.Forms.HorizontalAlignment.Right
        // 
        // colAttributes
        // 
        SELF:colAttributes:Text := "Attributes"
        SELF:colAttributes:Width := 30
        // 
        // colPath
        // 
        SELF:colPath:Text := "Path"
        SELF:colPath:Width := 200
        // 
        // statusStrip1
        // 
        SELF:statusStrip1:Items:AddRange(<System.Windows.Forms.ToolStripItem>{ SELF:toolStripStatusLabel1, SELF:toolStripProgressBar1 })
        SELF:statusStrip1:Location := System.Drawing.Point{0, 426}
        SELF:statusStrip1:Name := "statusStrip1"
        SELF:statusStrip1:Size := System.Drawing.Size{704, 22}
        SELF:statusStrip1:TabIndex := 4
        SELF:statusStrip1:Text := "statusStrip1"
        // 
        // toolStripStatusLabel1
        // 
        SELF:toolStripStatusLabel1:AutoSize := FALSE
        SELF:toolStripStatusLabel1:Name := "toolStripStatusLabel1"
        SELF:toolStripStatusLabel1:Size := System.Drawing.Size{200, 17}
        SELF:toolStripStatusLabel1:TextAlign := System.Drawing.ContentAlignment.MiddleLeft
        // 
        // toolStripProgressBar1
        // 
        SELF:toolStripProgressBar1:AutoSize := FALSE
        SELF:toolStripProgressBar1:MarqueeAnimationSpeed := 10
        SELF:toolStripProgressBar1:Name := "toolStripProgressBar1"
        SELF:toolStripProgressBar1:Size := System.Drawing.Size{200, 16}
        // 
        // MainWindow
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{704, 448}
        SELF:Controls:Add(SELF:statusStrip1)
        SELF:Controls:Add(SELF:panel1)
        SELF:Controls:Add(SELF:ZipCtrl)
        SELF:Controls:Add(SELF:ribbonFabZip)
        SELF:Name := "MainWindow"
        SELF:Text := "XSharp.Net Zip"
        SELF:panel1:ResumeLayout(FALSE)
        SELF:statusStrip1:ResumeLayout(FALSE)
        SELF:statusStrip1:PerformLayout()
        SELF:ResumeLayout(FALSE)
        SELF:PerformLayout()
    
    PRIVATE METHOD ribbonOrbButton_Close_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:Close()
        RETURN
    PRIVATE METHOD ribbonOrbMenuItemOpen_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	    LOCAL oOD	AS	OpenFileDialog
	    //
	    oOD := OpenFileDialog{ }
	    oOD:Filter := "Archives|*.Zip|Archives and Exe Files|*.Zip;*.Exe|All Files|*.*" 
	    oOD:FilterIndex := 1
	    oOD:Title := "Choose a Zip File"
	    IF ( oOD:ShowDialog() != DialogResult.OK )
	        RETURN
	    ENDIF
	    //
	    IF !Empty( oOD:FileName )
		    SELF:ZipFileName := oOD:FileName
	    ENDIF
	    //
	    IF File( SELF:ZipFileName )
		    //
		    // Clear ListView
		    SELF:ZipList:Items:Clear()
		    //
		    SELF:toolStripProgressBar1:Style := System.Windows.Forms.ProgressBarStyle.Marquee
		    SELF:ZipCtrl:ZipFile:FileName := SELF:ZipFileName
		    SELF:toolStripProgressBar1:Style := System.Windows.Forms.ProgressBarStyle.Blocks
		    // This is automatically done when setting the name
		    //	SELF:oDCZip_Control:FileZip:UpdateContents()
	    ENDIF	    
        RETURN
        
    PRIVATE METHOD ribbonOrbMenuItemNew_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        RETURN

    VIRTUAL METHOD OnFabZipDirUpdate( Ctrl AS System.Object ) AS System.Void
	    LOCAL oItem			AS	ListViewItem
	    LOCAL cTmp			AS	STRING
	    LOCAL oCtrl         as  FabZipFileCtrl
    //	LOCAL oFS			AS	FileSpec
	    // We come here due to FabZipFile creation, we are in the Init() of the Window
	    IF ( SELF:ZipList == NULL_OBJECT )
		    return 
	    ENDIF
	    //
	    oCtrl := (FabZipFileCtrl)Ctrl
	    // Clear ListView
	    SELF:ZipList:Items:Clear()
	    // Update ListView
		FOREACH oZDir AS FabZipDirEntry IN oCtrl:ZipFile:Contents
		    // Zip Dir Entry
		    // One Line
		    oItem := ListViewItem{}
		    // Convert FileName from Unix to DOS
		    cTmp := StrTran( oZDir:FileName, "/", "\" )
		    // FileName
		    oItem:SubItems:Add( FabExtractFileName( cTmp ) + FabExtractFileExt( cTmp ) )
		    // File Date
		    oItem:SubItems:Add( oZDir:FileDate:ToString() )
		    // File Time
		    oItem:SubItems:Add( oZDir:FileTime:ToString() )
		    // File Size
		    oItem:SubItems:Add( oZDir:UnCompressedSize:ToString() )
		    // Ratio
		    oItem:SubItems:Add( NTrim( oZDir:Ratio ) + "%" )
		    // File Packed Size
		    oItem:SubItems:Add( oZDir:CompressedSize:ToString() )
		    // Flag
		    IF oZDir:Crypted
			    oItem:Text := "*"
		    ELSE
			    oItem:Text := " "
		    ENDIF
		    // Files Attributes
		    oItem:SubItems:Add( oZDir:Attributes )
		    // File¨Path
    		oItem:SubItems:Add( FabExtractFilePath( cTmp ) )
    		// Set the real name of the file in the Tag
    		oItem:Tag := oZDir:FileName
		    // Add the line
		    Self:ZipList:Items:Add( oItem )
	    NEXT
    return	

    VIRTUAL METHOD OnFabZipProgress( oCtrl as object, symEvent as FabZipEvent, cFile as string, nSize as int64 ) AS VOID
	    IF ( symEvent == FabZipEvent.NewEntry )
		    // Convert Unix-style to Dos separator
		    cFile := StrTran( cFile, "/", "\" )
		    Self:toolStripStatusLabel1:Text := cFile
		    //
		    //SELF:oDCFProcess:TextValue := cFile
		    //SELF:oDCExtractBar:Range := Range{ 1, 100 }
		    //SELF:oDCExtractBar:UnitSize := 1
		    //SELF:oDCExtractBar:Position := 1
		    //
		    //SELF:nCurrentSize := (int)nSize
		    //SELF:nCurrentPos := 0
		    //
		    //SELF:nCurrentFile := SELF:nCurrentFile + 1
		    //SELF:oDCTotalFilesBar:Position := FabGetPercent( SELF:nCurrentFile, SELF:nMaxFiles )
		    //
	    //ELSEIF ( symEvent == FabZipEvent.UpdateEntry )
		    // nSize gives now the bytes processed since the last call.
		    //SELF:nCurrentPos := SELF:nCurrentPos + (int)nSize
		    //SELF:oDCExtractBar:Position := FabGetPercent( SELF:nCurrentPos, SELF:nCurrentSize )
		    //
		    //SELF:nCurrMaxSize := SELF:nCurrMaxSize + (int)nSize
		    //SELF:oDCTotalSizeBar:Position := FabGetPercent( SELF:nCurrMaxSize, SELF:nMaxSize )
		    //
	    ELSEIF ( symEvent == FabZipEvent.EndEntry )
		    //SELF:oDCFProcess:TextValue := ""
		    //SELF:oDCExtractBar:Range := Range{ 1, 100 }
		    //SELF:oDCExtractBar:UnitSize := 1
		    //SELF:oDCExtractBar:Position := 1
		    Self:toolStripStatusLabel1:Text := ""
	    //ELSEIF ( symEvent == FabZipEvent.TotalFiles )
		    //SELF:oDCTotalFilesBar:Range := Range{ 1, 100 }
		    //SELF:oDCTotalFilesBar:UnitSize := 1
		    //SELF:oDCTotalFilesBar:Position := 1
		    //SELF:nMaxFiles := (int)nSize
		    //SELF:nCurrentFile := 0
	    //ELSEIF ( symEvent == FabZipEvent.TotalSize )
		    //SELF:oDCTotalSizeBar:Range := Range{ 1, 100 }
		    //SELF:oDCTotalSizeBar:UnitSize := 1
		    //SELF:oDCTotalSizeBar:Position := 1
		    //SELF:nMaxSize := (int)nSize
		    //SELF:nCurrMaxSize := 0
	    ENDIF
	    //
    RETURN	
        
    PRIVATE METHOD ribbonButtonExtract_Selected_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        // Extract Selected
        Local ToExtract AS ListView.SelectedListViewItemCollection
        Local oDlg as ExtractWindow
        local cPath as string
        local Cpt as int
        local oItem as ListViewItem
        local cFile as string
        //
        ToExtract := SELF:ZipList:SelectedItems
        //
        IF ( ToExtract:Count == 0 )
            return 
        endif
        //
        oDlg := ExtractWindow{}
        if ( oDlg:ShowDialog() != DialogResult.Ok )
            return
        endif
        //
        cPath := oDlg:comboToPath:Text
        // Be sure to set the right style for the ProgressBar
        SELF:toolStripProgressBar1:Style := System.Windows.Forms.ProgressBarStyle.Blocks
        Self:toolStripProgressBar1:Maximum := ToExtract:Count
        //
        Self:ZipCtrl:ZipFile:ExtractDir := cPath
        //
        FOR Cpt := 0 TO ToExtract:Count-1
            oItem := ToExtract[ Cpt ]
            cFile := oItem:Tag:ToString()
            Self:ZipCtrl:ZipFile:FilesArg:Add( cFile )
        NEXT
        // Now, Extract
        Self:ZipCtrl:ZipFile:Extract()
        //
        RETURN

END CLASS
