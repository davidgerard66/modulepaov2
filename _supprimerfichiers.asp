<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%
			function v(champ)
			
				v = renvoi(rs,champ)
			
			end function

id_com = request.querystring("id_com")
sql = "select * from commandes_lignes_fichiers where id_com = " & id_com


ouvrirtable mm_frans_string, rs, sql
ctr=0

		while not rs.eof
			supprimefichier v("fichier_path")	& v("fichier_nom")
		ctr=ctr+1
		rs.movenext
		wend

fermertable rs


%>