 USING VO


FUNCTION FabXPThemesLoaded() AS LOGIC STRICT
RETURN TRUE

_DLL FUNCTION CloseThemeData( hTheme AS PTR ) AS PTR PASCAL:UXTHEME.CloseThemeData

_DLL FUNCTION DrawThemeBackground( hTheme AS PTR, hdc AS PTR, iPartId AS LONG, iStateId AS LONG, pRect AS _WINRect,  pClipRect AS _WINRect ) AS PTR PASCAL:UXTHEME.DrawThemeBackground

_DLL FUNCTION DrawThemeText( hTheme AS PTR, hdc AS PTR, iPartId AS LONG, iStateId AS LONG, pszText AS STRING, iCharCount AS LONG, dwTextFlags AS DWORD, dwTextFlags2 AS DWORD, pRect AS _winRect ) AS PTR PASCAL:UXTHEME.DrawThemeText ANSI

_DLL FUNCTION GetThemeBackgroundContentRect( hTheme AS PTR, hdc AS PTR, iPartId AS LONG, iStateId AS LONG, pBoundingRect AS _WINRect,  pContentRect AS _WINRect) AS PTR PASCAL:UXTHEME.GetThemeBackgroundContentRect

_DLL FUNCTION OpenThemeData( hWnd as ptr, cClassList as STRING) as PTR PASCAL:UXTHEME.OpenThemeData ANSI

PROCEDURE FabInitXPThemes() STRICT
	RETURN



