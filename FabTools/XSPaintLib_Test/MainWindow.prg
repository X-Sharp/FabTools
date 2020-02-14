USING System.Windows.Forms
USING FabPaintLib
PUBLIC PARTIAL CLASS MainWindow ;
    INHERIT System.Windows.Forms.Form
    PRIVATE METHOD openToolStripMenuItem_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        local oOD   AS  OpenFileDialog
        LOCAL oMP    AS    FabMultiPage
        //
        oOD := OpenFileDialog{}
        oOD:Filter := "All Pictures|*.bmp;*.jpg;*.pcx;*.tga;*.tif;*.png;*.pct;*.dib;*.gif" + ;
                        "|All files|*.*" + ;
                        "|BMP - OS/2 or Windows Bitmap|*.bmp" + ;
                        "|JPG - JPEG - JFIF Compliant|*.jpg" + ;
                        "|PCX - Zsoft Paintbrush|*.pcx" + ;
                        "|TGA - Truevision Targa|*.tga" + ;
                        "|TIF - Tagged Image File Format|*.tif" + ;
                        "|PNG - Portable Network Graphics|*.png" + ;
                        "|PCT - Macintosh PICT|*.pct" + ;
                        "|DIB - OS/2 or Windows DIB|*.dib" + ;
                        "|GIF - GIF File|*.gif"
        if ( oOD:ShowDialog() == DialogResult.OK )
            // MultiPage File ?
            oMP := FabMultiPage{ (String) oOD:FileName }
            IF oMP:IsValid
                // 
                SELF:DoOpenFile(oOD:FileName )
            ELSE
                // No, try as a standard file....
                SELF:DoOpenFile(oOD:FileName )
            ENDIF
            //
        ENDIF   
    
        RETURN
VIRTUAL METHOD DoOpenFile( cFileName AS System.String ) AS System.Void
        //
        SELF:fabPaintLib_Control21:Image := FabPaintLib{ cFileName }
        SELF:zoomToolStripMenuItem:Enabled := TRUE
     Return
PRIVATE METHOD toolStripMenuItem100_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:fabPaintLib_Control21:Zoom := 1
        RETURN
PRIVATE METHOD toolStripMenuItem200_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:fabPaintLib_Control21:Zoom := 2
        RETURN
PRIVATE METHOD toolStripMenuItem300_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:fabPaintLib_Control21:Zoom := 3
        RETURN
PRIVATE METHOD toolStripMenuItem75_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:fabPaintLib_Control21:Zoom := 0.75
        RETURN
PRIVATE METHOD toolStripMenuItem50_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        SELF:fabPaintLib_Control21:Zoom := 0.5
        RETURN

END CLASS 
