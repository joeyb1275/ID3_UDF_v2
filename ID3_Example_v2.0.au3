#include-once
#include <ID3_v2.0.au3>
#include <Array.au3>


$Filename = FileOpenDialog( "Select Mp3 File", "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}", "Muisc (*.mp3)")


;~ $sFilter = "TIT2|TALB|TPE1|TYER|APIC"
;~ $sFilter = "TagSize"
;~ $ID3Tag = _ID3ReadTag($Filename,2,$sFilter,2)
$ID3Tag = _ID3ReadTag($Filename,0,-1,2)
_ArrayDisplay($ID3Tag,"$ID3Tag",-1,0,";","")

;~ $ID3v1Tag = _ID3TagToArray($Filename,1)
;~ _ArrayDisplay($ID3v1Tag,"$ID3v1Tag")


;~ _ID3TagToBuffer($Filename,"TIT2|COMM")


;~ $Title = _ID3GetTagField($Filename, "TIT2")
;~ $err = @error
;~ $ext = @extended
;~ MsgBox(0,"$Title",$Title)
;~ MsgBox(0,"Error & Extended", "Error: " & $err & @CRLF & "Extended: " & $ext)


;~ $Title = _ID3GetTagField($Filename, "Title")
;~ $err = @error
;~ $ext = @extended
;~ MsgBox(0,"$Title",$Title)
;~ MsgBox(0,"Error & Extended", "Error: " & $err & @CRLF & "Extended: " & $ext)


;~ $Comm = _ID3GetTagField($Filename, "COMM")
;~ $err = @error
;~ $ext = @extended
;~ MsgBox(0,"$Comm",$Comm)
;~ MsgBox(0,"Error & Extended", "Error: " & $err & @CRLF & "Extended: " & $ext)


;_ID3DeleteFiles()