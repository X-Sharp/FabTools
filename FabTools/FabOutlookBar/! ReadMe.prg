/* TEXTBLOCK !Fab ReadMe
/-*
Ported to Vulcan.NET in November, 2009
To compile that library, you MUST set 
implicit CLIPPER calling convention to FALSE

!!! WARNING !!!
The Style Access/Assign has been change to BarStyle when ported to Vulcan.NET

Fabrice Foray Added some features (fabrice@fabtoys.net)
To activate use the Style symbol property, and set to #FABSTYLE

written by Klaus Pietsch (KuM.Pietsch@t-online.de)
use & modify as you want and need

Based on GfxOutBarCtrl
Copyright (c) Iuri Apollonio 1998
http://www.codeguru.com

- Added a #New style
	Looks like Office 2003 ( a bit ! )
	 
*-/

*/
/* TEXTBLOCK Log
/-*
11.11.2000 KP
 - Start

21.12.2000 KP
 - Clipping für das Zeichnen der Items eingebaut, so dass jetzt auch "halbe" Items
   dargestellt werden
 - Item:HiLite: Clipping eingebaut

24.12.2000 KP
 - Zustand "gedrückt" für die Items eingebaut bei MouseButtonDown
 - MouseButtonUp über dem gedrückten Item benachrichtigt den Controlowner

28.12.2000 KP
 - Einige fürchterliche Ressourcen-Löcher gestopft. SaveDC/RestoreDC in DrawItems,
   einige vergessene ReleaseDCs und einige DeleteObjects (Pens).

30.12.2000 KP
 - Die Items zeichnen sich jetzt selbst.
 - Vorbereitet zum Scrollen. Ein Header hat jetzt Protects mit der Nummer des ersten
   und letzten sichtbaren Items.
 - Ein Header hat zwei logische Protects (UpArrow/DownArrow) mit denen festgelegt
   wird ob die Scrollpfeile gezeichnet werden
 - Die Scrollpfeile werden gezeichnet wenn notwendig

02.01.2001 KP
 - Aufgewacht von der Sylvesterpary
 - Scrolling für die Items funktioniert
 - Die Items haben jetzt auch Texte (mehrzeilig bei Bedarf)

05.01.2001 KP
 - Event "OLBItemClicked" dazugefügt
 - Event "OLBItemChanged" wird nur noch ausgelöst, wenn sich das Item wirklich ändert
 - Added some english comments
 - Released V 1.0 on KnowVo and VO-Forum

06.01.2001 KP
 - new Class OutlookBarElement as base class for all visible components

13.01.2001 KP
 - new Class WRect for easier handling of windows coordinates

27.01.2001 KP
 - The size of the images is no longer limited to 32x32 pixel. The size is now calculated
   from the Imagelist in the ImageList Assign.

10.02.2001 KP
 - New Method SetItemCaption( symItem ) to change the caption of an Item at runtime.
   Enhanced sample dialog to test this

27.04.2001 KP
 - new Method "Clone" for class WRect
 - changed OutlookBarItem:HitTest to avoid flicker if the mouse moves between an items
   bitmap and its caption

29.07.2001 KP
 - added screen update, when Outlookbar:BackgroundColor is set
   Enhanced sample window to test this
*-/


*/
/* TEXTBLOCK Todo
/-*
- add support for small iconview
- add support for individual context-menus (per item)

- just tell ;-)

*-/

*/
/* TEXTBLOCK !Fab Todo
/-*
- Adding Icons on Headers

*-/

*/
/* textblock What's New ?
/-*
V0408 ( April 2008 )
	.Added a new style, more "Office XP like"
		- You now have :
			#STDSTYLE
			#FABSTYLE
			#NEWSTYLE
				Be aware that in NewStyle, the Icon is on the left, and the text is on the right, 
					whereas in FABSTYLE and STDSTYLE Icon is at center and Text below
					 
			. To support this NEWSTYLE you now have :
			
			- OutlookBarHeader:GradientColor ( Clear Orange per Default )
				Color to start the Gradient Fill of the Header.
				The Gradient Fill is Vertical (lines of single color are drawn vertically ) and goes from GradientColor to :
						HiliteBackgroundColor, when selected, which is Orange per default
						BackgroundColor, when unselected, which is blue per default 
				!! This property is set when you create a Header, BUT it is also RESET when you change the style of OutlookBar
				
			- OutlookBarItem:GradientColor ( White per Default ) 
				Color to start the Gradient Fill of the Item.
				The Gradient Fill is Horizontal (lines of single color are draw Horizontally) and goes from GradientColor to :
						HiliteBackgroundColor, when selected, which is Orange per default
						BackgroundColor, when unselected, which is blue per default 
				!! This property is set when you create an Item, BUT it is also RESET when you change the style of OutlookBar
				
			- OutlookBar:HiliteBackgroundColor ( Orange per Default ) 
		
			- OutlookBar:BackgroundColor ( Blue per Default, Depends on the Theme used !! )
				Color used to draw the "empty" part of the bar
			
			- Outlookbar:IsItemsBoxed : ( True per default )
				If Set, a black rectangle is drawn around items button
				
			- Outlookbar:ItemsBackground ( Blue per Default, Depends on the Theme used !! )
				Items can have a different color than the bar, this color is also used to draw headers
				
				  
	

*-/
*/
