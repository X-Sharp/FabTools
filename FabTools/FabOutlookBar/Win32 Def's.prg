VOSTRUCT	_winGRADIENT_RECT 
	member UpperLeft as DWORD 
	member LowerRight	as	DWORD 

VOSTRUCT _winTRIVERTEX 
	member x 		as long 
	member y 		as long 
	member Red 		as word
	member Green 	as word
	member Blue 	as word
	member Alpha 	as word
	 

VOSTRUCT	_winGRADIENT_TRIANGLE 
	member Vertex1	as	DWORD 
	member Vertex2	as	DWORD 
	member Vertex3	as	DWORD 

_dll FUNC GradientFill(HDC as ptr, pVertex as _winTRIVERTEX, dwNumVertex as dword, pMesh as ptr, dwNumMesh as dword, dwMode as dword );
	as LOGIC PASCAL:MSImg32.GradientFill


DEFINE GRADIENT_FILL_RECT_H := 0 AS LONG
DEFINE GRADIENT_FILL_RECT_V := 1 AS LONG