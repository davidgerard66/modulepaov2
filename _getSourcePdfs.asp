<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%


id_com = request.querystring("id_com")
root_pao = "D:\ED-PAO\PROD\" & id_com

Set FSO = CreateObject("Scripting.FileSystemObject")
set folder = FSO.GetFolder (root_pao) 'utilisation du FSO pour prendre le dossier
			Set fic = folder.Files 'definition de la variables toucher les fichier des dossier
			
			ctr=0
			for each f in fic
			if ctr>0 then fichiers = fichiers & ","
			fichiers = fichiers & """"&f.name&""""
			ctr=ctr+1
			next

			fichiers = "[" & fichiers & "]"
			response.write(fichiers)
%>