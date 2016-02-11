<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%
response.ContentType = "application/json"

			function v(champ)
			
				v = renvoi(rs,champ)
			
			end function
			function j(valeur) ' valeur json compatible version moi
				if valeur = "" then 
				valeur = "null"
				else
				valeur = replace(valeur,"\","\\")
				valeur = replace(valeur,"""","""""")
				end if
				j = valeur
			end function

sql = "select l.*, l.date_creation as date_creation, u.prenom as prenom, q.ref as ref,q.quantite as quantite from log_pao l inner join utilisateurs u on l.id_user = u.id_user "
sql = sql &  " left outer join production_queue q on q.id_enr = l.id_ordre"

if request.querystring("id_com")<>"" then sql = sql &  " where l.id_com = " & request.querystring("id_com")
if request.querystring("etape")<>"" then sql = sql &  " where l.etape like '%" & request.querystring("etape")&"%'"
sql = sql & " order by date_creation desc "
'response.write("<h3>"&sql&"</h3>")

ouvrirtable mm_frans_string, rs, sql
ctr=0

		while not rs.eof
		
			if ctr>0 then commande = commande & ","
			 commande = commande & "{"
			 
			 
			 commande = commande & """id_com"": "&v("id_com")&", ""user"" : {""id"": "&v("id_user")&",""nom"": """&v("prenom")&"""}, ""activite"": """& v("activite") &""", ""id_ordre"": "& j(v("id_ordre")) &", ""ref"": """&  v("ref") &""", ""quantite"": """&  v("quantite") &""", ""date_creation"": """&  v("date_creation") &""""
			 commande = commande & "}"
		ctr=ctr+1
		rs.movenext
		wend

fermertable rs
commande = "[" & commande & "]"


response.write(commande)

%>