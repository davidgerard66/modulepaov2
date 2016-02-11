<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%
			function v(champ)
			
				v = renvoi(rs,champ)
			
			end function

id_com = request.querystring("id_com")
sql = "update de_fpc_lignescommandes set sendpdf='', sendpdfdate=NULL,sendpdfislocked='',sendpdfislockeddate=NULL where id_com = " & id_com
MODIFIERTABLE mm_fpc3_string, sql


' todo journaliser
' todo notes-ed
' todo check si bat est ok
' check les ordres de productions peut etre si pas fait avant
' recalculer les paoneed et prepress et isproduisable





%>