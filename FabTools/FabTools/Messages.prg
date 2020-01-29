// Messages.prg
using System.Windows.Forms

Function FabMessageInfo( ) as void
    FabMessageInfo( NULL, NULL )
return

Function FabMessageInfo( cText as string ) as void
    FabMessageInfo( cText, NULL )
return 

Function FabMessageInfo( cText as string, cTitle as string ) as void
    //
    if ( cText == NULL )
        cText := ""
    endif
    if ( cTitle == NULL )
        cTitle := "Information"
    endif
    //
    MessageBox.Show( cText, cTitle, MessageBoxButtons.OK, MessageBoxIcon.Information )
Return


Function FabMessageAlert( ) as void
    FabMessageAlert( NULL, NULL )
return

Function FabMessageAlert( cText as string ) as void
    FabMessageAlert( cText, NULL )
return 

Function FabMessageAlert( cText as string, cTitle as string ) as void
    //
    if ( cText == NULL )
        cText := ""
    endif
    if ( cTitle == NULL )
        cTitle := "Attention"
    endif
    //
    MessageBox.Show( cText, cTitle, MessageBoxButtons.OK, MessageBoxIcon.Exclamation )
Return