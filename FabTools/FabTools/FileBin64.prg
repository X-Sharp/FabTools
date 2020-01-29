/*
textblock !Read-Me
/-*
An OOP way to access any "binary" file.
With an auto-close feature using the Axit() method.
CLASS FabFileBin64 inherit from FabFileBin.
It uses SetFilePointer to avoid 2GB limitations. Be carefull FabFileBin64 use Real8 type
to manage big files. 2Gb limitations came from VO FSeek and FTell, so you will find that
some functions were overwritten.

The code is based on fragmented information found it at http://msdn.microsoft.com

*-/

*/
#region DEFINES
DEFINE _2GB := 2147483648
#endregion

CLASS FabFileBin64                                              INHERIT FabFileBin
//l Class to access File in a OOP way without 2GB limit. Inherit from FabFileBin.
//g Files, Files Related Classes/Functions

	PROTECT		r8Size			as	REAL8	//++


PROTECT METHOD __UpdateSize() as USUAL PASCAL 
	LOCAL r8Current	as	REAL8
	//
	r8Current := self:Position
	//
	self:r8Size := self:GoBottom()
	//
	self:Goto( r8Current )
	//
RETURN	self:r8Size


METHOD FTell64( ) as USUAL PASCAL 
	LOCAL r8Position as REAL8
	r8Position := self:Seek64( 0, FILE_CURRENT )
RETURN r8Position	


METHOD GoBottom() as USUAL PASCAL 
//p Set the file pointer at the end-of-file.
//r The position of the file pointer as a longint value after the operation
	LOCAL r8Position as REAL8
	r8Position  := self:Seek64( 0, FS_END )
RETURN r8Position


METHOD GoTo( nOffset as USUAL ) as USUAL PASCAL 
//p Move the file pointer to a specified position
//r The position of the file pointer as a longint value after the operation
	LOCAL r8Position as REAL8
	r8Position := self:Seek64( nOffset, FS_SET )
RETURN  r8Position


METHOD GoTop() as USUAL PASCAL 
//p Set the file pointer at the begin-of-file.
//r The position of the file pointer as a longint value after the operation
	LOCAL r8Position as REAL8
	r8Position := self:Seek64( 0, FS_SET )
RETURN r8Position	


METHOD I64Exp()                                                 
RETURN (POW( 2, 31 )- 1)


METHOD Seek( nOffset as USUAL, nOrigin as DWORD ) as USUAL PASCAL  
//p Move the File pointer to a specified position
//x <nOffset>	The number of bytes to move the file pointer, from the position defined by <nOrigin>.  It can be a positive or negative number.  A positive number moves the pointer forward in the file, and a negative number moves the pointer backward.  If <nOrigin> is the end-of-file, <nOffset> must be 0 or negative.\line
//x <nOrigin>	One of the following constants indicating the starting location of the file pointer, telling where to start searching the file
	LOCAL r8Position as REAL8
	r8Position := self:Seek64( nOffset, nOrigin )
RETURN  r8Position


METHOD Seek64( nOffset as USUAL, nOrigin as DWORD ) as USUAL PASCAL 
//p Move the File pointer to a specified position
//x <nOffset>	The number of bytes to move the file pointer, from the position defined by <nOrigin>.  It can be a positive or negative number.  A positive number moves the pointer forward in the file, and a negative number moves the pointer backward.  If <nOrigin> is the end-of-file, <nOffset> must be 0 or negative.\line
//x <nOrigin>	One of the following constants indicating the starting location of the file pointer, telling where to start searching the file
	//LOCAL dwPointer AS DWORD
	LOCAL dwError    as DWORD
	LOCAL r8Return   as REAL8
    LOCAL dwPointer  as DWORD

	LOCAL r          is I64Rec

    F2Int64( nOffset, @r )

    r8Return    := 0.00
    dwPointer   := 0

	IF self:IsOpen

	    IF self:Size > self:I64Exp()
   	        dwPointer := SetFilePointer(self:FileHandle, r.Lo, @r.Hi, nOrigin)
   	    ELSE
            dwPointer := SetFilePointer(self:FileHandle, r.Lo, null_ptr, nOrigin)
        ENDIF
		
		// if we failed ...
        IF (dwPointer == 0xFFFFFFFF  .and. (dwError := GetLastError()) != NO_ERROR )
            //Show the error code
            //FabMessageAlert(dwError,"Function Seek() Error")

            // deal with that failure
            //SELF:UpdateError()
            self:dwErrorCode := ERROR_SEEK

            r8Return := -1
        ELSE
            r8Return := dwPointer
        ENDIF
	ELSE
		self:dwErrorCode := ERROR_INVALID_HANDLE	// Invalid Handle
	ENDIF

RETURN  r8Return


ACCESS	Size as USUAL PASCAL 
//r The Size of File
RETURN self:r8Size


METHOD Tell() as USUAL PASCAL  
//r The current file pointer position
	LOCAL r8Pos as	REAL8
	//
	IF self:IsOpen
		r8Pos := self:FTell64()
	ELSE
		self:dwErrorCode := ERROR_INVALID_HANDLE	// Invalid Handle
	ENDIF
RETURN r8Pos


END CLASS
FUNCTION F2Int64( fNumber as USUAL, _struInt64 as I64Rec ) as void
// F2Int64
// Store a float number into two long values.
// This is the way to store big numbers into 64 bits.
// The code is based on fragmented information found it at http://msdn.microsoft.com
//
/*
        -1 ==> Lo:-1           Hi:-1
        -2 ==> Lo:-2           Hi:-1
        -3 ==> Lo:-3           Hi:-1
        -4 ==> Lo:-4           Hi:-1

2147483646 ==> Lo: 2147483646  Hi: 0
2147483647 ==> Lo: 2147483647  Hi: 0
2147483648 ==> Lo:-2147483648  Hi: 0
2147483649 ==> Lo:-2147483647  Hi: 0
2147483650 ==> Lo:-2147483646  Hi: 0

4294967293 ==> Lo:-3           Hi: 0
4294967294 ==> Lo:-2           Hi: 0
4294967295 ==> Lo:-1           Hi: 0
4294967296 ==> Lo: 0           Hi: 1
4294967297 ==> Lo: 1           Hi: 1
4294967298 ==> Lo: 2           Hi: 1
4294967299 ==> Lo: 3           Hi: 1
*/
    LOCAL lIsNeg      as LOGIC
    LOCAL r8AbsNumber as REAL8
    LOCAL r           is I64Rec

    // Is number negative)?
    lIsNeg      := ( fNumber < 0 )

    // asure we work with a positive number
    r8AbsNumber := Abs(fNumber)

    // obtain the 2Gb exponent ( _2GB^x )
    r.Hi        := Integer( r8AbsNumber / _2GB )

    // and the modulus is. As you can see MOD can't do it.
    r.Lo        := LONG(r8AbsNumber - REAL8(r.Hi)*_2GB) // MOD( r8AbsNumber , _2GB )

    // the easy part was do it.
    // As you can see in the test  Lo: 0 Hi: 1 is 2*2GB. So now we have to adjust
    // to recreate all range number. Perhaps there is another way to do the same.
    IF (r.Hi == 1)
       r.Lo := _or( r.Lo, - _2GB )
    ENDIF
    r.Hi := Integer(r.Hi / 2)

    // and if number is negative, we have to perform a
    // binary Not (inverse) on both values, and then add 1 to the lower half
    IF lIsNeg
       r.Lo       := _not(r.Lo)  + 1
       r.Hi       := _not(r.Hi)
    ENDIF

    // save the results into the structure
    _struInt64.Lo   := r.Lo
    _struInt64.Hi   := r.Hi

RETURN


VOSTRUCT I64Rec
   MEMBER Lo as LONG
   MEMBER Hi as LONG



