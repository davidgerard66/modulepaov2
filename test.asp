<%

Dim FSO
		
		 
		'instantation du file system object (FSO)
		Set FSO = CreateObject("Scripting.FileSystemObject") 
		
		
fic = "\\plancheur\FICHIERSPOD\ED-INDIGO\1-1-2016\16000013-218527-2-(MI17-011-W x 30).pdf"
Dim fichiers
Set fichiers=Server.CreateObject("Scripting.Dictionary")
fichiers.Add fic,fic

For Each objFile in fichiers 
Set f = fso.GetFile(objfile)
response.write(f.path&"<br>"&f.name&"<br>"&f.DateLastModified )
next
%>