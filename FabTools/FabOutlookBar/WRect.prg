CLASS WRect INHERIT VObject

	EXPORT Left AS LONGINT
	EXPORT Top AS LONGINT
	EXPORT Right AS LONGINT
	EXPORT Bottom AS LONGINT

	ACCESS BoundingBox AS BoundingBox  
	LOCAL oBB AS BoundingBox
    //
	oBB := BoundingBox{ SELF:Origin, Point{ SELF:Right, SELF:Bottom } }
RETURN oBB

ASSIGN BoundingBox( oBB AS BoundingBox )   
    //
	SELF:SetRect( oBB:Origin:x, oBB:Origin:y, oBB:Extent:x, oBB:Extent:y )
RETURN 

METHOD Clone() AS WRect  

	LOCAL oClonedRect AS WRect

	oClonedRect := WRect{}
	oClonedRect:SetRect(SELF:Left, SELF:Top, SELF:Right, SELF:Bottom)
	RETURN oClonedRect

METHOD GetRectWin( rc AS _winRect ) AS LOGIC  
//l Koordinaten des Objektes in eine _winRect-Struktur übernehmen
//p Übernahme der Koordinaten des Objektes in eine _winRect-Struktur
//a lprc\tab (PTR) Zeiger auf eine _winRect-Struktur in die die Koordinaten des Objektes übernommen werden sollen
//r Die Methode liefert immer TRUE zurück
//d Diese Methode dient, zusammen mit der Methode SetRectWin() zum einfacheren Handling
//d der _winRect Struktur bei der Zusammenarbeit mit dieser Klasse.

	rc:Left := SELF:Left
	rc:Top := SELF:Top
	rc:Right := SELF:Right
	rc:Bottom := SELF:Bottom
	RETURN TRUE


ACCESS Height AS LONGINT  

	LOCAL liHeight AS LONGINT

	liHeight := SELF:Bottom - SELF:Top
	RETURN liHeight


CONSTRUCTOR() 

	SUPER()

	SELF:Left := 0L
	SELF:Top := 0L
	SELF:Right := 0L
	SELF:Bottom := 0L

return 

ACCESS Origin AS Point  

	LOCAL oPoint AS Point

	oPoint := Point{ SELF:Left, SELF:Top}
	RETURN oPoint


ASSIGN Origin( oPoint AS Point )   

	SELF:Left := oPoint:X
	SELF:Top := oPoint:Y
	RETURN 


METHOD PointInside( oTarget AS Point ) AS LOGIC  
	LOCAL lInside AS LOGIC
	//
	IF oTarget:X < SELF:Left
		lInside := FALSE
	ELSEIF oTarget:Y < SELF:Top
		lInside := FALSE
	ELSEIF oTarget:X > SELF:Right
		lInside := FALSE
	ELSEIF oTarget:Y > SELF:Bottom
		lInside := FALSE
	ELSE
		lInside := TRUE
	ENDIF
RETURN lInside


METHOD SetEmpty() AS LOGIC  

	SELF:Left := 0
	SELF:Top := 0
	SELF:Right := 0
	SELF:Bottom := 0
	RETURN TRUE


METHOD SetRect( liLeft AS LONGINT, liTop AS LONGINT, liRight AS LONGINT, liBottom AS LONGINT ) AS LOGIC  
//l Setzen der Koordinaten für das Objekt
//p Setzen aller vier Koordinaten des Objektes mit einem Aufruf
//a liLeft\tab (LongInt) Gibt die X-Koordinate der oberen linken Ecke an
//a liTop\tab (LongInt) Gibt die Y-Koordinate der oberen linken Ecke an
//a liRight\tab (LongInt) Gibt die X-Koordinate der Ecke unten rechts an
//a liBottom\tab (LongInt) Gibt die Y-Koordinate der Ecke unten rechts an
//r Die Methode liefert immer TRUE zurück
//d Die SetRect Methode setzt die Koordinaten des Objektes auf die übergebenen Werte.
//d Diese Methode ist zum setzen der einzelnen Properties des Objektes gleichwertig,
//d erlaubt jedoch eine etwas kürzere Schreibweise.

	SELF:Left := liLeft
	SELF:Top := liTop
	SELF:Right := liRight
	SELF:Bottom := liBottom
	RETURN TRUE


METHOD SetRectWin( lprc AS _winRect ) AS LOGIC  
//l Koordinaten des Objektes aus einer _winRect-Struktur übernehmen
//p Übernahme der Koordinaten aus einer _winRect-Struktur
//a lprc\tab (PTR) Zeiger auf eine _winRect-Struktur von der die Koordinaten übernommen werden
//r Die Methode liefert immer TRUE zurück
//d Diese Methode dient, zusammen mit der Methode GetRectWin() zum einfacheren Handling
//d der _winRect Struktur bei der Zusammenarbeit mit dieser Klasse.

	SELF:Left := lprc:Left
	SELF:Top := lprc:Top
	SELF:Right := lprc:Right
	SELF:Bottom := lprc:Bottom
	RETURN TRUE


ACCESS Width AS LONGINT  

	LOCAL liWidth AS LONGINT

	liWidth := SELF:Bottom - SELF:Top
	RETURN liWidth


END CLASS

