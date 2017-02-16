#include-once
#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <ListboxConstants.au3>
#Include <GuiStatusBar.au3>
#Include <GuiListView.au3>
#Include <File.au3>
#include "ID3_v2.2.au3"


Dim $Gui_Width = 850-265-65, $Gui_Height = 550
$ID3Gui_H = GUICreate("ID3 Example GUI", $Gui_Width, $Gui_Height)

$ProgDir = @WorkingDir & "\"

$StatusBar = _GUICtrlStatusBar_Create($ID3Gui_H, -1, -1)
_GUICtrlStatusBar_SetText($StatusBar , "Status")

$File_button = GUICtrlCreateButton("Open", 10, 20, 50, 20, $BS_DEFPUSHBUTTON)
$File_input = GUICtrlCreateInput("", 65, 20, 330, 20)
$FileSize_label = GUICtrlCreateLabel("FileSize:", 415, 25, 50, 20)
$FileSize_input = GUICtrlCreateInput("", 460, 20, 50, 20)

$RawTag_button = GUICtrlCreateButton("Raw Data", 440, 45, 70, 20)
$WriteTag_button = GUICtrlCreateButton("Save Tag", 360, 45, 70, 20)
$NewPic_button = GUICtrlCreateButton("Pic", 280, 45, 70, 20)

$tab = GUICtrlCreateTab(10,50,500,470)
$ID3_tab = GUICtrlCreateTabitem ("ID3 Data")
GUICtrlCreateGroup("ID3V2",20,74,480,275)
$Title_label = GUICtrlCreateLabel("Title:", 40, 90, 50, 20)
$Title_input = GUICtrlCreateInput("", 40, 105, 220, 20)
$Artist_label = GUICtrlCreateLabel("Artist:", 40, 100+30, 50, 20)
$Artist_input = GUICtrlCreateInput("", 40, 100+45, 220, 20)
$Album_label = GUICtrlCreateLabel("Album:", 40, 150+20, 50, 20)
$Album_input = GUICtrlCreateInput("", 40, 150+35, 220, 20)
$Track_label = GUICtrlCreateLabel("Track", 40, 210, 50, 20)
$Track_input = GUICtrlCreateInput("", 40, 200+25, 30, 20)
$Length_label = GUICtrlCreateLabel("Length", 90, 210, 50, 20)
$Length_input = GUICtrlCreateInput("", 90, 200+25, 40, 20)
$Year_label = GUICtrlCreateLabel("Year", 220, 210, 50, 20)
$Year_input = GUICtrlCreateInput("", 220, 200+25, 40, 20)
$Genre_label = GUICtrlCreateLabel("Genre", 40, 245, 50, 20)
$Genre_input = GUICtrlCreateInput("", 40, 240+20, 220, 20)
$Comment_label = GUICtrlCreateLabel("Comment", 40, 285, 50, 20)
$Comment_edit = GUICtrlCreateEdit( "", 40, 300, 220, 40)

If Not(FileExists("default.jpg")) Then
	$DefaultPicName = FileOpenDialog("Select default.jpg File", @WorkingDir & "\", "JPG (*.jpg;*.jpeg)", 1 + 4 )
Else
	$DefaultPicName = "default.jpg"
EndIf
$AlbumArt_pic = GUICtrlCreatePic($DefaultPicName,280,95, 200, 200)

$AlbumArtInfo_list = GUICtrlCreateList("",280,310,200,40,$LBS_NOSEL)
GUICtrlCreateGroup("ID3V1",20, 355 ,480,155)
$TitleV1_label = GUICtrlCreateLabel("Title:", 40, 375, 50, 20)
$TitleV1_input = GUICtrlCreateInput("", 40, 390, 220, 20)
$ArtistV1_label = GUICtrlCreateLabel("Artist:", 40, 415, 50, 20)
$ArtistV1_input = GUICtrlCreateInput("", 40, 430, 220, 20)
$AlbumV1_label = GUICtrlCreateLabel("Album:", 40, 455, 50, 20)
$AlbumV1_input = GUICtrlCreateInput("", 40, 470, 220, 20)
$TrackV1_label = GUICtrlCreateLabel("Track", 280, 375, 50, 20)
$TrackV1_input = GUICtrlCreateInput("", 280, 390, 30, 20)
$YearV1_label = GUICtrlCreateLabel("Year", 440, 375, 50, 20)
$YearV1_input = GUICtrlCreateInput("", 440, 390, 40, 20)
$GenreV1_label = GUICtrlCreateLabel("Genre", 280, 415, 50, 20)
$GenreV1_input = GUICtrlCreateInput("", 280, 430, 200, 20)
$CommentV1_label = GUICtrlCreateLabel("Comment", 280, 455, 50, 20)
$CommentV1_input = GUICtrlCreateInput( "", 280, 470, 200, 20)

$ID3V2_tab = GUICtrlCreateTabitem ("ID3V2 More")
$ZPADSize_label = GUICtrlCreateLabel("Zero Padding:", 40, 90, 100, 20)
$ZPADSize_input = GUICtrlCreateInput("", 40, 105, 50, 20)
$Encoder_label = GUICtrlCreateLabel("Encoder:", 40, 130, 100, 20)
$Encoder_input = GUICtrlCreateInput("", 40, 145, 100, 20)
$Publisher_label = GUICtrlCreateLabel("Publisher:", 40, 150+20, 50, 20)
$Publisher_input = GUICtrlCreateInput("", 40, 150+35, 220, 20)
$UFID_label = GUICtrlCreateLabel("Unique File ID:", 40, 210, 220, 20)
$UFID_input = GUICtrlCreateInput("", 40, 225, 220, 20)
$Composer_label = GUICtrlCreateLabel("Composer:", 40, 250, 50, 20)
$Composer_input = GUICtrlCreateInput("", 40, 265, 220, 20)
$Band_label = GUICtrlCreateLabel("Band/Orchestra/Accompaniment:", 40, 290, 220, 20)
$Band_input = GUICtrlCreateInput("", 40, 305, 220, 20)
$WCOM_label = GUICtrlCreateLabel("Commerical Info URL", 280, 90, 200, 20)
$WCOM_input = GUICtrlCreateInput("", 280, 105, 200, 20)
$WXXX_label = GUICtrlCreateLabel("User Defined URL", 280, 130, 200, 20)
$WXXX_input = GUICtrlCreateInput("", 280, 145, 200, 20)
$WOAR_label = GUICtrlCreateLabel("Official artist/performer URL", 280, 170, 200, 20)
$WOAR_input = GUICtrlCreateInput("", 280, 185, 200, 20)
$Lyrics_label = GUICtrlCreateLabel("Lyrics:", 25, 355, 50, 20)
$Lyrics_edit = GUICtrlCreateEdit( "", 25, 370, 465, 140)

Dim $szDrive, $szDir, $szFName, $szExt, $Filename

GUISetState()
While 1
	$msg = GUIGetMsg()
	Switch $msg
		Case $GUI_EVENT_CLOSE
			ExitLoop
		Case $RawTag_button
			_ArrayDisplay($ID3BufferArray,"ID3v2 Tag Array",-1,0,";","")
		Case $WriteTag_button
			_GUICtrlStatusBar_SetText( $StatusBar , "Writing Tags...")
			_ID3SetTagField("TIT2",GUICtrlRead ($Title_input))
			_ID3SetTagField("TPE1",GUICtrlRead ($Artist_input))
			_ID3SetTagField("COMM",GUICtrlRead ($Comment_edit))
;~ 			_ID3SetTagField("WOAR",GUICtrlRead ($WOAR_input))
			_ID3RemoveField("WOAR")
			_ID3SetTagField("Title",GUICtrlRead($TitleV1_input))
			_ID3SetTagField("Artist",GUICtrlRead($ArtistV1_input))
			_ID3SetTagField("Album",GUICtrlRead($AlbumV1_input))
			_ID3SetTagField("Track",GUICtrlRead($TrackV1_input))
			_ID3SetTagField("Year",GUICtrlRead($YearV1_input))
			_ID3SetTagField("Comment",GUICtrlRead($CommentV1_input))
			_ID3SetTagField("Genre",GUICtrlRead($GenreV1_input))
			_ID3WriteTag($Filename)
			_GUICtrlStatusBar_SetText( $StatusBar , "Complete")
		Case $NewPic_button
			$PIC_Filename = FileOpenDialog("Select JPG File", "", "All (*.*)", 1 + 4 )
			IF Not @error Then
				_ID3SetTagField("APIC",$PIC_Filename)
				GUICtrlSetImage($AlbumArt_pic, $PIC_Filename)
			EndIf
		
		Case $File_button
			_ResetAll()
			_GUICtrlStatusBar_SetText( $StatusBar , "Reading Tags...")
			
			$Filename = FileOpenDialog("Select MP3 File", "", "MP3 (*.mp3)", 1 + 4 )
			If Not(@error) Then
				FileChangeDir($ProgDir)
				_PathSplit($Filename, $szDrive, $szDir, $szFName, $szExt)
				GUICtrlSetData($File_input, $szFName & $szExt)
				GUICtrlSetData($FileSize_input, Round(FileGetSize($Filename)/1048576,2) & " MB")
			
			
			        MsgBox(0,"UFID",_ID3GetFrameDescription("UFID"))
			
;~ 					Dim $aFull2D = _ID3ReadTag($Filename, 0, -1, 2)
;~ 					_ArrayDisplay($aFull2D)
				
					;Get Version 2 Info
					_ID3ReadTag($Filename)
					GUICtrlSetData($Title_input, _ID3GetTagField("TIT2"))
					GUICtrlSetData($Artist_input, _ID3GetTagField("TPE1"))
					GUICtrlSetData($Album_input, _ID3GetTagField("TALB"))
					GUICtrlSetData($Track_input, _ID3GetTagField("TRCK"))
					GUICtrlSetData($Year_input, _ID3GetTagField("TYER"))
					GUICtrlSetData($Genre_input, _ID3GetTagField("TCON"))
					GUICtrlSetData($Comment_edit, _ID3GetTagField("COMM"))
				
					;Get Version 1 Info
					GUICtrlSetData($TitleV1_input, _ID3GetTagField("Title"))
					GUICtrlSetData($ArtistV1_input, _ID3GetTagField("Artist"))
					GUICtrlSetData($AlbumV1_input, _ID3GetTagField("Album"))
					GUICtrlSetData($TrackV1_input, _ID3GetTagField("Track"))
					GUICtrlSetData($YearV1_input, _ID3GetTagField("Year"))
					GUICtrlSetData($GenreV1_input, _ID3GetTagField("Genre"))
					GUICtrlSetData($CommentV1_input, _ID3GetTagField("Comment"))
			
					;Get Album Art
					$AlbumArtFile = _ID3GetTagField("APIC")
					GUICtrlSetImage($AlbumArt_pic, $AlbumArtFile)
;~ 					If Not($AlbumArtFile == $DefaultPicName) Then
;~ 						If FileExists($AlbumArtFile) Then FileDelete($AlbumArtFile)
;~ 					EndIf
			
					;Get More Stuff
					GUICtrlSetData($Length_input, _ID3GetTagField("TLEN"))
					GUICtrlSetData($ZPADSize_input, _ID3GetTagField("ZPAD"))
					GUICtrlSetData($Encoder_input, _ID3GetTagField("TSSE"))
					GUICtrlSetData($Publisher_input, _ID3GetTagField("TPUB"))
					GUICtrlSetData($UFID_input, _ID3GetTagField("UFID"))
					GUICtrlSetData($Composer_input, _ID3GetTagField("TPUB"))
					GUICtrlSetData($Band_input,_ID3GetTagField("TPE2"))
					GUICtrlSetData($WCOM_input, _ID3GetTagField("WCOM"))
					GUICtrlSetData($WXXX_input, _ID3GetTagField("WXXX"))
					GUICtrlSetData($WOAR_input, _ID3GetTagField("WOAR"))
					$LyricsFile = _ID3GetTagField("USLT")
					GUICtrlSetData($Lyrics_edit,  FileRead($LyricsFile))
			EndIf
			_GUICtrlStatusBar_SetText ( $StatusBar , "Status")
	EndSwitch
WEnd

	
Func _ResetAll()
	GUICtrlSetData($File_input, "")
	GUICtrlSetData($Title_input, "")
	GUICtrlSetData($Artist_input, "")
	GUICtrlSetData($Album_input, "")
	GUICtrlSetData($Track_input, "")
	GUICtrlSetData($Comment_edit, "")
	GUICtrlSetData($Year_input, "")
	GUICtrlSetData($Length_input, "")
	GUICtrlSetData($Genre_input, "")
	GUICtrlSetImage($AlbumArt_pic,$DefaultPicName)
	GUICtrlSetData($AlbumArtInfo_list, "")
	
	GUICtrlSetData($TitleV1_input, "")
	GUICtrlSetData($ArtistV1_input, "")
	GUICtrlSetData($AlbumV1_input,"")
	GUICtrlSetData($TrackV1_input, "")
	GUICtrlSetData($YearV1_input, "")
	GUICtrlSetData($GenreV1_input, "")
	GUICtrlSetData($CommentV1_input,"")
	
	GUICtrlSetData($FileSize_input, "")
	GUICtrlSetData($ZPADSize_input,"")
	GUICtrlSetData($Encoder_input,"")
	
	GUICtrlSetData($Lyrics_edit, "")
	GUICtrlSetData($Publisher_input, "")
	GUICtrlSetData($UFID_input,"")
	GUICtrlSetData($Composer_input,"")
	GUICtrlSetData($Band_input,"")
	GUICtrlSetData($WXXX_input,"")
	GUICtrlSetData($WOAR_input,"")
EndFunc