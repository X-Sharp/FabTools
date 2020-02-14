
BEGIN NAMESPACE FabPaintLib.Control

	CLASS FabMouseTrackSelection
		//d Class used when TrackSelection is activated in FabPaintLib Control
		//d When you set TrackSelection to TRUE in a FabPaintLibCtrl object,
		//d Pressing LeftMouse Button Down with Shift key down will generate a call
		//d to OnTrackSelection Method in the Owner of the Control
		//d In that method copy the following code.
		//d All work in done in the TrackStart method, at the return of this method
		//d you can retrieve the selected rectangle in
		//d oMTrack:TrackRect:Left, oMTrack:TrackRect:TOp,oMTrack:TrackRect:RIght,oMTrack:TrackRect:Bottom
		
		//e METHOD OnTrackSelection () CLASS TestWnd
		//e	LOCAL oMTrack AS FabMouseTrackSelection
		//e	//
		//e	oMTrack := FabMouseTrackSelection{ SELF:oDCOrgImg }
		//e	oMTrack:ShowCoords := TRUE
		//e	oMTrack:LineMode := SELF:oDCLineModeChk:Checked
		//e	oMTrack:TrackStart()
		
		PROTECT hWnd 		AS 	PTR	
		PROTECT hDC 		AS 	PTR
		PROTECT rcClip 		AS 	_winRECT
		PROTECT lShowCoords AS 	LOGIC
		PROTECT lLineMode	AS	LOGIC
		
		METHOD __DrawSelect() AS OBJECT  	
			LOCAL pszCoords AS PSZ
			LOCAL x,y,dx,dy AS INT
			LOCAL hdcBits AS PTR
			LOCAL hbm, hOldBm AS PTR
			LOCAL size IS _winSIZE
			// Draw the Rectangle's selection
			// Something to Draw ?
			//	IF !IsRectEmpty ( SELF:rcClip)
			IF !( ( SELF:rcClip:Left == SELF:rcClip:Right ) .AND. ( SELF:rcClip:Top == SELF:rcClip:Bottom ) )
				IF !( SELF:LineMode )
					// If a rectangular clip region has been selected, draw it
					PatBlt( SELF:hDC, SELF:rcClip:left,    SELF:rcClip:top,        SELF:rcClip:right- SELF:rcClip:left, 1,  DSTINVERT)
					PatBlt( SELF:hDC, SELF:rcClip:left,    SELF:rcClip:bottom, 1, -(SELF:rcClip:bottom- SELF:rcClip:top),   DSTINVERT)
					PatBlt( SELF:hDC, SELF:rcClip:right-1, SELF:rcClip:top, 1,   SELF:rcClip:bottom- SELF:rcClip:top,   DSTINVERT)
					PatBlt( SELF:hDC, SELF:rcClip:right,   SELF:rcClip:bottom-1, -( SELF:rcClip:right- SELF:rcClip:left), 1, DSTINVERT)
				ELSE
					SetROP2( SELF:hDC, R2_NOTXORPEN )
					MoveToEx( SELF:hDC, SELF:rcClip:left, SELF:rcClip:top, NULL_PTR )
					LineTo( SELF:hDC, SELF:rcClip:right, SELF:rcClip:bottom )
				ENDIF
				//
				IF SELF:lShowCoords
					// Format the dimensions string
					pszCoords := StringAlloc ( Space ( 80 ) )
					//
					
					//			OSPrintF( pszCoords,;
					//                  Cast2Psz ( "%dx%d" ),;
					//                  AbsLong(SELF:rcClip:right  - SELF:rcClip:left),;
					//                  AbsLong(SELF:rcClip:bottom - SELF:rcClip:top) )
					
					// ... and center it in the rectangle
					GetTextExtentPoint( self:hDC, pszCoords, long(PszLen ( pszCoords )), @size)
					dx := size:cx
					dy := size:cy
					//
					x  :=  ( SELF:rcClip:right  + SELF:rcClip:left - dx) / 2
					y  :=  ( SELF:rcClip:bottom + SELF:rcClip:top  - dy) / 2
					// Create a Bitmap
					hdcBits := CreateCompatibleDC ( SELF:hDC )
					SetTextColor (hdcBits, 0xFFFFFFL)
					SetBkColor (hdcBits, 0x000000L)
					//
					// Output the text to the DC
					hbm := CreateBitmap(dx, dy, 1, 1, NULL)
					IF ( hBM != NULL_PTR )
						hOldBm := SelectObject (hdcBits, hbm)
						ExtTextOut (hdcBits, 0, 0, 0, NULL, pszCoords, PszLen ( pszCoords ), NULL)
						BitBlt ( SELF:hDC, x, y, dx, dy, hdcBits, 0, 0, SRCINVERT)
						SelectObject (hdcBits, hOldbm)
						DeleteObject (hbm)
					ENDIF
					//
					DeleteDC (hdcBits)
					MemFree ( pszCoords )
				ENDIF			
			ENDIF
			RETURN SELF
			
		METHOD __NormalizeRect () AS OBJECT  
			LOCAL liTemp AS LONG
			// Make sure coords are in the right position
			// Depending on how you select the region ( from right to left, Bottom to up, ... )
			IF ( SELF:rcClip:right < SELF:rcClip:left )
				liTemp := SELF:rcClip:right
				//
				SELF:rcClip:right := SELF:rcClip:left
				SELF:rcClip:left := liTemp
			ENDIF
			//
			IF SELF:rcClip:bottom < SELF:rcClip:top
				liTemp := SELF:rcClip:bottom
				//		
				SELF:rcClip:bottom := SELF:rcClip:top
				SELF:rcClip:top := liTemp
			ENDIF	
			RETURN SELF
			
		DESTRUCTOR() 
			//	
			SELF:destroy()
			//
			return 
			
		METHOD Destroy() 
			//	
			MemFree ( SELF:rcClip )
			DeleteDC ( SELF:hDC )
			//
			SELF:rcClip := NULL_PTR
			SELF:hDC := NULL_PTR
			//
			UnRegisterAxit( SELF )
			//
			
			return self	
			
		CONSTRUCTOR ( oOwner) 	
			//d Retrieve the Window's Handle, depending of the Window type
			DO CASE
				CASE IsPtr ( oOwner )
					SELF:hWnd := oOwner
				CASE IsObject( oOwner ) .and. IsInstanceOf ( oOwner , #DATAWINDOW )
					SELF:hWnd := oOwner:__GetFormSurface():handle()
				CASE IsObject( oOwner )
					SELF:hWnd := oOwner:handle()
			ENDCASE
			// Need an access to screen
			SELF:hDC := CreateDC(Cast2Psz("DISPLAY"), NULL_PSZ, NULL_PSZ , NULL_PTR )
			SELF:rcClip := MemAlloc ( _sizeof ( _winRECT ) )
			SELF:lLineMode := FALSE
			//
			
			//
			return 
			
		ACCESS LineMode AS LOGIC  
			//r A logical value indicating if the selection drawing is a Line or a Box
			RETURN SELF:lLineMode
			
		ASSIGN LineMode ( lSet AS LOGIC )   
			//r A logical value indicating if the selection drawing is a Line or a Box
			SELF:lLineMode := lSet
			RETURN 
			
		ACCESS ShowCoords AS LOGIC  
			//r A logical value indicating if the coords must be shown during selection
			RETURN SELF:lShowCoords
			
			
		ASSIGN ShowCoords ( lShow AS LOGIC )   
			//r A logical value indicating if the coords must be shown during selection
			SELF:lShowCoords := lShow
			RETURN 
			
			
			
		ACCESS TrackRect() AS Boundingbox  
			//r A BoundingBox of the current selection coords.
			RETURN Boundingbox { Point { SELF:rcClip:left , SELF:rcClip:bottom } , ;
			Point { SELF:rcClip:right , SELF:rcClip:Top } }
			
			
		METHOD TrackStart() AS OBJECT  
			//d Start the Track Selection Process
			LOCAL msg 		IS _winMSG
			LOCAL pt 		IS _winPOINT
			LOCAL sRect 	IS _winRECT
			LOCAL sNewpoint is _winPOINT
			//
			GetCursorPos ( @pt )
			GetClientRect ( SELF:hWnd , @sRect )		
			//		
			SetCapture( self:hWnd)
			SetRectEmpty ( self:rcClip )
			// Draw the current selection
			self:__DrawSelect()
			//
			self:rcClip:left   := pt:x
			self:rcClip:top    := pt:y
			self:rcClip:right  := pt:x
			self:rcClip:bottom := pt:y
			// Eat mouse messages until a WM_LBUTTONUP IS encountered. Meanwhile
			// continue TO draw a rubberbanding rectangle and display it's dimensions
			SetCursor ( pointer {POINTERCROSSHAIRS}:handle() )
			//
			WHILE true
				//
				WaitMessage()
				// Is it a Mouse Message ?
				IF ( PeekMessage( @msg , null , WM_MOUSEFIRST , WM_MOUSELAST , PM_REMOVE ) )
					// Re-Drawing at the same place....erase the drawing
					self:__DrawSelect( )
					//
					sNewPoint:x := msg:pt:x
					sNewPoint:y := msg:pt:y			
					ScreenToClient ( self:hWnd , @sNewpoint )
					//
					IF ! SELF:LineMode
						IF ( sNewPoint:x < sRect:left )
							sNewPoint:x := sRect:left
						ENDIF
						IF ( sNewPoint:x > sRect:right )
							sNewPoint:x := sRect:right
						ENDIF
						IF ( sNewPoint:y < sRect:top )
							sNewPoint:y := sRect:top
						ENDIF
						IF ( sNewPoint:y > sRect:bottom )
							sNewPoint:y := sRect:bottom
						ENDIF
					ENDIF
					// Check if mouse is inside the Window
					IF Between ( sNewpoint:x , sRect:left , sRect:Right ) .and. ;
						Between ( sNewPoint:y , sRect:top , sRect:bottom )	
						//
						ClientToScreen( SELF:hWnd , @sNewPoint )
						//
						self:rcClip:left   := pt:x
						self:rcClip:top    := pt:y
						self:rcClip:right  := sNewpoint:x //msg.pt.x
						self:rcClip:bottom := sNewpoint:y
					ENDIF
					//		
					IF ! self:LineMode
						self:__NormalizeRect()
					ENDIF
					// Draw the New selection
					self:__DrawSelect( )
					// Last Message.....
					IF (msg:message == (DWORD)WM_LBUTTONUP)
						self:__DrawSelect( )
						exit
					ENDIF
				ENDIF
			ENDDO
			//
			ReleaseCapture()
			RETURN self  
	END CLASS
	
END NAMESPACE 