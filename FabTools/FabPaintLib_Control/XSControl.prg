// CodeFile1.prg
#using System.Windows.Forms
#using System.Drawing
#using System.Drawing.Drawing2D
#using FabPaintLib

BEGIN NAMESPACE FabPaintLib.Control

	//Implicit CLIPPER Calling convention : Off
	
	class FabPaintLib_Control inherit System.Windows.Forms.ScrollableControl
		// Fields
		Private oImg     as FabPaintLib
		private r8Zoom    as real8
		
		// Methods
		constructor()
			super()
			//
			self:r8Zoom := 1
			self:SetStyle((System.Windows.Forms.ControlStyles.DoubleBuffer | (System.Windows.Forms.ControlStyles.AllPaintingInWmPaint | (System.Windows.Forms.ControlStyles.ResizeRedraw | System.Windows.Forms.ControlStyles.UserPaint))), true)
			self:AutoScroll := true
			
		ACCESS Image AS FabPaintLib  
			//r Give access to the FabPaintLib object linked to the control
			RETURN self:oImg
			
		ASSIGN Image( oNewImg AS FabPaintLib )   
			//p Set a new FabPaintLib object to be linked to the control
			IF ( oNewImg != NULL_OBJECT ) 
				//
				IF ( oNewImg:IsValid )
					IF ( SELF:oImg != NULL_OBJECT )
						SELF:oImg:Destroy()
					ENDIF
					//
					SELF:oImg := oNewImg
					Self:UpdateZoom()
					SELF:Invalidate()
				ENDIF
			ENDIF
			RETURN 
			
			
			// Drawing the Image
		protected virtual method OnPaint(e as System.Windows.Forms.PaintEventArgs) as void
			local matrix as System.Drawing.Drawing2D.Matrix
			local tmpRect as System.Drawing.Rectangle
			Local img as System.Drawing.Image 
			//
			if ((self:oImg == null) .OR. ( Self:oImg:IsValid != True ) )
				//
				Super:OnPaintBackground(e)
			else
				// Retrieve the underlying System.Drawing.Bitmap object
				img := Self:oImg:Image
				//
				matrix := Matrix{ (single)self:r8Zoom, 0, 0, (single)self:r8Zoom, 0, 0}
				matrix:Translate( (single)((real8)self:AutoScrollPosition:X  / self:r8Zoom), (single)((real8)self:AutoScrollPosition:Y  / self:r8Zoom))
				e:Graphics:Transform := matrix
				e:Graphics:InterpolationMode := System.Drawing.Drawing2D.InterpolationMode.High
				tmpRect := Rectangle{0, 0, img:Width, img:Height}
				e:Graphics:DrawImage(img, tmpRect, 0, 0, img:Width, img:Height, System.Drawing.GraphicsUnit.Pixel)
				//
				Super:OnPaint(e)
			endif
			
		protected virtual method OnPaintBackground( e as System.Windows.Forms.PaintEventArgs) as void
			return 
			
			
			
		access Zoom as real8
			//
			return self:r8Zoom
			
		assign Zoom(value as real8)
			//
			if (IIF(((value < 0) .or. (value < 1.0e-5)),1,0) != 0)
				//
				value := 1.0E-5
			endif
			self:r8Zoom := value
			self:UpdateZoom()
			self:Invalidate()
			
			
		private method UpdateZoom() as void
			local tmpSize as System.Drawing.Size
			Local img as Image
			//
			if ((self:oImg == null) .OR. ( Self:oImg:IsValid != True ) )
				//
				self:AutoScrollMargin := self:Size
			else
				img := Self:oImg:Image
				//
				tmpSize := Size{(Long)System.Math.Round((real8)((img:Width * self:r8Zoom) + 0.5) ) , (Long)System.Math.Round((real8)((img:Height * self:r8Zoom) + 0.5) ) }
				self:AutoScrollMinSize := tmpSize
			endif
			
	end class
	
END NAMESPACE 