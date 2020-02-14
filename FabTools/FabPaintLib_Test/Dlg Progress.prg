USING VO
#include "Dlg Progress.vh"

STATIC DEFINE PROGRESS_PROGRESSBAR1 := 100


PARTIAL CLASS Progress INHERIT DIALOGWINDOW
	EXPORT oDCProgressBar1 AS PROGRESSBAR

	// {{%UC%}} User code starts here (DO NOT remove this line)  

CONSTRUCTOR(oParent,uExtra)

	SELF:PreInit(oParent,uExtra)

	SUPER(oParent , ResourceID{"Progress" , _GetInst()} , FALSE)

	SELF:oDCProgressBar1 := PROGRESSBAR{SELF , ResourceID{ PROGRESS_PROGRESSBAR1  , _GetInst() } }
	SELF:oDCProgressBar1:HyperLabel := HyperLabel{#ProgressBar1 , NULL_STRING , NULL_STRING , NULL_STRING}
	SELF:oDCProgressBar1:Range := Range{ , 100}

	SELF:Caption := "Loading..."
	SELF:HyperLabel := HyperLabel{#Progress , "Loading..." , NULL_STRING , NULL_STRING}

	SELF:PostInit(oParent,uExtra)

RETURN


END CLASS

