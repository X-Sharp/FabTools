 
 USING VO

STATIC GLOBAL __hModThemes AS PTR

PROCEDURE FabInitXPThemes() STRICT
	//
	IF ( __hModThemes != NULL_PTR )
		RETURN
	ENDIF
	//
	__hModThemes := LoadLibrary( PSZ(_CAST,"UXTHEME.DLL" ) )
	IF( __hModThemes != NULL )
		//
		ptrOpenThemeData := GetProcAddress(__hModThemes, PSZ(_CAST,"OpenThemeData"))
		ptrDrawThemeBackground := GetProcAddress(__hModThemes, PSZ(_CAST,"DrawThemeBackground"))
		ptrCloseThemeData := GetProcAddress(__hModThemes, PSZ(_CAST,"CloseThemeData"))
		ptrDrawThemeText := GetProcAddress(__hModThemes, PSZ(_CAST,"DrawThemeText"))
		ptrGetThemeBackgroundContentRect := GetProcAddress(__hModThemes, PSZ(_CAST,"GetThemeBackgroundContentRect"))
		//
		IF( ptrOpenThemeData != NULL_PTR )
		ELSE
			FreeLibrary( __hModThemes )
			__hModThemes := NULL
		ENDIF
	ENDIF
	//
return

STATIC GLOBAL ptrOpenThemeData AS OpenThemeData PTR

STATIC GLOBAL ptrDrawThemeBackground AS DrawThemeBackground PTR

STATIC GLOBAL ptrCloseThemeData AS CloseThemeData PTR

STATIC GLOBAL ptrDrawThemeText AS DrawThemeText PTR

STATIC GLOBAL ptrGetThemeBackgroundContentRect AS GetThemeBackgroundContentRect PTR

FUNCTION FabXPThemesLoaded() AS LOGIC STRICT
RETURN ( __hModTHemes != NULL )

FUNCTION CloseThemeData( hTheme AS PTR ) AS PTR STRICT
	LOCAL hResult	AS	PTR
	//
	hResult := PCALL( ptrCloseThemeData, hTheme )
RETURN hResult

FUNCTION DrawThemeBackground( hTheme AS PTR, hdc AS PTR, iPartId AS LONG, iStateId AS LONG, pRect AS _WINRect,  pClipRect AS _WINRect ) AS PTR STRICT
	LOCAL hResult	AS	PTR
	//
	hResult := PCALL( ptrDrawThemeBackground, hTheme, hDC, iPartID, IStateId, pRect, pClipRect )
RETURN hResult

FUNCTION DrawThemeText( hTheme AS PTR, hdc AS PTR, iPartId AS LONG, iStateId AS LONG, pszText AS PSZ, iCharCount AS LONG, dwTextFlags AS DWORD, dwTextFlags2 AS DWORD, pRect AS _winRect ) AS PTR STRICT
	LOCAL hResult	AS	PTR
	//
	hResult := PCALL( ptrDrawThemeText, hTheme, hdc, iPartId, iStateID, pszText, iCharCount, dwTextFlags, dwTextFlags2 , pRect )
RETURN hResult

FUNCTION GetThemeBackgroundContentRect( hTheme AS PTR, hdc AS PTR, iPartId AS LONG, iStateId AS LONG, pBoundingRect AS _WINRect,  pContentRect AS _WINRect) AS PTR STRICT
	LOCAL hResult	AS	PTR
	//
	hResult := PCALL( ptrGetThemeBackgroundContentRect, hTheme, hdc, iPartId, iStateId, pBoundingRect, pContentRect )
RETURN hResult

FUNCTION OpenThemeData( hWnd as ptr, cClassList as psz ) as ptr STRICT
	LOCAL hResult		AS	PTR
	LOCAL wClassList	AS	STRING
	//
	wClassList := Multi2Wide( Psz2String(cClassList) )
	hResult := PCALL( ptrOpenThemeData, hWnd, String2Psz(wClassList ) )
RETURN hResult

