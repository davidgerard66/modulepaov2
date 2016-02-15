<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%
Function Base64Data2Stream(sData)
    Set Base64Data2Stream = Server.CreateObject("Adodb.Stream")
        Base64Data2Stream.Type = 1 'adTypeBinary
        Base64Data2Stream.Open
    With Server.CreateObject("MSXML2.DomDocument.6.0").createElement("b64")
        .dataType = "bin.base64"
        .text = sData
        'response.write(.nodeTypedValue)
		Base64Data2Stream.Write .nodeTypedValue 'write bytes of decoded base64 to stream
        Base64Data2Stream.Position = 0
    End With
End Function


if request.form("id_com")<>""  then 


id_com = request.form("id_com")

nom_fichier = request.form("nom_fichier")

databin = request.form("fichier")
destination = request.form("destination")
id_ligne = 		request.form("id_ligne")										

if instr(ucase(nom_fichier),".INDT")>0 then destination = replace(destination,".pdf",".indd")
response.write("<br>" & destination)

'Write binary to Response Stream
'Response.BinaryWrite CanvasStream.Read
'Write binary to File

														'Set objFSO = CreateObject("Scripting.FileSystemObject")
															'	If not objFSO.FolderExists("D:\ED-PAO\PROD\"&id_com) Then 
															'			objFSO.CreateFolder("D:\ED-PAO\PROD\"&id_com) ' creation du dossier cmd 
														  '      end if
														'set objFSO=nothing

Dim CanvasStream
Set CanvasStream = Base64Data2Stream(databin)
CanvasStream.SaveToFile destination, 2                    'adSaveCreateOverWrite


end if
%>
