#include "VOSystemLibrary.vh"
#include "VOWin32APILibrary.vh"
#include "Dlg Progress.vh"
class Progress inherit DIALOGWINDOW 

	export oDCProgressBar1 as PROGRESSBAR

  //{{%UC%}} USER CODE STARTS HERE (do NOT remove this line)

CONSTRUCTOR(oParent,uExtra)  

self:PreInit(oParent,uExtra)

super(oParent,ResourceID{"Progress",_GetInst()},FALSE)

oDCProgressBar1 := ProgressBar{self,ResourceID{PROGRESS_PROGRESSBAR1,_GetInst()}}
oDCProgressBar1:HyperLabel := HyperLabel{#ProgressBar1,NULL_STRING,NULL_STRING,NULL_STRING}
oDCProgressBar1:Range := Range{0,100}

self:Caption := "Loading..."
self:HyperLabel := HyperLabel{#Progress,"Loading...",NULL_STRING,NULL_STRING}

self:PostInit(oParent,uExtra)

return 

END CLASS

