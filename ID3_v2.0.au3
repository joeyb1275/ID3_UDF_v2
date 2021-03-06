#include-once
#include <Array.au3>
#include <String.au3>
#include <File.au3>

Dim $ID3Filenames = "",$AlbumArtFilename = ""
Dim $avID3BufferArray[1] = [0];use to buffer ID3 Data

;FrameID Definitions:	(Frame ID Definitions - not all may work)
;~ 	<Header for 'Replay Gain Adjustment', ID: "RGAD">
;~         Peak Amplitude                          $xx $xx $xx $xx
;~         Radio Replay Gain Adjustment            $xx $xx
;~         Audiophile Replay Gain Adjustment       $xx $xx

;~         Header consists of:
;~         Frame ID                $52 $47 $41 $44 = "RGAD"
;~         Size                    $00 $00 $00 $08
;~         Flags                   $40 $00         (%01000000 %00000000)

;~         In the RGAD frame, the flags state that the frame should be preserved if the ID3v2 
;~         tag is altered, but discarded if the audio data is altered.
;~ TDRC
;~    The 'Recording time' frame contains a timestamp describing when the
;~    audio was recorded. Timestamp format is described in the ID3v2
;~    structure document [ID3v2-strct].

;~ AENC Audio encryption
;~ APIC Attached picture
;~ COMM Comments
;~ COMR Commercial frame
;~ ENCR Encryption method registration
;~ EQUA Equalization
;~ ETCO Event timing codes
;~ GEOB General encapsulated object
;~ GRID Group identification registration
;~ IPLS Involved people list
;~ LINK Linked information
;~ MCDI Music CD identifier
;~ MLLT MPEG location lookup table
;~ OWNE Ownership frame
;~ PRIV Private frame
;~ PCNT Play counter
;~ POPM Popularimeter
;~ POSS Position synchronisation frame
;~ RBUF Recommended buffer size
;~ RVAD Relative volume adjustment
;~ RVRB Reverb
;~ SYLT Synchronized lyric/text
;~ SYTC Synchronized tempo codes
;~ TALB Album/Movie/Show title
;~ TBPM BPM (beats per minute)
;~ TCOM Composer
;~ TCON Content type
;~ TCOP Copyright message
;~ TDAT Date
;~ TDLY Playlist delay
;~ TENC Encoded by
;~ TEXT Lyricist/Text writer
;~ TFLT File type
;~ TIME Time
;~ TIT1 Content group description
;~ TIT2 Title/songname/content description
;~ TIT3 Subtitle/Description refinement
;~ TKEY Initial key
;~ TLAN Language(s)
;~ TLEN Length
;~ TMED Media type
;~ TOAL Original album/movie/show title
;~ TOFN Original filename
;~ TOLY Original lyricist(s)/text writer(s)
;~ TOPE Original artist(s)/performer(s)
;~ TORY Original release year
;~ TOWN File owner/licensee
;~ TPE1 Lead performer(s)/Soloist(s)
;~ TPE2 Band/orchestra/accompaniment
;~ TPE3 Conductor/performer refinement
;~ TPE4 Interpreted, remixed, or otherwise modified by
;~ TPOS Part of a set
;~ TPUB Publisher
;~ TRCK Track number/Position in set
;~ TRDA Recording dates
;~ TRSN Internet radio station name
;~ TRSO Internet radio station owner
;~ TSIZ Size
;~ TSRC ISRC (international standard recording code)
;~ TSSE Software/Hardware and settings used for encoding
;~ TYER Year
;~ TXXX User defined text information frame
;~ UFID Unique file identifier
;~ USER Terms of use
;~ USLT Unsychronized lyric/text transcription
;~ WCOM Commercial information
;~ WCOP Copyright/Legal information
;~ WOAF Official audio file webpage
;~ WOAR Official artist/performer webpage
;~ WOAS Official audio source webpage
;~ WORS Official internet radio station homepage
;~ WPAY Payment
;~ WPUB Publishers official webpage
;~ WXXX User defined URL link frame 




; #FUNCTION# ;===============================================================================
;
; Name...........: _ID3ReadTag
; Description ...: Reads ID3v1.0, ID3v1.1, ID3v2.3, ID3v2.2 and can return an array of all fields or use _ID3GetTagField()
;					to after calling _ID3ReadTag() to get each frames data seperately.
; Syntax.........: _ID3ReadTag($sFilename [, $iVersion = 0 [, $sFilter = -1 [, $iReturnArray = 0]]])
; Parameters ....: $sFilename - String of the filename including path of mp3 file to read
;                   $iVersion - ID3 Version to read
;						|0 - Read ID3v1 & ID3v2 (Default)
;						|1 - Read ID3v1 only
;						|2 - Read ID3v2 only
;                   $sFilter - ID3v2 Frame Filter as a pipe delimited string of FrameIDs (ie. "TIT2|TALB|TPE1|TYER|APIC")
;						|-1 - Read All Frames (Default)
;						|See Above listing of possible values for FrameIDs
;					$fRetArray - Boolean value to request a string formatted array of the requested frames data.
;						|False - Do not return Array (Default)
;						|True - Return Array
; Return values .: Success - Returns 1 if $fRetArray = Flase or returns an array of tag fields and data if $fRetArray = True.
;                  Failure - 0 and Sets @error = -1 for end-of-file, @error = 1 for other errors
;                  	|0 - No error.
;                  	|1 - Invalid $sType
;                  	|2 - Invalid $sStartDate
;                  	|3 - Invalid $sEndDate
; Author ........: joeyb1275
; Modified.......:
; Remarks .......:
; Related .......: _ID3GetTagField, _ID3SetTagField, _ID3RemoveField, _ID3WriteTag
; Link ..........; http://www.id3.org/Home
; Example .......; Yes
;
; ;==========================================================================================
Func _ID3ReadTag($sFilename, $iVersion = 0, $sFilter = -1, $fRetArray = False)
	
	If Not(FileExists($sFilename)) Then Return 0
	Dim $avID3BufferArray[1] = [0]  ;clear Buffer
	Switch $iVersion
		Case 0
			_ReadID3v2($sFilename,$avID3BufferArray,$sFilter)
			_ReadID3v1($sFilename,$avID3BufferArray)
		Case 1
			_ReadID3v1($sFilename,$avID3BufferArray)
		Case 2
			_ReadID3v2($sFilename,$avID3BufferArray,$sFilter)
	EndSwitch
	
	;Add Filename to buffer
	;****************************************************************************************
	_ArrayAdd($avID3BufferArray,$sFilename) 
	$avID3BufferArray[0] += 1
	SetError(0)
	;****************************************************************************************
	
	;Setup simple array to return (IF $iRetArray = True)
	;****************************************************************************************
	If $fRetArray Then
		Local $asID3Array[1] = [0]
		For $i = 3 To $avID3BufferArray[0]
			Dim $asID3FrameArray = StringSplit($avID3BufferArray[$i], "|")
			_ArrayAdd($asID3Array,$asID3FrameArray[1] & "|" & _ID3GetTagData($asID3FrameArray[1]))
			$asID3Array[0] += 1
		Next
		Return $asID3Array
	Else
		Return 1
	EndIf
	;****************************************************************************************
	
EndFunc


;===============================================================================
; Function Name:    _ID3GetTagField()
; Description:      Reads the ID3 Tag Data from an mp3 file and stores it in a Buffer and returns the Field Requested
; Parameter(s):     $Filename 			- Filename of mp3 file include full path
;					$sFieldIDRequest	- ID3 Field ID String of the Field to return (ie. "TIT2" for ID3v2 Title or "Title" for ID3v1 Title)
; Requirement(s):   None
; Return Value(s):  On Success - Returns Field String. If multiple fields found string is delimited with @CRLF.
;						@error = 0; @extended = number of fields found (ID3v2 can have multiple COMM Fields)
;                   On Failure - Returns Empty String meaning $sFieldIDRequest did not match any IDs in the mp3 File
;						@error = 1; @extended = 0
;===============================================================================
Func _ID3GetTagData($sFrameIDRequest)  ;add support for ID3v2.2

	;Check $avID3BufferArray; If $avID3BufferArray is empty then set error and return
	;****************************************************************************************
	If $avID3BufferArray[0] == 0 Then
		SetError(1)
		Return ""
	EndIf
	;****************************************************************************************

	Local $sFrameID, $sFrameData = "", $fFrameFound = False, $iNumFound = 0
	
	;Search for $sFieldIDRequest in $avID3BufferArray to get specified frame data from buffer
	;****************************************************************************************
	Dim $iDataIndex = 0
	For $i = 1 To $avID3BufferArray[0]
		$asBufferFrameString = StringSplit($avID3BufferArray[$i],"|")
		If $asBufferFrameString[0] > 1 Then
			$sFrameID = $asBufferFrameString[1]
			
			If $sFrameID == $sFrameIDRequest Then
				$fFrameFound = True
				$iNumFound += 1
				$iDataIndex = $i
				ExitLoop
			EndIf
			
		EndIf
	Next
	;****************************************************************************************

	If $fFrameFound Then
		$sFrameData = _GetID3FrameString($avID3BufferArray[$iDataIndex])
	EndIf

	;Set Error and Extended Macros
	SetError(Not($fFrameFound),$iNumFound)
	
	Return $sFrameData
	
EndFunc

; #FUNCTION# ;===============================================================================
;
Func _ID3GetTagString($sFrameIDRequest)
	;Check $avID3BufferArray; If $avID3BufferArray is empty then set error and return
	;****************************************************************************************
	If $avID3BufferArray[0] == 0 Then
		SetError(1)
		Return ""
	EndIf
	;****************************************************************************************

	Local $sFrameID, $sFrameString = "", $fFrameFound = False, $iNumFound = 0
	
	;Search for $sFieldIDRequest in $avID3BufferArray to get specified frame data from buffer
	;****************************************************************************************
	Dim $iDataIndex = 0
	For $i = 1 To $avID3BufferArray[0]
		$asBufferFrameString = StringSplit($avID3BufferArray[$i],"|")
		If $asBufferFrameString[0] > 1 Then
			$sFrameID = $asBufferFrameString[1]
			
			If $sFrameID == $sFrameIDRequest Then
				$fFrameFound = True
				$iNumFound += 1
				$iDataIndex = $i
				;ExitLoop
			EndIf
			
		EndIf
	Next
	;****************************************************************************************

	If $fFrameFound Then
		$sFrameString = _GetID3FrameString($avID3BufferArray[$iDataIndex])
	EndIf

	;Set Error and Extended Macros
	SetError(Not($fFrameFound),$iNumFound)
	
	Return $sFrameString
EndFunc

; #FUNCTION# ;===============================================================================
;
; Name...........: _ID3SetTagData
; Description ...: Set the Frame Data in the buffer to value requested.  Call _ID3WriteTag() to save new data to mp3 file.
; Syntax.........: _ID3SetTagData($sFrameIDRequest, $vFrameData [, $sDataType = -1])
; Parameters ....: $sFrameIDRequest - String of the FrameID to edit
;                  $vFrameData - The data to set the Frame Data to. It can have multiple formats.
;						|0 - Read ID3v1 & ID3v2 (Default)
;						|1 - Read ID3v1 only
;						|2 - Read ID3v2 only
;                   $sDataType - ID3v2 Frame Filter as a pipe delimited string of FrameIDs (ie. "TIT2|TALB|TPE1|TYER|APIC")
;						|-1 - Read All Frames (Default)
;						|See Above listing of possible values for FrameIDs
; Return values .: Success - Returns 1 if $fRetArray = Flase or returns an array of tag fields and data if $fRetArray = True.
;                  Failure - 0 and Sets @error = -1 for end-of-file, @error = 1 for other errors
;                  	|0 - No error.
;                  	|1 - Invalid $sType
;                  	|2 - Invalid $sStartDate
;                  	|3 - Invalid $sEndDate
; Author ........: joeyb1275
; Modified.......:
; Remarks .......:
; Related .......: _ID3ReadTag, _ID3GetTagField, _ID3RemoveField, _ID3WriteTag
; Link ..........; http://www.id3.org/Home
; Example .......; Yes
;
; ;==========================================================================================
Func _ID3SetTagData($sFrameIDRequest, $vFrameData, $sDataType = -1)
		
	Local $FrameID = ""
	Local $FrameIDFound = False, $TagSize = 0
	Local $ArrayIndex = 0, $TagSizeIndex = 0
		
	;Get specified field from buffer
	;****************************************************************************************
	For $i = 1 To $avID3BufferArray[0]
		$aBufferFrameString = StringSplit($avID3BufferArray[$i],"|")
		If $aBufferFrameString[0] > 1 Then
			$FrameID = $aBufferFrameString[1]
			If $FrameID == "TagSize" Then
				$TagSize = Number($aBufferFrameString[2])
				$TagSizeIndex = $i
			EndIf
			If $FrameID == $sFrameIDRequest Then
				$FrameIDFound = True
				$ArrayIndex = $i
				ExitLoop
			EndIf
		EndIf
	Next
	;****************************************************************************************
	
	;Change Frame Data and Size (Need to add all Frame Types)
	;****************************************************************************************
	If Not $FrameIDFound Then
		_ArrayAdd($avID3BufferArray,"")
		$avID3BufferArray[0] += 1
		$ArrayIndex = $avID3BufferArray[0]
		$FrameID = $sFrameIDRequest
	EndIf
	
		If (StringMid($FrameID,1,1) == "T") and (StringLen($FrameID) == 4) and ($FrameID <> "TXXX") Then
;~ 			<Header for 'Text information frame', ID: "T000" - "TZZZ",
;~      		excluding "TXXX" described in 4.2.2.>
;~      		Text encoding                $xx
;~      		Information                  <text string according to encoding>
			$bFrameData = Binary("0x00") ;Text Encoding
			$bFrameData &= StringToBinary($vFrameData)
			$avID3BufferArray[$ArrayIndex] = $FrameID & "|" & $bFrameData & "|" & BinaryLen($bFrameData)
		Elseif $FrameID == "TXXX" Then
;~ 			<Header for 'User defined text information frame', ID: "TXXX">
;~      		Text encoding     $xx
;~      		Description       <text string according to encoding> $00 (00)
;~      		Value             <text string according to encoding>
			$bFrameData = Binary("0x00") ;Text Encoding
			$bFrameData = Binary("0x00") ;Description
			$bFrameData &= StringToBinary($vFrameData)
			$avID3BufferArray[$ArrayIndex] = $FrameID & "|" & $bFrameData & "|" & BinaryLen($bFrameData)
			
		ElseIf (StringMid($FrameID,1,1) == "W") and (StringLen($FrameID) == 4) and ($FrameID <> "WXXX") Then
;~ 			<Header for 'URL link frame', ID: "W000" - "WZZZ", excluding "WXXX"
;~      		described in 4.3.2.>
;~      		URL              <text string>
			$bFrameData = StringToBinary($vFrameData)
			$avID3BufferArray[$ArrayIndex] = $FrameID & "|" & $bFrameData & "|" & BinaryLen($bFrameData)
		ElseIf $FrameID == "WXXX" Then
;~ 			<Header for 'User defined URL link frame', ID: "WXXX">
;~      		Text encoding     $xx
;~      		Description       <text string according to encoding> $00 (00)
;~      		URL               <text string>
			$bFrameData = Binary("0x00") ;Text Encoding
			$bFrameData = Binary("0x00") ;Description
			$bFrameData &= StringToBinary($vFrameData)
			$avID3BufferArray[$ArrayIndex] = $FrameID & "|" & $bFrameData & "|" & BinaryLen($bFrameData)
			
		Else
			
			Switch $FrameID
				Case "COMM"
;~ 					<Header for 'Comment', ID: "COMM">
;~      				Text encoding          $xx
;~      				Language               $xx xx xx
;~      				Short content descrip. <text string according to encoding> $00 (00)
;~      				The actual text        <full text string according to encoding>
					$bFrameData = Binary("0x00") ;Text Encoding
					$bFrameData &= StringToBinary("eng") ;Language (eng ONLY)
					$bFrameData &= Binary("0x00") ;Short content descrip. (NONE)
					$bFrameData &= StringToBinary($vFrameData)
					$avID3BufferArray[$ArrayIndex] = $FrameID & "|" & $bFrameData & "|" & BinaryLen($bFrameData)
				Case "APIC"
;~ 					 <Header for 'Attached picture', ID: "APIC">
;~ 						Text encoding      $xx
;~ 						MIME type          <text string> $00
;~ 						Picture type       $xx
;~ 						Description        <text string according to encoding> $00 (00)
;~ 						Picture data       <binary data>
					$bFrameData = Binary("0x00") ;Text Encoding
					$bFrameData &= StringToBinary("image/jpg") & Binary("0x00") ;MIME type (JPEG ONLY)
					$bFrameData &= Binary("0x03") ;Picture type ($03  Cover (front) ONLY)
					$bFrameData &= StringToBinary("Cover Image") & Binary("0x00") ;Description
					$FrameSize = FileGetSize($vFrameData) + BinaryLen($bFrameData)
					$avID3BufferArray[$ArrayIndex] = $FrameID & "|" & $bFrameData & "|" & $vFrameData & "|" & $FrameSize
				Case "USLT"
;~ 					<Header for 'Unsynchronised lyrics/text transcription', ID: "USLT">
;~      				Text encoding        $xx
;~      				Language             $xx xx xx
;~      				Content descriptor   <text string according to encoding> $00 (00)
;~      				Lyrics/text          <full text string according to encoding>
					$bFrameData = Binary("0x00") ;Text Encoding
					$bFrameData &= StringToBinary("eng") ;Language (eng ONLY)
					$bFrameData &= Binary("0x00") ;Content descriptor (NONE)
					$FrameSize = FileGetSize($vFrameData) + BinaryLen($bFrameData)
					$avID3BufferArray[$ArrayIndex] = $FrameID & "|" & $bFrameData & "|" & $vFrameData & "|" & $FrameSize
				Case "UFID" ;Not Implimented Yet
;~ 					<Header for 'Unique file identifier', ID: "UFID">
;~      				Owner identifier        <text string> $00
;~      				Identifier              <up to 64 bytes binary data>

			EndSwitch
			
		EndIf
	;****************************************************************************************
	
	
EndFunc

Func _ID3RemoveField($sFieldIDRequest)
	
	Local $FrameID = ""
	Local $FrameIDFound = False, $TagSize = 0
	Local $ArrayIndex = 0, $TagSizeIndex = 0
		
	;Get specified field from buffer
	;****************************************************************************************
	For $i = 1 To $avID3BufferArray[0]
		$aBufferFrameString = StringSplit($avID3BufferArray[$i],"|")
		If $aBufferFrameString[0] > 1 Then
			$FrameID = $aBufferFrameString[1]
			If $FrameID == "TagSize" Then
				$TagSize = Number($aBufferFrameString[2])
				$TagSizeIndex = $i
			EndIf
			If $FrameID == $sFieldIDRequest Then
				$FrameIDFound = True
				$ArrayIndex = $i
				ExitLoop
			EndIf
		EndIf
	Next
	;****************************************************************************************
	
	If $FrameIDFound Then
		_ArrayDelete($avID3BufferArray,$ArrayIndex)
		$avID3BufferArray[0] -= 1
	EndIf
	
	
EndFunc


;actually writes the tag
Func _ID3WriteTag($Filename,$iFlag = 0)
	
	Switch $iFlag
		Case 0 ;Wite both ID3v1 and ID3v2 Tags
			$TagFile = StringTrimRight($Filename,4) & "_ID3TAG.mp3"
			_FileCreate($TagFile)
			
			Local $OldTagSize = 0, $ID3v1Tag = StringToBinary("TAG"),  $ID3v1_Artist = ""
			Local $ID3v1_Title = "",$ID3v1_Album = "",$ID3v1_Year = "",$ID3v1_Comment = ""
			Local $ID3v1_Genre = "", $ID3v1_Track = ""
			
			$hTagFile = Fileopen($TagFile,1) ;append
			
			;Write ID3
			FileWrite($TagFile,StringToBinary("ID3"))
			
			;Write Version (Assume ID3v2.3)
			;****************************************************************************************
			FileWrite($TagFile,Binary("0x" & Hex(Number(3),2)))
			FileWrite($TagFile,Binary("0x" & Hex(Number(0),2)))
			;****************************************************************************************

 			;Write Flags (Assume all zero)
			;****************************************************************************************
			FileWrite($TagFile,Binary("0x00"))
			;****************************************************************************************
			
			;Calculate new TagSize
			;****************************************************************************************
			Dim $NewTagSize = 0
			For $i = 1 To $avID3BufferArray[0]
				$aBufferFrameString = StringSplit($avID3BufferArray[$i],"|")
				If $aBufferFrameString[0] > 2 Then
					$NewTagSize += Number($aBufferFrameString[$aBufferFrameString[0]]) + 10
				EndIf
				If $aBufferFrameString[1] == "ZPAD" Then
					$NewTagSize += Number($aBufferFrameString[$aBufferFrameString[0]])
				EndIf
			Next
;~ 			MsgBox(0,"$NewTagSize",$NewTagSize)
			;****************************************************************************************
			
			;Write TagSize (4 byte number)
			;****************************************************************************************
			$sTagSize = $NewTagSize
			$iTagSize = Hex($NewTagSize)
			$bTagSize = _HexToBin_ID3($iTagSize)
			$bTagSize = _StringReverse($bTagSize)
			$bTagSize = StringLeft($bTagSize,28)
			$TagHeaderBin = StringMid($bTagSize,1,7) & "0" & StringMid($bTagSize,8,7) & "0" & _
							StringMid($bTagSize,15,7) & "0" & StringMid($bTagSize,22,7) & "0"
			$TagHeaderBin = _StringReverse($TagHeaderBin)			
			$TagHeader = _BinToHex_ID3($TagHeaderBin)
			FileWrite($TagFile,Binary("0x" & $TagHeader))
			;****************************************************************************************
			
			;Write Frames to File
			;****************************************************************************************
			For $i = 1 To $avID3BufferArray[0]
				$aBufferFrameString = StringSplit($avID3BufferArray[$i],"|")
				If $aBufferFrameString[1] == "ZPAD" Then
					Dim $ZPAD = Binary("0x00")
					For $iZPAD = 2 to Number($aBufferFrameString[$aBufferFrameString[0]])
						$ZPAD &= Binary("0x00")
					Next
					$NewTagSize += Number($aBufferFrameString[$aBufferFrameString[0]])
				ElseIf $aBufferFrameString[1] == "TagSize" Then
					$OldTagSize = Number($aBufferFrameString[2])
					;MsgBox(0,"$OldTagSize",$OldTagSize)
				ElseIf $aBufferFrameString[1] == "Title" Then
					$ID3v1_Title = StringToBinary(StringLeft($aBufferFrameString[2],30))
					for $iPAD = 1 to (30 - BinaryLen($ID3v1_Title))
						$ID3v1_Title &= Binary("0x00")
					Next
				ElseIf $aBufferFrameString[1] == "Artist" Then
					$ID3v1_Artist = StringToBinary(StringLeft($aBufferFrameString[2],30))
					for $iPAD = 1 to (30 - BinaryLen($ID3v1_Artist))
						$ID3v1_Artist &= Binary("0x00")
					Next
				ElseIf $aBufferFrameString[1] == "Album" Then
					$ID3v1_Album = StringToBinary(StringLeft($aBufferFrameString[2],30))
					for $iPAD = 1 to (30 - BinaryLen($ID3v1_Album))
						$ID3v1_Album &= Binary("0x00")
					Next
				ElseIf $aBufferFrameString[1] == "Year" Then
					$ID3v1_Year = StringToBinary(StringLeft($aBufferFrameString[2],4))
					
				ElseIf $aBufferFrameString[1] == "Comment" Then
					$ID3v1_Comment = StringToBinary(StringLeft($aBufferFrameString[2],28)) ;28 bytes for ID3v1.1
					for $iPAD = 1 to (28 - BinaryLen($ID3v1_Comment))
						$ID3v1_Comment &= Binary("0x00")
					Next
				ElseIf $aBufferFrameString[1] == "Track" Then
					$ID3v1_Track = StringLeft($aBufferFrameString[2],3)
				ElseIf $aBufferFrameString[1] == "Genre" Then
					$ID3v1_Genre = $aBufferFrameString[2]
				EndIf
				
				If $aBufferFrameString[0] > 2 Then
					
					If $aBufferFrameString[1] == "APIC" Then
					
						FileWrite($TagFile,StringToBinary($aBufferFrameString[1]))
						FileWrite($TagFile,Binary("0x" & Hex($aBufferFrameString[$aBufferFrameString[0]],8))) ;FrameSize
						FileWrite($TagFile,Binary("0x" & Hex(0,2)))	;FrameFlag1
						FileWrite($TagFile,Binary("0x" & Hex(0,2)))	;FrameFlag2
						FileWrite($TagFile,Binary($aBufferFrameString[2]))
						$PicFile_h = FileOpen($aBufferFrameString[3], 16) ;force binary
						$WriteError = FileWrite($TagFile,FileRead($PicFile_h))
						FileClose($PicFile_h)
					
					
					ElseIf $aBufferFrameString[1] == "USLT" Then
					
						FileWrite($TagFile,StringToBinary($aBufferFrameString[1]))
						FileWrite($TagFile,Binary("0x" & Hex($aBufferFrameString[$aBufferFrameString[0]],8))) ;FrameSize
						FileWrite($TagFile,Binary("0x" & Hex(0,2)))	;FrameFlag1
						FileWrite($TagFile,Binary("0x" & Hex(0,2)))	;FrameFlag2
						FileWrite($TagFile,Binary($aBufferFrameString[2]))
						$LyricsFile_h = FileOpen($aBufferFrameString[3], 16) ;force binary
						$LyricData = FileRead($LyricsFile_h)
						$WriteError = FileWrite($TagFile,$LyricData)
						FileClose($LyricsFile_h)
					
					Else
					
						FileWrite($TagFile,StringToBinary($aBufferFrameString[1]))
						FileWrite($TagFile,Binary("0x" & Hex($aBufferFrameString[$aBufferFrameString[0]],8))) ;FrameSize
						FileWrite($TagFile,Binary("0x" & Hex(0,2)))	;FrameFlag1
						FileWrite($TagFile,Binary("0x" & Hex(0,2)))	;FrameFlag2
						FileWrite($TagFile,Binary($aBufferFrameString[2]))	;Frame Data
					
					EndIf
					$NewTagSize += Number($aBufferFrameString[$aBufferFrameString[0]]) + 10
					
				EndIf
			Next
			;****************************************************************************************
			
			;Write Tag Padding
			;****************************************************************************************
			FileWrite($TagFile,$ZPAD)
			;****************************************************************************************
			
			;Write MP3 Data
			;****************************************************************************************
			$hFile = FileOpen($Filename,16) 		;read force binary
			FileRead($hFile,$OldTagSize) 			;read past Old Tag
			FileWrite($hTagFile,FileRead($hFile,FileGetSize($Filename) - 128 - $OldTagSize))	;Write the mp3 data 
			;****************************************************************************************
			
			;Write ID3v1.1 Tag
			;****************************************************************************************
			$ID3v1Tag &= $ID3v1_Title
			$ID3v1Tag &= $ID3v1_Artist
			$ID3v1Tag &= $ID3v1_Album
			$ID3v1Tag &= $ID3v1_Year
			$ID3v1Tag &= $ID3v1_Comment
			$ID3v1Tag &= Binary("0x00")
			$ID3v1Tag &= Binary("0x" & Hex(Number($ID3v1_Track),2))
			$ID3v1Tag &= Binary("0x" & Hex(_GetGenreID($ID3v1_Genre),2))
			FileWrite($hTagFile,$ID3v1Tag)
			;****************************************************************************************

			FileClose($hFile)		
			FileClose($hTagFile)
			
			FileCopy($TagFile,$Filename,1)
			FileDelete($TagFile)
	EndSwitch
	
	
	
EndFunc


;===============================================================================
; Function Name:    _ID3DeleteFiles()
; Description:      Deletes any files created by ID3.au3 (ie. AlbumArt.jpeg and SongLyrics.txt)
; Parameter(s):     None
; Requirement(s):   None
; Return Value(s):  On Success - Returns 1.
;                   On Failure - Returns 0 
;===============================================================================
Func _ID3DeleteFiles()
	
	If $ID3Filenames == "" Then Return 1
	$aID3File = StringSplit($ID3Filenames,"|")
	For $i = 1 To $aID3File[0]
		If FileExists($aID3File[$i]) Then
			$ret = FileDelete($aID3File[$i])
			If $ret == 0 Then Return 0
		EndIf
	Next
	$ID3Filenames = ""
	
	Return 1
	
EndFunc
; -----------------------------------------------------------------------------



;-------------------  Main File Reading Functions -----------------------------
Func _ReadID3v2($Filename, ByRef $aID3V2Tag, $sFilter = -1)
		
	Local $ZPAD = 0, $BytesRead = 0
	Local $hFile = FileOpen($Filename,16) ;mode = Force binary
	Local $iFilterNum
	
	If $sFilter <> -1 Then
		$aFilter = StringSplit($sFilter,"|")
		$iFilterNum = $aFilter[0]
	EndIf
		
	;Read Header Bytes (First 10 Bytes of File)
	;****************************************************************************************
	Local $ID3v2Header = FileRead($hFile, 10)
	_ArrayAdd($aID3V2Tag,"Header" & "|" & $ID3v2Header)
	$aID3V2Tag[0] += 1
	$BytesRead = 10 ;ID3 Header has been read (Header Size = 10 Bytes)
;~ 	MsgBox(0,"$ID3v2Header",$ID3v2Header)
	;****************************************************************************************
	
	;Read "ID3" string
	;****************************************************************************************
	If Not(BinaryToString(BinaryMid($ID3v2Header,1,3)) == "ID3") Then 
		FileClose($hFile)
		SetError(1)
		Return 0
	EndIf
	;****************************************************************************************
	
	;GetTagVer
	;****************************************************************************************
	Local $FrameIDLen ;equals 3 or 4 depending on ID3v2.2 or ID3v2.3+
	Local $iID3v2Ver_Major = Number(BinaryMid($ID3v2Header,4,1))
	Local $iID3v2Ver_Rev = Number(BinaryMid($ID3v2Header,5,1))
	;Local $sID3v2Version = String(Number(BinaryMid($ID3v2Header,4,1))) & "." & String(Number(BinaryMid($ID3v2Header,5,1)))
	
	If $iID3v2Ver_Major = 2 Then
		$FrameIDLen = 3
		If $sFilter <> -1 Then
			_ConvertFilterToID3v2_2($sFilter)
		EndIf
	Else
		$FrameIDLen = 4
	EndIf
	;****************************************************************************************
	
	;GetTagFlags
	;****************************************************************************************
	Local $TagFlagsBin = BinaryMid($ID3v2Header,6,1)
	Local $TagFlags = _HexToBin_ID3(StringTrimLeft($TagFlagsBin,2))
	Local $Unsynchronisation = StringMid($TagFlags,1,1)
	Local $ExtendedHeader = StringMid($TagFlags,2,1)
	Local $ExperimentalIndicator = StringMid($TagFlags,3,1)
	Local $Footer = StringMid($TagFlags,4,1)
	If Not $TagFlags == "00000000" Then
		MsgBox(0,"$ID3TagFlags", $TagFlags)
	EndIf
;~ 	If $sFilter == -1 Then
;~ 		_ArrayAdd($aID3V2Tag,"Unsynchronisation" & "|" & $Unsynchronisation)
;~ 		_ArrayAdd($aID3V2Tag,"ExtendedHeader" & "|" & $ExtendedHeader)
;~ 		_ArrayAdd($aID3V2Tag,"ExperimentalIndicator" & "|" & $ExperimentalIndicator)
;~ 		_ArrayAdd($aID3V2Tag,"Footer" & "|" & $Footer)
;~ 		$aID3V2Tag[0] += 4
;~ 	EndIf
	;****************************************************************************************
	
	
	;GetTagSize
	;****************************************************************************************
	Local $TagSizeBin = ""
	$TagHeaderBin = _HexToBin_ID3(StringTrimLeft(BinaryMid($ID3v2Header,7,4),2)) ;Removes 0x
	For $i = 1 To 33 Step 8
		$TagSizeBin &= StringMid($TagHeaderBin,$i + 1,7) ;Skip most significant bit in every byte
	Next
	Local $TagSize = Dec(_BinToHex_ID3($TagSizeBin)) + 10 ;add 10 to include header
	If ($sFilter == -1) or StringInStr($sFilter,"TagSize") Then
		_ArrayAdd($aID3V2Tag,"TagSize" & "|" & $TagSize)
		$aID3V2Tag[0] += 1
		If $aID3V2Tag[0] == ($iFilterNum + 1) Then ;Plus one needed to account for Header
			FileClose($hFile)
			Return 1
		EndIf
	EndIf
;~ 	MsgBox(0,"$TagSize",$TagSize)
	;****************************************************************************************
	
	;Read in all of the tag and close the file might be faster
	Local $ZPadding, $FrameIDFristHex, $FrameID, $FrameSizeHex, $FrameSize, $FrameFlag1, $FrameFlag2, $FoundTag, $index
	Local $FrameHeader
	
	;Get Rest Of Tag 
	While $BytesRead < $TagSize
		
		;Initialize ZPAD & Read first Hex value to test for new Frame or NULL Bytes
		;****************************************************************************************
		$ZPadding = 0 
		$FrameIDFristHex = StringTrimLeft(FileRead($hFile,1),2)
		$BytesRead += 1
;~ 		MsgBox(0,"Chr(Dec($FrameIDFristHex))",Chr(Dec($FrameIDFristHex)))
		;****************************************************************************************
		
		;check for NULL
		If $FrameIDFristHex == "00" Then
			;Count how many NULL Bytes at the end of the Tag then Exit Loop
			;****************************************************************************************
			$ZPadding += 1
			While $FrameIDFristHex == "00"
				$FrameIDFristHex = StringTrimLeft(FileRead($hFile,1),2)
				$BytesRead += 1
				$ZPadding += 1
				If $BytesRead >= $TagSize Then
					ExitLoop
				EndIf
			WEnd
			$ZPAD = $ZPadding
			ExitLoop
			;****************************************************************************************
			
		Else
			
			;Read Frame ID String
			;****************************************************************************************
			$FrameID = Chr(Dec($FrameIDFristHex)) & BinaryToString(FileRead($hFile,$FrameIDLen-1))
			$BytesRead += $FrameIDLen-1
			;****************************************************************************************
			
			;Check for a valid frameID string
			If StringIsAlNum($FrameID) Then
				
				;Read Frame Header & Size (Differant for 2.2 and 2.3+) (ID3v2.4 has syncsafe FrameSize)
				;****************************************************************************************
				If $FrameIDLen == 4 Then
					$bFrameHeader = FileRead($hFile,6)
					$BytesRead += 6
					$FrameSizeHex = StringTrimLeft(BinaryMid($bFrameHeader,1,4),2)
					If $iID3v2Ver_Major = 3 Then
						$FrameSize = _HexToUint32_ID3($FrameSizeHex)
					Elseif $iID3v2Ver_Major = 4 Then
						;32 bit synchsafe integer
						MsgBox(0,"New Version Found","Check new Calculation of FrameSize")
						$sFrameSizebin = _HexToBin_ID3($FrameSizeHex)
						Dim $sSyncFrameSizeBin = ""
						For $i = 1 To 33 Step 8
							$sSyncFrameSizeBin &= StringMid($sFrameSizebin,$i + 1,7) ;Skip most significant bit in every byte
						Next
						$FrameSize = Dec(_BinToHex_ID3($sSyncFrameSizeBin))
						
					EndIf
					
					$FrameFlag1 = _HexToBin_ID3(StringTrimLeft(BinaryMid($bFrameHeader,5,1),2))
					$FrameFlag2 = _HexToBin_ID3(StringTrimLeft(BinaryMid($bFrameHeader,6,1),2))
					
				ElseIf $FrameIDLen == 3 Then
					$bFrameHeader = FileRead($hFile,3) ;only frame size
					$BytesRead += 3
					$FrameSizeHex = StringTrimLeft(BinaryMid($bFrameHeader,1,3),2)
					$FrameSize = Dec($FrameSizeHex)
				EndIf
;~ 				MsgBox(0,$FrameID,$FrameID)
				;****************************************************************************************
				
				
				;Add FrameID and Frame Data to array
				;****************************************************************************************
				If $sFilter == -1 Then
					Switch $FrameID
						Case "APIC" ;Picture (Write to File)
							$FrameData = _GetAlbumArt($hFile,$FrameSize)
						Case "USLT" ;Lyrics (Write to File)
							$FrameData = _GetSongLyrics($hFile,$FrameSize)
						Case "NCON"
							FileRead($hFile,$FrameSize)
							$FrameData = "Frame Not Compliant - MusicMatch Frame"
						Case Else
							$FrameData = FileRead($hFile,$FrameSize)
					EndSwitch
					_ArrayAdd($aID3V2Tag,$FrameID & "|" & $FrameData & "|" & $FrameSize)
					$aID3V2Tag[0] += 1
					$BytesRead += $FrameSize
				Else 
					If $aID3V2Tag[0] == ($iFilterNum + 1) Then ;Plus one needed to account for Header
						ExitLoop
					EndIf
					If StringInStr($sFilter,$FrameID) Then
						Switch $FrameID
						Case "APIC" ;Picture (Write to File)
							$FrameData = _GetAlbumArt($hFile,$FrameSize)
						Case "USLT" ;Lyrics (Write to File)
							$FrameData = _GetSongLyrics($hFile,$FrameSize)
						Case Else
							$FrameData = FileRead($hFile,$FrameSize)
					EndSwitch
						_ArrayAdd($aID3V2Tag,$FrameID & "|" & $FrameData & "|" & $FrameSize)
						$aID3V2Tag[0] += 1
					Else
						FileRead($hFile,$FrameSize)
					EndIf
					$BytesRead += $FrameSize
				EndIf
				;****************************************************************************************
				
				
				
			EndIf
		EndIf
	WEnd
	
	;Read MPEG Header & Write to Array MPEG & ZPAD
	;****************************************************************************************
	If ($sFilter == -1) or StringInStr($sFilter,"MPEG") or StringInStr($sFilter,"ZPAD") Then
		Local $MPEGHeaderCheck = $FrameIDFristHex & StringTrimLeft(FileRead($hFile,50),2)
		Local $index = StringInStr($MPEGHeaderCheck,"FF")
		Local $MPEGHeaderHex = StringMid($MPEGHeaderCheck,$index,8)
		;check MPEG Header
		If _CheckMPEGHeader($MPEGHeaderHex) and (StringInStr($sFilter,"MPEG") or ($sFilter == -1)) Then
			_ArrayAdd($aID3V2Tag,"MPEG" & "|" & $MPEGHeaderHex)
			$aID3V2Tag[0] += 1
		EndIf
		If StringInStr($sFilter,"ZPAD") or ($sFilter == -1) Then
			_ArrayAdd($aID3V2Tag,"ZPAD" & "|" & $ZPAD)
			$aID3V2Tag[0] += 1
		EndIf
	EndIf
	;****************************************************************************************

	FileClose($hFile)
	Return 1
	
EndFunc

Func _ReadID3v1($Filename, ByRef $aID3V1Tag)
	
	Local $hfile = FileOpen($Filename,16) ;open in binary mode
	FileRead($hfile,FileGetSize($Filename)-128)
	Local $ID3v1Tag = FileRead($hfile)
	FileClose($hfile)
	
	Local $ID3v1ID = BinaryToString(BinaryMid($ID3v1Tag,1,3))

	If Not($ID3v1ID == "TAG") Then
		FileClose($hfile)
		SetError(-1)
		Return 0
	EndIf
	
	Local $Title, $Artist, $Album, $Year, $Comment, $Track, $GenreID, $Genre
	
	$Title = BinaryToString(BinaryMid($ID3v1Tag,4,30))
	_ArrayAdd($aID3V1Tag,"Title" & "|" & $Title)
	$aID3V1Tag[0] += 1

	$Artist = BinaryToString(BinaryMid($ID3v1Tag,34,30))
	_ArrayAdd($aID3V1Tag,"Artist" & "|" & $Artist)
	$aID3V1Tag[0] += 1

	$Album = BinaryToString(BinaryMid($ID3v1Tag,64,30))
	_ArrayAdd($aID3V1Tag,"Album" & "|" & $Album)
	$aID3V1Tag[0] += 1
	
	$Year = BinaryToString(BinaryMid($ID3v1Tag,94,4))
	_ArrayAdd($aID3V1Tag,"Year" & "|" & $Year)
	$aID3V1Tag[0] += 1
	
	$Comment = BinaryToString(BinaryMid($ID3v1Tag,98,28))
	_ArrayAdd($aID3V1Tag,"Comment" & "|" & $Comment)
	$aID3V1Tag[0] += 1
	
	$Track = Dec(StringTrimLeft(BinaryMid($ID3v1Tag,126,2),2))
;~ 	MsgBox(0,"$Track",$Track)
	If $Track < 1000 And $Track > 0 Then
		_ArrayAdd($aID3V1Tag,"Track" & "|" & $Track)
		$aID3V1Tag[0] += 1
	Else
		_ArrayAdd($aID3V1Tag,"Track" & "|" & "")
		$aID3V1Tag[0] += 1
	EndIf
		
	$GenreID = Dec(StringTrimLeft(BinaryMid($ID3v1Tag,128,1),2))
	$Genre = _GetGenreByID($GenreID)
	_ArrayAdd($aID3V1Tag,"Genre" & "|" & $Genre)
	$aID3V1Tag[0] += 1
	
	If $Track == 0 Then
		_ArrayAdd($aID3V1Tag,"Version" & "|" & "ID3v1.0")
		$aID3V1Tag[0] += 1
	Else
		_ArrayAdd($aID3V1Tag,"Version" & "|" & "ID3v1.1")
		$aID3V1Tag[0] += 1
	EndIf
	
	FileClose($hfile)
	Return 1
	
EndFunc


Func _GetFrame_TextInfoFrame($sFrameID)
	
EndFunc

Func _GetFrame_URLLinkFrame($sFrameID)
	
EndFunc

Func _GetFrame_APIC()
	
EndFunc


Func _GetID3FrameString($vFrameData)
	
	Local $bTagFieldFound = False, $sFrameString = ""
	Local $bText_Encoding
	
	$aFrameData = StringSplit($vFrameData,"|")
	$FrameID = $aFrameData[1]
	
	If (StringMid($FrameID,1,1) == "T") and (StringLen($FrameID) == 4) and ($FrameID <> "TXXX") and ($FrameID <> "TCON") Then
		$bTagFieldFound = True
		$bFrameData = Binary($aFrameData[2])
		$sFrameString = BinaryToString(BinaryMid($bFrameData,2))
	Elseif $FrameID == "TXXX" Then
		$bTagFieldFound = True
		$bFrameData = Binary($aFrameData[2])			
		$bText_Encoding = BinaryMid($bFrameData,1,1)
		$ByteIndex = 2
		$Description = ""
		$Byte = BinaryMid($bFrameData,$ByteIndex,1)
		$ByteIndex += 1
		While $Byte <> "0x00"
			$Description &= BinaryToString($Byte)
			$Byte = BinaryMid($bFrameData,$ByteIndex,1)
			$ByteIndex += 1
		WEnd
		$sFrameString = BinaryToString(BinaryMid($bFrameData,$ByteIndex))
	Elseif $FrameID == "TCON" Then;Content Type/Genre
		$bTagFieldFound = True
		$bFrameData = Binary($aFrameData[2])
		$Genre = BinaryToString($bFrameData)
		If StringMid($Genre,1,1) == "(" Then ;check if first char is "("
			$closeparindex = StringInStr($Genre,")")
			$GenreID = StringMid($Genre,2,$closeparindex-1)
			$Genre = _GetGenreByID($GenreID)
		EndIf ;If no "(" then return the whole field as is
		$sFrameString = $Genre
		
	ElseIf (StringMid($FrameID,1,1) == "W") and (StringLen($FrameID) == 4) and ($FrameID <> "WXXX") Then
		$bTagFieldFound = True
		$bFrameData = Binary($aFrameData[2])
		$sFrameString = BinaryToString($bFrameData)
	ElseIf $FrameID == "WXXX" Then
		
		$bTagFieldFound = True
		$bFrameData = Binary($aFrameData[2])			
		$bText_Encoding = BinaryMid($bFrameData,1,1)
		$ByteIndex = 2
		$Description = ""
		$Byte = BinaryMid($bFrameData,$ByteIndex,1)
		$ByteIndex += 1
		While $Byte <> "0x00"
			$Description &= BinaryToString($Byte)
			$Byte = BinaryMid($bFrameData,$ByteIndex,1)
			$ByteIndex += 1
		WEnd
		$sFrameString = BinaryToString(BinaryMid($bFrameData,$ByteIndex))
		
	Else
		
		Switch $FrameID
			Case "COMM", "COM" ;Comment
				$bTagFieldFound = True
			
				$bFrameData = Binary($aFrameData[2])			
			
				$bText_Encoding = BinaryMid($bFrameData,1,1)
				$Language = BinaryToString(BinaryMid($bFrameData,2,3))
				$ByteIndex = 5
			
				$Short_Content_Descrip = ""
				$Byte = BinaryMid($bFrameData,$ByteIndex,1)
				$ByteIndex += 1
				While $Byte <> "0x00"
					$Short_Content_Descrip &= BinaryToString($Byte)
					$Byte = BinaryMid($bFrameData,$ByteIndex,1)
					$ByteIndex += 1
				WEnd
				$sFrameString = BinaryToString(BinaryMid($bFrameData,$ByteIndex))
			Case "APIC"
				$bTagFieldFound = True
				$sFrameString = $aFrameData[3]
			Case "USLT"
				$bTagFieldFound = True
				$sFrameString = $aFrameData[3]
			Case "UFID"
				$bTagFieldFound = True
				$bFrameData = Binary($aFrameData[2])
				$sFrameString = BinaryToString(BinaryMid($bFrameData,2))
			Case "Artist" ;ID3v1
				$bTagFieldFound = True
				$sFrameString = $aFrameData[2]
			Case "Title" ;ID3v1
				$bTagFieldFound = True
				$sFrameString = $aFrameData[2]
			Case "Album" ;ID3v1
				$bTagFieldFound = True
				$sFrameString = $aFrameData[2]
			Case "Track" ;ID3v1
				$bTagFieldFound = True
				$sFrameString = $aFrameData[2]
			Case "Year" ;ID3v1
				$bTagFieldFound = True
				$sFrameString = $aFrameData[2]
			Case "Genre" ;ID3v1
				$bTagFieldFound = True
				$sFrameString = $aFrameData[2]
			Case "Comment" ;ID3v1
				$bTagFieldFound = True
				$sFrameString = $aFrameData[2]
			Case "ZPAD" ;ID3v2
				$bTagFieldFound = True
				$sFrameString = $aFrameData[2]
			Case "MPEG" ;MPEG
				$bTagFieldFound = True
				$sFrameString = $aFrameData[2]
			Case "NCON" ;??http://www.id3.org/Compliance_Issues --- non-standard NCON frame in tag
				$bTagFieldFound = True
				$sFrameString &= "Non-Standard NCON Frame"
			Case "PRIV" ;Private frame
				$bTagFieldFound = True
;~ 				$Owner_Identifier = FileRead($hFile,1)
;~ 				$LengthToRead -= 1
;~ 				$FrameString &= FileRead($hFile,$LengthToRead)
;~ 			Case "PCNT", "CNT" ;Play counter
;~ 				$bTagFieldFound = True
;~ 				$FrameString &= _HexToUint32_ID3(StringTrimLeft($aFrameData[2],2)) ;Not Tested
;~ 			Case "RVA" ;Relative volume adjustment ID3v2.2 only
;~ 				$bTagFieldFound = True
;~ 				$FrameString &= "TBP - Relative Volume Adjustment" ;Not Tested
;~ 				FileRead($hFile,$LengthToRead)
			Case Else
				MsgBox(0,"$FrameID Unknown",$FrameID)
				$sFrameString &= "Undefined FrameID"
					
		EndSwitch
			
	EndIf
	
	
	If $bTagFieldFound == False Then
		SetError(1)
	EndIf
	
	Return $sFrameString

EndFunc

;--------------------------  Support Functions --------------------------------

Func _CheckMPEGHeader($MPEGFrameSyncHex)
	
	$MPEGFrameSyncUint32 = _HexToUint32_ID3($MPEGFrameSyncHex)
	
	If $MPEGFrameSyncUint32 > _HexToUint32_ID3("FFE00000") Then 
		If $MPEGFrameSyncUint32 < _HexToUint32_ID3("FFFFEC00") Then
			If Not(StringMid($MPEGFrameSyncHex,4,1) == "0") Then
				If Not(StringMid($MPEGFrameSyncHex,4,1) == "1") Then
					If Not(StringMid($MPEGFrameSyncHex,4,1) == "9") Then
						;valid MPEG Header Found
						Return 1
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
		
	Return 0

EndFunc

Func _GetAlbumArt($hFile,$FrameLen)
	
	Local $LengthToRead = $FrameLen, $AlbumArtFilename = @ScriptDir & "\" & "AlbumArt", $bReturn
	
	$bText_Encoding = FileRead($hFile,1)
	$LengthToRead -= 1
		
	$MIME_Type = ""
	$Byte = FileRead($hFile,1)
	$bMIME_Type = $Byte
	$LengthToRead -= 1
	While $Byte <> "0x00"
		$MIME_Type &= BinaryToString($Byte)
		$Byte = FileRead($hFile,1)
		$bMIME_Type &= $Byte
		$LengthToRead -= 1
	WEnd
;~ 	MsgBox(0,"$bMIME_Type",$bMIME_Type)
			
	$bPicture_Type = FileRead($hFile,1)
	$LengthToRead -= 1
			
	$Description = ""
	$Byte = FileRead($hFile,1)
	$bDescription = $Byte
	$LengthToRead -= 1
	While $Byte <> "0x00"
		$Description &= BinaryToString($Byte)
		$Byte = FileRead($hFile,1)
		$bDescription &= $Byte
		$LengthToRead -= 1
	WEnd
	
;~ 	MsgBox(0,"$Description",$Description)
	
	If StringInStr($MIME_Type,"jpg") Or StringInStr($MIME_Type,"jpeg") Then
		$AlbumArtFilename &= ".jpg"
		$ID3Filenames &= $AlbumArtFilename & "|"
	ElseIf StringInStr($MIME_Type,"png") Then
		$AlbumArtFilename &= ".png"
		$ID3Filenames &= $AlbumArtFilename & "|"
	Else
		$AlbumArtFilename = "File Type Unknown"
	EndIf
	
	;Read Picture data to file
	;****************************************************************************************
	$PicFile_h = FileOpen($AlbumArtFilename, 2) ;Open for write and erase existing
	$WriteError = FileWrite($PicFile_h,FileRead($hFile, $LengthToRead))
	FileClose($PicFile_h)
	;****************************************************************************************
	
	$bReturn = $bText_Encoding & $bMIME_Type
	$bReturn &= $bPicture_Type & $bDescription
	$bReturn &= "|" & $AlbumArtFilename
	
	Return $bReturn
	
EndFunc

Func _GetSongLyrics($hFile,$FrameLen)

	Local $LengthToRead = $FrameLen, $LyricsFilename = @ScriptDir & "\" & "SongLyrics.txt", $bReturn
	$ID3Filenames &= $LyricsFilename & "|"
	
	$bText_Encoding = FileRead($hFile,1)
	$LengthToRead -= 1
	
	$bLanguage = FileRead($hFile,3)
	$LengthToRead -= 3
	
	$Content_Descriptor = ""
	$Byte = FileRead($hFile,1)
	$bContent_Descriptor = $Byte
	$LengthToRead -= 1
	While $Byte <> "0x00"
		$Content_Descriptor &= BinaryToString($Byte)
		$Byte = FileRead($hFile,1)
		$bContent_Descriptor &= $Byte
		$LengthToRead -= 1
	WEnd

	$bLyrics_Text = FileRead($hFile,$LengthToRead)
	$Lyrics_Text = BinaryToString($bLyrics_Text)
	
	$hLyricFile = FileOpen($LyricsFilename, 2) ;Open for write and erase existing
	FileWrite($hLyricFile,$Lyrics_Text)
	FileClose($hLyricFile)

	$bReturn = $bText_Encoding & $bLanguage & $bContent_Descriptor
	$bReturn &= "|" & $LyricsFilename

	Return $bReturn

EndFunc

Func _ConvertFilterToID3v2_2(ByRef $sFilter)
	
	
	$sFilter = StringReplace($sFilter,"TIT1", "TT1")
	$sFilter = StringReplace($sFilter,"TIT2", "TT2")
	$sFilter = StringReplace($sFilter,"TIT3", "TT3")
	$sFilter = StringReplace($sFilter,"TEXT", "TXT")
	$sFilter = StringReplace($sFilter,"TLAN", "TLA")
	$sFilter = StringReplace($sFilter,"TKEY", "TKE")
	$sFilter = StringReplace($sFilter,"TMED", "TMT")
	$sFilter = StringReplace($sFilter,"TOAL", "TOT")
	$sFilter = StringReplace($sFilter,"TOFN", "TOF")
	$sFilter = StringReplace($sFilter,"TOLY", "TOL")
	$sFilter = StringReplace($sFilter,"TOPE", "TOA")
	$sFilter = StringReplace($sFilter,"TORY", "TOR")
	$sFilter = StringReplace($sFilter,"TPE1", "TP1")
	$sFilter = StringReplace($sFilter,"TPE2", "TP2")
	$sFilter = StringReplace($sFilter,"TPE3", "TP3")
	$sFilter = StringReplace($sFilter,"TPE4", "TP4")
	$sFilter = StringReplace($sFilter,"TPOS", "TPA")
	$sFilter = StringReplace($sFilter,"TALB", "TRK")
	$sFilter = StringReplace($sFilter,"TRCK", "TP2")
	$sFilter = StringReplace($sFilter,"TYER", "TYE")
	$sFilter = StringReplace($sFilter,"COMM", "COM")
	$sFilter = StringReplace($sFilter,"APIC", "PIC")
	$sFilter = StringReplace($sFilter,"USLT", "ULT")
	$sFilter = StringReplace($sFilter,"TSSE", "TSS")
	$sFilter = StringReplace($sFilter,"TENC", "TEN")
	$sFilter = StringReplace($sFilter,"TCOP", "TCR")
	$sFilter = StringReplace($sFilter,"TBPM", "TBP")
	$sFilter = StringReplace($sFilter,"TRDA", "TRD")
	$sFilter = StringReplace($sFilter,"TSIZ", "TSI")
	$sFilter = StringReplace($sFilter,"TSRC", "TRC")
	$sFilter = StringReplace($sFilter,"TCON", "TCO")
	$sFilter = StringReplace($sFilter,"TLEN", "TLE")
	$sFilter = StringReplace($sFilter,"TPUB", "TPB")
	$sFilter = StringReplace($sFilter,"TFLT", "TFT")
	$sFilter = StringReplace($sFilter,"UFID", "UFI")
	$sFilter = StringReplace($sFilter,"TCOM", "TCM")
	$sFilter = StringReplace($sFilter,"WCOM", "WCM")
	$sFilter = StringReplace($sFilter,"WCOP", "WCP")
	$sFilter = StringReplace($sFilter,"WXXX", "WXX")
	$sFilter = StringReplace($sFilter,"WOAR", "WAR")
	$sFilter = StringReplace($sFilter,"WOAS", "WAS")
	$sFilter = StringReplace($sFilter,"WOAF", "WAF")
	$sFilter = StringReplace($sFilter,"WPUB", "WPB")
	$sFilter = StringReplace($sFilter,"PCNT", "CNT")

EndFunc

;Author: YDY (Lazycat)  Thank you for writing all this out
Func _GetGenreByID($iID)
    Local $asGenre = StringSplit("Blues,Classic Rock,Country,Dance,Disco,Funk,Grunge,Hip-Hop," & _
    "Jazz,Metal,New Age, Oldies,Other,Pop,R&B,Rap,Reggae,Rock,Techno,Industrial,Alternative," & _
    "Ska,Death Metal,Pranks,Soundtrack,Euro-Techno,Ambient,Trip-Hop,Vocal,Jazz+Funk,Fusion," & _
    "Trance,Classical,Instrumental,Acid,House,Game,Sound Clip,Gospel,Noise,Alternative Rock," & _
    "Bass,Soul,Punk,Space,Meditative,Instrumental Pop,Instrumental Rock,Ethnic,Gothic,Darkwave," & _
    "Techno-Industrial,Electronic,Pop-Folk,Eurodance,Dream,Southern Rock,Comedy,Cult,Gangsta," & _
    "Top 40,Christian Rap,Pop/Funk,Jungle,Native US,Cabaret,New Wave,Psychadelic,Rave,Showtunes," & _
    "Trailer,Lo-Fi,Tribal,Acid Punk,Acid Jazz,Polka,Retro,Musical,Rock & Roll,Hard Rock,Folk," & _
    "Folk-Rock,National Folk,Swing,Fast Fusion,Bebob,Latin,Revival,Celtic,Bluegrass,Avantgarde," & _
    "Gothic Rock,Progressive Rock,Psychedelic Rock,Symphonic Rock,Slow Rock,Big Band,Chorus," & _
    "Easy Listening,Acoustic,Humour,Speech,Chanson,Opera,Chamber Music,Sonata,Symphony,Booty Bass," & _
    "Primus,Porn Groove,Satire,Slow Jam,Club,Tango,Samba,Folklore,Ballad,Power Ballad,Rhytmic Soul," & _
    "Freestyle,Duet,Punk Rock,Drum Solo,Acapella,Euro-House,Dance Hall,Goa,Drum & Bass,Club-House," & _
    "Hardcore,Terror,Indie,BritPop,Negerpunk,Polsk Punk,Beat,Christian Gangsta,Heavy Metal,Black Metal," & _
    "Crossover,Contemporary C,Christian Rock,Merengue,Salsa,Thrash Metal,Anime,JPop,SynthPop", ",")
    If ($iID >= 0) and ($iID < 148) Then Return $asGenre[$iID + 1]
    Return("")
EndFunc

Func _GetGenreID($sGrenre)
	Local $asGenre = StringSplit("Blues,Classic Rock,Country,Dance,Disco,Funk,Grunge,Hip-Hop," & _
    "Jazz,Metal,New Age, Oldies,Other,Pop,R&B,Rap,Reggae,Rock,Techno,Industrial,Alternative," & _
    "Ska,Death Metal,Pranks,Soundtrack,Euro-Techno,Ambient,Trip-Hop,Vocal,Jazz+Funk,Fusion," & _
    "Trance,Classical,Instrumental,Acid,House,Game,Sound Clip,Gospel,Noise,Alternative Rock," & _
    "Bass,Soul,Punk,Space,Meditative,Instrumental Pop,Instrumental Rock,Ethnic,Gothic,Darkwave," & _
    "Techno-Industrial,Electronic,Pop-Folk,Eurodance,Dream,Southern Rock,Comedy,Cult,Gangsta," & _
    "Top 40,Christian Rap,Pop/Funk,Jungle,Native US,Cabaret,New Wave,Psychadelic,Rave,Showtunes," & _
    "Trailer,Lo-Fi,Tribal,Acid Punk,Acid Jazz,Polka,Retro,Musical,Rock & Roll,Hard Rock,Folk," & _
    "Folk-Rock,National Folk,Swing,Fast Fusion,Bebob,Latin,Revival,Celtic,Bluegrass,Avantgarde," & _
    "Gothic Rock,Progressive Rock,Psychedelic Rock,Symphonic Rock,Slow Rock,Big Band,Chorus," & _
    "Easy Listening,Acoustic,Humour,Speech,Chanson,Opera,Chamber Music,Sonata,Symphony,Booty Bass," & _
    "Primus,Porn Groove,Satire,Slow Jam,Club,Tango,Samba,Folklore,Ballad,Power Ballad,Rhytmic Soul," & _
    "Freestyle,Duet,Punk Rock,Drum Solo,Acapella,Euro-House,Dance Hall,Goa,Drum & Bass,Club-House," & _
    "Hardcore,Terror,Indie,BritPop,Negerpunk,Polsk Punk,Beat,Christian Gangsta,Heavy Metal,Black Metal," & _
    "Crossover,Contemporary C,Christian Rock,Merengue,Salsa,Thrash Metal,Anime,JPop,SynthPop", ",")
	
	For $i = 1 to $asGenre[0]
		If $sGrenre == $asGenre[$i] Then
			Return $i - 1
		EndIf
	Next
	
	Return 12 ;Other
	
	
EndFunc


Func _HexToUint32_ID3($HexString4Byte)
	;need this because function Dec is signed
	Return Dec(StringLeft($HexString4Byte,2)) * Dec("FFFFFF") + Dec(StringTrimLeft($HexString4Byte,2))
EndFunc

Func _HexToBin_ID3($HexString)
	Local $Bin = ""
	For $i = 1 To StringLen($HexString) Step 1
		$Hex = StringRight(StringLeft($HexString, $i), 1)
		Select
		Case $Hex = "0"
			$Bin = $Bin & "0000"
		Case $Hex = "1"
			$Bin = $Bin & "0001"
		Case $Hex = "2"
			$Bin = $Bin & "0010"
		Case $Hex = "3"
			$Bin = $Bin & "0011"
		Case $Hex = "4"
			$Bin = $Bin & "0100"
		Case $Hex = "5"
			$Bin = $Bin & "0101"
		Case $Hex = "6"
			$Bin = $Bin & "0110"
		Case $Hex = "7"
			$Bin = $Bin & "0111"
		Case $Hex = "8"
			$Bin = $Bin & "1000"
		Case $Hex = "9"
			$Bin = $Bin & "1001"
		Case $Hex = "A"
			$Bin = $Bin & "1010"
		Case $Hex = "B"
			$Bin = $Bin & "1011"
		Case $Hex = "C"
			$Bin = $Bin & "1100"
		Case $Hex = "D"
			$Bin = $Bin & "1101"
		Case $Hex = "E"
			$Bin = $Bin & "1110"
		Case $Hex = "F"
			$Bin = $Bin & "1111"
		Case Else
			SetError(-1)
		EndSelect
	Next
	If @error Then 
		Return "ERROR"
	Else
		Return $Bin
	EndIf
EndFunc

Func _BinToHex_ID3($BinString)
	Local $Hex = ""
	If Not IsInt(StringLen($BinString) / 4) Then
		$Num = ((StringLen($BinString) / 4) - Int(StringLen($BinString) / 4)) * 4
;~ 		MsgBox(0, "", $Num)
		For $i = 1 To 4 - $Num Step 1
			$BinString = "0" & $BinString
		Next
	EndIf
	
	For $i = 4 To StringLen($BinString) Step 4
		$Bin = StringLeft(StringRight($BinString, $i), 4)
		Select
		Case $Bin = "0000"
			$Hex = $Hex & "0"
		Case $Bin = "0001"
			$Hex = $Hex & "1"
		Case $Bin = "0010"
			$Hex = $Hex & "2"
		Case $Bin = "0011"
			$Hex = $Hex & "3"
		Case $Bin = "0100"
			$Hex = $Hex & "4"
		Case $Bin = "0101"
			$Hex = $Hex & "5"
		Case $Bin = "0110"
			$Hex = $Hex & "6"
		Case $Bin = "0111"
			$Hex = $Hex & "7"
		Case $Bin = "1000"
			$Hex = $Hex & "8"
		Case $Bin = "1001"
			$Hex = $Hex & "9"
		Case $Bin = "1010"
			$Hex = $Hex & "A"
		Case $Bin = "1011"
			$Hex = $Hex & "B"
		Case $Bin = "1100"
			$Hex = $Hex & "C"
		Case $Bin = "1101"
			$Hex = $Hex & "D"
		Case $Bin = "1110"
			$Hex = $Hex & "E"
		Case $Bin = "1111"
			$Hex = $Hex & "F"
		Case Else
			SetError(-1)
		EndSelect
	Next
	If @error Then 
		Return "ERROR"
	Else
		Return _StringReverse($Hex)
	EndIf
EndFunc
; -----------------------------------------------------------------------------
