USING System.Windows.Forms
USING FabZip
USING FabZip.WinForms

PUBLIC CLASS MainWindow	;
	INHERIT System.Windows.Forms.Form
    
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
    PRIVATE components	:=	NULL AS System.ComponentModel.IContainer
    PRIVATE statusStrip1 AS System.Windows.Forms.StatusStrip
    PRIVATE toolStripStatusLabel1 AS System.Windows.Forms.ToolStripStatusLabel
    PRIVATE toolStripProgressBar1 AS System.Windows.Forms.ToolStripProgressBar
    PRIVATE ribbonPanel_MultiPart AS System.Windows.Forms.RibbonPanel
    // 
    PROTECTED ZipFileName AS STRING
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
    PRIVATE METHOD InitializeComponent() AS VOID STRICT
		LOCAL resources	:=	System.ComponentModel.ComponentResourceManager{typeof(MainWindow)} AS System.ComponentModel.ComponentResourceManager
		SELF:ribbonFabZip	:=	System.Windows.Forms.Ribbon{}
		SELF:ribbonOrbMenuItemNew	:=	System.Windows.Forms.RibbonOrbMenuItem{}
		SELF:ribbonOrbMenuItemOpen	:=	System.Windows.Forms.RibbonOrbMenuItem{}
		SELF:ribbonOrbMenuItemSave	:=	System.Windows.Forms.RibbonOrbMenuItem{}
		SELF:ribbonSeparator2	:=	System.Windows.Forms.RibbonSeparator{}
		SELF:ribbonOrbMenuItemSFX	:=	System.Windows.Forms.RibbonOrbMenuItem{}
		SELF:ribbonOrbButton_Close	:=	System.Windows.Forms.RibbonOrbOptionButton{}
		SELF:ribbonButtonHelp	:=	System.Windows.Forms.RibbonButton{}
		SELF:ribbonTab_FabZip	:=	System.Windows.Forms.RibbonTab{}
		SELF:ribbonPanel_Operation	:=	System.Windows.Forms.RibbonPanel{}
		SELF:ribbonButtonAdd	:=	System.Windows.Forms.RibbonButton{}
		SELF:ribbonButtonAdd_File	:=	System.Windows.Forms.RibbonButton{}
		SELF:ribbonButtonAdd_Folder	:=	System.Windows.Forms.RibbonButton{}
		SELF:ribbonButtonExtract	:=	System.Windows.Forms.RibbonButton{}
		SELF:ribbonButtonExtract_Selected	:=	System.Windows.Forms.RibbonButton{}
		SELF:ribbonButtonExtract_All	:=	System.Windows.Forms.RibbonButton{}
		SELF:ribbonPanel_MultiPart	:=	System.Windows.Forms.RibbonPanel{}
		SELF:ribbonSeparator1	:=	System.Windows.Forms.RibbonSeparator{}
		SELF:ribbonOrbOptionButton1	:=	System.Windows.Forms.RibbonOrbOptionButton{}
		SELF:ZipCtrl	:=	FabZip.WinForms.FabZipFileCtrl{}
		SELF:panel1	:=	System.Windows.Forms.Panel{}
		SELF:ZipList	:=	System.Windows.Forms.ListView{}
		SELF:colCrypted	:=	System.Windows.Forms.ColumnHeader{}
		SELF:colName	:=	System.Windows.Forms.ColumnHeader{}
		SELF:colDate	:=	System.Windows.Forms.ColumnHeader{}
		SELF:colTime	:=	System.Windows.Forms.ColumnHeader{}
		SELF:colSize	:=	System.Windows.Forms.ColumnHeader{}
		SELF:colRatio	:=	System.Windows.Forms.ColumnHeader{}
		SELF:colPacked	:=	System.Windows.Forms.ColumnHeader{}
		SELF:colAttributes	:=	System.Windows.Forms.ColumnHeader{}
		SELF:colPath	:=	System.Windows.Forms.ColumnHeader{}
		SELF:statusStrip1	:=	System.Windows.Forms.StatusStrip{}
		SELF:toolStripStatusLabel1	:=	System.Windows.Forms.ToolStripStatusLabel{}
		SELF:toolStripProgressBar1	:=	System.Windows.Forms.ToolStripProgressBar{}
		SELF:panel1:SuspendLayout()
		SELF:statusStrip1:SuspendLayout()
		SELF:SuspendLayout()
		//	
		//	ribbonFabZip
		//	
		SELF:ribbonFabZip:Font	:=	System.Drawing.Font{"Segoe UI", 9}
		SELF:ribbonFabZip:Location	:=	System.Drawing.Point{0, 0}
		SELF:ribbonFabZip:Margin	:=	System.Windows.Forms.Padding{4}
		SELF:ribbonFabZip:Minimized	:=	false
		SELF:ribbonFabZip:Name	:=	"ribbonFabZip"
		//	
		//	
		//	
		SELF:ribbonFabZip:OrbDropDown:BorderRoundness	:=	8
		SELF:ribbonFabZip:OrbDropDown:Location	:=	System.Drawing.Point{0, 0}
		SELF:ribbonFabZip:OrbDropDown:MenuItems:Add(SELF:ribbonOrbMenuItemNew)
		SELF:ribbonFabZip:OrbDropDown:MenuItems:Add(SELF:ribbonOrbMenuItemOpen)
		SELF:ribbonFabZip:OrbDropDown:MenuItems:Add(SELF:ribbonOrbMenuItemSave)
		SELF:ribbonFabZip:OrbDropDown:MenuItems:Add(SELF:ribbonSeparator2)
		SELF:ribbonFabZip:OrbDropDown:MenuItems:Add(SELF:ribbonOrbMenuItemSFX)
		SELF:ribbonFabZip:OrbDropDown:Name	:=	""
		SELF:ribbonFabZip:OrbDropDown:OptionItems:Add(SELF:ribbonOrbButton_Close)
		SELF:ribbonFabZip:OrbDropDown:Size	:=	System.Drawing.Size{227, 251}
		SELF:ribbonFabZip:OrbDropDown:TabIndex	:=	0
		SELF:ribbonFabZip:OrbImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonFabZip.OrbImage")))
		SELF:ribbonFabZip:OrbStyle	:=	System.Windows.Forms.RibbonOrbStyle.Office_2013
		//	
		//	
		//	
		SELF:ribbonFabZip:QuickAccessToolbar:Items:Add(SELF:ribbonButtonHelp)
		SELF:ribbonFabZip:RibbonTabFont	:=	System.Drawing.Font{"Trebuchet MS", 9}
		SELF:ribbonFabZip:Size	:=	System.Drawing.Size{939, 170}
		SELF:ribbonFabZip:TabIndex	:=	0
		SELF:ribbonFabZip:Tabs:Add(SELF:ribbonTab_FabZip)
		SELF:ribbonFabZip:TabSpacing	:=	4
		SELF:ribbonFabZip:Text	:=	"ribbon1"
		//	
		//	ribbonOrbMenuItemNew
		//	
		SELF:ribbonOrbMenuItemNew:DropDownArrowDirection	:=	System.Windows.Forms.RibbonArrowDirection.Left
		SELF:ribbonOrbMenuItemNew:Image	:=	((System.Drawing.Image)(resources:GetObject("ribbonOrbMenuItemNew.Image")))
		SELF:ribbonOrbMenuItemNew:LargeImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonOrbMenuItemNew.LargeImage")))
		SELF:ribbonOrbMenuItemNew:Name	:=	"ribbonOrbMenuItemNew"
		SELF:ribbonOrbMenuItemNew:SmallImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonOrbMenuItemNew.SmallImage")))
		SELF:ribbonOrbMenuItemNew:Text	:=	"New"
		SELF:ribbonOrbMenuItemNew:Click	+=	System.EventHandler{ SELF, @ribbonOrbMenuItemNew_Click() }
		//	
		//	ribbonOrbMenuItemOpen
		//	
		SELF:ribbonOrbMenuItemOpen:DropDownArrowDirection	:=	System.Windows.Forms.RibbonArrowDirection.Left
		SELF:ribbonOrbMenuItemOpen:Image	:=	((System.Drawing.Image)(resources:GetObject("ribbonOrbMenuItemOpen.Image")))
		SELF:ribbonOrbMenuItemOpen:LargeImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonOrbMenuItemOpen.LargeImage")))
		SELF:ribbonOrbMenuItemOpen:Name	:=	"ribbonOrbMenuItemOpen"
		SELF:ribbonOrbMenuItemOpen:SmallImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonOrbMenuItemOpen.SmallImage")))
		SELF:ribbonOrbMenuItemOpen:Text	:=	"Open"
		SELF:ribbonOrbMenuItemOpen:Click	+=	System.EventHandler{ SELF, @ribbonOrbMenuItemOpen_Click() }
		//	
		//	ribbonOrbMenuItemSave
		//	
		SELF:ribbonOrbMenuItemSave:DropDownArrowDirection	:=	System.Windows.Forms.RibbonArrowDirection.Left
		SELF:ribbonOrbMenuItemSave:Image	:=	((System.Drawing.Image)(resources:GetObject("ribbonOrbMenuItemSave.Image")))
		SELF:ribbonOrbMenuItemSave:LargeImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonOrbMenuItemSave.LargeImage")))
		SELF:ribbonOrbMenuItemSave:Name	:=	"ribbonOrbMenuItemSave"
		SELF:ribbonOrbMenuItemSave:SmallImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonOrbMenuItemSave.SmallImage")))
		SELF:ribbonOrbMenuItemSave:Text	:=	"Save"
		//	
		//	ribbonSeparator2
		//	
		SELF:ribbonSeparator2:Name	:=	"ribbonSeparator2"
		//	
		//	ribbonOrbMenuItemSFX
		//	
		SELF:ribbonOrbMenuItemSFX:DropDownArrowDirection	:=	System.Windows.Forms.RibbonArrowDirection.Left
		SELF:ribbonOrbMenuItemSFX:Image	:=	((System.Drawing.Image)(resources:GetObject("ribbonOrbMenuItemSFX.Image")))
		SELF:ribbonOrbMenuItemSFX:LargeImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonOrbMenuItemSFX.LargeImage")))
		SELF:ribbonOrbMenuItemSFX:Name	:=	"ribbonOrbMenuItemSFX"
		SELF:ribbonOrbMenuItemSFX:SmallImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonOrbMenuItemSFX.SmallImage")))
		SELF:ribbonOrbMenuItemSFX:Text	:=	"Save as SFX"
		//	
		//	ribbonOrbButton_Close
		//	
		SELF:ribbonOrbButton_Close:Image	:=	((System.Drawing.Image)(resources:GetObject("ribbonOrbButton_Close.Image")))
		SELF:ribbonOrbButton_Close:LargeImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonOrbButton_Close.LargeImage")))
		SELF:ribbonOrbButton_Close:Name	:=	"ribbonOrbButton_Close"
		SELF:ribbonOrbButton_Close:SmallImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonOrbButton_Close.SmallImage")))
		SELF:ribbonOrbButton_Close:Text	:=	"Close FabZip"
		SELF:ribbonOrbButton_Close:Click	+=	System.EventHandler{ SELF, @ribbonOrbButton_Close_Click() }
		//	
		//	ribbonButtonHelp
		//	
		SELF:ribbonButtonHelp:Image	:=	((System.Drawing.Image)(resources:GetObject("ribbonButtonHelp.Image")))
		SELF:ribbonButtonHelp:LargeImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonButtonHelp.LargeImage")))
		SELF:ribbonButtonHelp:MaxSizeMode	:=	System.Windows.Forms.RibbonElementSizeMode.Compact
		SELF:ribbonButtonHelp:Name	:=	"ribbonButtonHelp"
		SELF:ribbonButtonHelp:SmallImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonButtonHelp.SmallImage")))
		SELF:ribbonButtonHelp:Text	:=	"About..."
		//	
		//	ribbonTab_FabZip
		//	
		SELF:ribbonTab_FabZip:Name	:=	"ribbonTab_FabZip"
		SELF:ribbonTab_FabZip:Panels:Add(SELF:ribbonPanel_Operation)
		SELF:ribbonTab_FabZip:Panels:Add(SELF:ribbonPanel_MultiPart)
		SELF:ribbonTab_FabZip:Text	:=	"FabZip"
		//	
		//	ribbonPanel_Operation
		//	
		SELF:ribbonPanel_Operation:Items:Add(SELF:ribbonButtonAdd)
		SELF:ribbonPanel_Operation:Items:Add(SELF:ribbonButtonExtract)
		SELF:ribbonPanel_Operation:Name	:=	"ribbonPanel_Operation"
		SELF:ribbonPanel_Operation:Text	:=	"Zip Operation"
		//	
		//	ribbonButtonAdd
		//	
		SELF:ribbonButtonAdd:DropDownItems:Add(SELF:ribbonButtonAdd_File)
		SELF:ribbonButtonAdd:DropDownItems:Add(SELF:ribbonButtonAdd_Folder)
		SELF:ribbonButtonAdd:Image	:=	((System.Drawing.Image)(resources:GetObject("ribbonButtonAdd.Image")))
		SELF:ribbonButtonAdd:LargeImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonButtonAdd.LargeImage")))
		SELF:ribbonButtonAdd:Name	:=	"ribbonButtonAdd"
		SELF:ribbonButtonAdd:SmallImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonButtonAdd.SmallImage")))
		SELF:ribbonButtonAdd:Style	:=	System.Windows.Forms.RibbonButtonStyle.DropDown
		SELF:ribbonButtonAdd:Text	:=	"Add"
		//	
		//	ribbonButtonAdd_File
		//	
		SELF:ribbonButtonAdd_File:DropDownArrowDirection	:=	System.Windows.Forms.RibbonArrowDirection.Left
		SELF:ribbonButtonAdd_File:Image	:=	((System.Drawing.Image)(resources:GetObject("ribbonButtonAdd_File.Image")))
		SELF:ribbonButtonAdd_File:LargeImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonButtonAdd_File.LargeImage")))
		SELF:ribbonButtonAdd_File:Name	:=	"ribbonButtonAdd_File"
		SELF:ribbonButtonAdd_File:SmallImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonButtonAdd_File.SmallImage")))
		SELF:ribbonButtonAdd_File:Text	:=	"File"
		//	
		//	ribbonButtonAdd_Folder
		//	
		SELF:ribbonButtonAdd_Folder:DropDownArrowDirection	:=	System.Windows.Forms.RibbonArrowDirection.Left
		SELF:ribbonButtonAdd_Folder:Image	:=	((System.Drawing.Image)(resources:GetObject("ribbonButtonAdd_Folder.Image")))
		SELF:ribbonButtonAdd_Folder:LargeImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonButtonAdd_Folder.LargeImage")))
		SELF:ribbonButtonAdd_Folder:Name	:=	"ribbonButtonAdd_Folder"
		SELF:ribbonButtonAdd_Folder:SmallImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonButtonAdd_Folder.SmallImage")))
		SELF:ribbonButtonAdd_Folder:Text	:=	"Folder"
		//	
		//	ribbonButtonExtract
		//	
		SELF:ribbonButtonExtract:DropDownItems:Add(SELF:ribbonButtonExtract_Selected)
		SELF:ribbonButtonExtract:DropDownItems:Add(SELF:ribbonButtonExtract_All)
		SELF:ribbonButtonExtract:Image	:=	((System.Drawing.Image)(resources:GetObject("ribbonButtonExtract.Image")))
		SELF:ribbonButtonExtract:LargeImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonButtonExtract.LargeImage")))
		SELF:ribbonButtonExtract:Name	:=	"ribbonButtonExtract"
		SELF:ribbonButtonExtract:SmallImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonButtonExtract.SmallImage")))
		SELF:ribbonButtonExtract:Style	:=	System.Windows.Forms.RibbonButtonStyle.DropDown
		SELF:ribbonButtonExtract:Text	:=	"Extract"
		//	
		//	ribbonButtonExtract_Selected
		//	
		SELF:ribbonButtonExtract_Selected:DropDownArrowDirection	:=	System.Windows.Forms.RibbonArrowDirection.Left
		SELF:ribbonButtonExtract_Selected:Image	:=	((System.Drawing.Image)(resources:GetObject("ribbonButtonExtract_Selected.Image")))
		SELF:ribbonButtonExtract_Selected:LargeImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonButtonExtract_Selected.LargeImage")))
		SELF:ribbonButtonExtract_Selected:Name	:=	"ribbonButtonExtract_Selected"
		SELF:ribbonButtonExtract_Selected:SmallImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonButtonExtract_Selected.SmallImage")))
		SELF:ribbonButtonExtract_Selected:Text	:=	"Selected"
		SELF:ribbonButtonExtract_Selected:Click	+=	System.EventHandler{ SELF, @ribbonButtonExtract_Selected_Click() }
		//	
		//	ribbonButtonExtract_All
		//	
		SELF:ribbonButtonExtract_All:DropDownArrowDirection	:=	System.Windows.Forms.RibbonArrowDirection.Left
		SELF:ribbonButtonExtract_All:Image	:=	((System.Drawing.Image)(resources:GetObject("ribbonButtonExtract_All.Image")))
		SELF:ribbonButtonExtract_All:LargeImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonButtonExtract_All.LargeImage")))
		SELF:ribbonButtonExtract_All:Name	:=	"ribbonButtonExtract_All"
		SELF:ribbonButtonExtract_All:SmallImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonButtonExtract_All.SmallImage")))
		SELF:ribbonButtonExtract_All:Text	:=	"All"
		//	
		//	ribbonPanel_MultiPart
		//	
		SELF:ribbonPanel_MultiPart:Name	:=	"ribbonPanel_MultiPart"
		SELF:ribbonPanel_MultiPart:Text	:=	"MultiPart"
		//	
		//	ribbonSeparator1
		//	
		SELF:ribbonSeparator1:Name	:=	"ribbonSeparator1"
		//	
		//	ribbonOrbOptionButton1
		//	
		SELF:ribbonOrbOptionButton1:Image	:=	((System.Drawing.Image)(resources:GetObject("ribbonOrbOptionButton1.Image")))
		SELF:ribbonOrbOptionButton1:LargeImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonOrbOptionButton1.LargeImage")))
		SELF:ribbonOrbOptionButton1:Name	:=	"ribbonOrbOptionButton1"
		SELF:ribbonOrbOptionButton1:SmallImage	:=	((System.Drawing.Image)(resources:GetObject("ribbonOrbOptionButton1.SmallImage")))
		SELF:ribbonOrbOptionButton1:Text	:=	"ribbonOrbOptionButton1"
		//	
		//	ZipCtrl
		//	
		SELF:ZipCtrl:Location	:=	System.Drawing.Point{456, 364}
		SELF:ZipCtrl:Margin	:=	System.Windows.Forms.Padding{4}
		SELF:ZipCtrl:Name	:=	"ZipCtrl"
		SELF:ZipCtrl:Size	:=	System.Drawing.Size{108, 82}
		SELF:ZipCtrl:TabIndex	:=	1
		//	
		//	panel1
		//	
		SELF:panel1:Controls:Add(SELF:ZipList)
		SELF:panel1:Dock	:=	System.Windows.Forms.DockStyle.Fill
		SELF:panel1:Location	:=	System.Drawing.Point{0, 170}
		SELF:panel1:Margin	:=	System.Windows.Forms.Padding{4}
		SELF:panel1:Name	:=	"panel1"
		SELF:panel1:Size	:=	System.Drawing.Size{939, 381}
		SELF:panel1:TabIndex	:=	2
		//	
		//	ZipList
		//	
		SELF:ZipList:Columns:AddRange(<System.Windows.Forms.ColumnHeader>{ SELF:colCrypted, SELF:colName, SELF:colDate, SELF:colTime, SELF:colSize, SELF:colRatio, SELF:colPacked, SELF:colAttributes, SELF:colPath })
		SELF:ZipList:Dock	:=	System.Windows.Forms.DockStyle.Fill
		SELF:ZipList:FullRowSelect	:=	true
		SELF:ZipList:HideSelection	:=	false
		SELF:ZipList:Location	:=	System.Drawing.Point{0, 0}
		SELF:ZipList:Margin	:=	System.Windows.Forms.Padding{4}
		SELF:ZipList:Name	:=	"ZipList"
		SELF:ZipList:Size	:=	System.Drawing.Size{939, 381}
		SELF:ZipList:TabIndex	:=	0
		SELF:ZipList:UseCompatibleStateImageBehavior	:=	false
		SELF:ZipList:View	:=	System.Windows.Forms.View.Details
		//	
		//	colCrypted
		//	
		SELF:colCrypted:Text	:=	"Crypted"
		SELF:colCrypted:Width	:=	10
		//	
		//	colName
		//	
		SELF:colName:Text	:=	"File Name"
		SELF:colName:Width	:=	150
		//	
		//	colDate
		//	
		SELF:colDate:Text	:=	"Date"
		SELF:colDate:Width	:=	70
		//	
		//	colTime
		//	
		SELF:colTime:Text	:=	"Time"
		SELF:colTime:Width	:=	68
		//	
		//	colSize
		//	
		SELF:colSize:Text	:=	"Size"
		SELF:colSize:TextAlign	:=	System.Windows.Forms.HorizontalAlignment.Right
		//	
		//	colRatio
		//	
		SELF:colRatio:Text	:=	"Ratio"
		SELF:colRatio:TextAlign	:=	System.Windows.Forms.HorizontalAlignment.Right
		SELF:colRatio:Width	:=	40
		//	
		//	colPacked
		//	
		SELF:colPacked:Text	:=	"Packed"
		SELF:colPacked:TextAlign	:=	System.Windows.Forms.HorizontalAlignment.Right
		//	
		//	colAttributes
		//	
		SELF:colAttributes:Text	:=	"Attributes"
		SELF:colAttributes:Width	:=	30
		//	
		//	colPath
		//	
		SELF:colPath:Text	:=	"Path"
		SELF:colPath:Width	:=	200
		//	
		//	statusStrip1
		//	
		SELF:statusStrip1:ImageScalingSize	:=	System.Drawing.Size{20, 20}
		SELF:statusStrip1:Items:AddRange(<System.Windows.Forms.ToolStripItem>{ SELF:toolStripStatusLabel1, SELF:toolStripProgressBar1 })
		SELF:statusStrip1:Location	:=	System.Drawing.Point{0, 526}
		SELF:statusStrip1:Name	:=	"statusStrip1"
		SELF:statusStrip1:Padding	:=	System.Windows.Forms.Padding{1, 0, 19, 0}
		SELF:statusStrip1:Size	:=	System.Drawing.Size{939, 25}
		SELF:statusStrip1:TabIndex	:=	4
		SELF:statusStrip1:Text	:=	"statusStrip1"
		//	
		//	toolStripStatusLabel1
		//	
		SELF:toolStripStatusLabel1:AutoSize	:=	false
		SELF:toolStripStatusLabel1:Name	:=	"toolStripStatusLabel1"
		SELF:toolStripStatusLabel1:Size	:=	System.Drawing.Size{200, 19}
		SELF:toolStripStatusLabel1:TextAlign	:=	System.Drawing.ContentAlignment.MiddleLeft
		//	
		//	toolStripProgressBar1
		//	
		SELF:toolStripProgressBar1:AutoSize	:=	false
		SELF:toolStripProgressBar1:MarqueeAnimationSpeed	:=	10
		SELF:toolStripProgressBar1:Name	:=	"toolStripProgressBar1"
		SELF:toolStripProgressBar1:Size	:=	System.Drawing.Size{267, 17}
		//	
		//	MainWindow
		//	
		SELF:AutoScaleDimensions	:=	System.Drawing.SizeF{8, 16}
		SELF:AutoScaleMode	:=	System.Windows.Forms.AutoScaleMode.Font
		SELF:ClientSize	:=	System.Drawing.Size{939, 551}
		SELF:Controls:Add(SELF:statusStrip1)
		SELF:Controls:Add(SELF:panel1)
		SELF:Controls:Add(SELF:ZipCtrl)
		SELF:Controls:Add(SELF:ribbonFabZip)
		SELF:KeyPreview	:=	true
		SELF:Margin	:=	System.Windows.Forms.Padding{4}
		SELF:Name	:=	"MainWindow"
		SELF:Text	:=	"XSharp.Net Zip"
		SELF:panel1:ResumeLayout(false)
		SELF:statusStrip1:ResumeLayout(false)
		SELF:statusStrip1:PerformLayout()
		SELF:ResumeLayout(false)
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
	    LOCAL oCtrl         AS  FabZipFileCtrl
    //	LOCAL oFS			AS	FileSpec
	    // We come here due to FabZipFile creation, we are in the Init() of the Window
	    IF ( SELF:ZipList == NULL_OBJECT )
		    RETURN 
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
		    SELF:ZipList:Items:Add( oItem )
	    NEXT
    RETURN	
	
	
	
	
	
	
	

    VIRTUAL METHOD OnFabZipProgress( oCtrl AS OBJECT, symEvent AS FabZipEvent, cFile AS STRING, nSize AS INT64 ) AS VOID
	    IF ( symEvent == FabZipEvent.NewEntry )
		    // Convert Unix-style to Dos separator
		    cFile := StrTran( cFile, "/", "\" )
		    SELF:toolStripStatusLabel1:Text := cFile
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
		    SELF:toolStripStatusLabel1:Text := ""
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
        LOCAL ToExtract AS ListView.SelectedListViewItemCollection
        LOCAL oDlg AS ExtractWindow
        LOCAL cPath AS STRING
        LOCAL Cpt AS INT
        LOCAL oItem AS ListViewItem
        LOCAL cFile AS STRING
        //
        ToExtract := SELF:ZipList:SelectedItems
        //
        IF ( ToExtract:Count == 0 )
            RETURN 
        ENDIF
        //
        oDlg := ExtractWindow{}
        IF ( oDlg:ShowDialog() != DialogResult.Ok )
            RETURN
        ENDIF
        //
        cPath := oDlg:comboToPath:Text
        // Be sure to set the right style for the ProgressBar
        SELF:toolStripProgressBar1:Style := System.Windows.Forms.ProgressBarStyle.Blocks
        SELF:toolStripProgressBar1:Maximum := ToExtract:Count
        //
        SELF:ZipCtrl:ZipFile:ExtractDir := cPath
        //
        FOR Cpt := 0 TO ToExtract:Count-1
            oItem := ToExtract[ Cpt ]
            cFile := oItem:Tag:ToString()
            SELF:ZipCtrl:ZipFile:FilesArg:Add( cFile )
        NEXT
        // Now, Extract
        SELF:ZipCtrl:ZipFile:Extract()
        //
        RETURN

END CLASS 
