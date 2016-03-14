<%@LANGUAGE="VBSCRIPT"  %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%
response.ContentType = "application/json"
Response.CodePage = 65001
Response.CharSet = "UTF-8"
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

sql = "select l.*, (l.date_creation) as date_creation, l.activite as activite, rtrim(u.prenom) as prenom, q.ref as ref,q.quantite as quantite, q.quantite_feuilles as qfeuilles, rtrim(q.imprimante) as imprimante, RTRIM(q.statut)as statut_ordre from log_pao l inner join utilisateurs u on l.id_user = u.id_user  inner join commandes c on c.id_com =l.id_com "
sql = sql &  " left outer join production_queue q on q.id_enr = l.id_ordre"

nbjourshisto = 15
if request.querystring("id_com")<>"" then 
sql = sql &  " where l.id_com = " & request.querystring("id_com")
nbjourshisto = 180
end if
etape = request.querystring("etape")
if etape<>"" then sql = sql &  " where l.etape like '%" & request.querystring("etape")&"%'"
if etape = "imprimerie" then sql = sql & " and c.statut_commande = 'confirme' "

sql = sql & " and l.date_creation >= '"&date()-nbjourshisto&"' order by l.date_creation desc, l.id_ordre"
'response.write("<h3>"&sql&"</h3>")

ouvrirtable mm_frans_string, rs, sql
ctr=0

		while not rs.eof
		
		ACTIVITE = replace(v("activite"),"'","'")
		ACTIVITE = replace(ACTIVITE,chr(13),"\n")
		ACTIVITE = replace(ACTIVITE,chr(10),"\n")
		ACTIVITE = replace(ACTIVITE,"""","\""")
		activite = removeAccents(activite)
		if etape = "IMPRIMERIE" then  activite = left(activite,14)&".."
		
		datejob = left(v("date_creation"),13) 
		datejob = replace(datejob,"/2016","")
		datejob = replace(datejob," 2016","")
		
			if ctr>0 then commande = commande & ","
			 commande = commande & "{"
			 
			 
			 
			 commande = commande & """id_com"": "&v("id_com")&",""user"":{""id"": "&v("id_user")&",""nom"":"""&v("prenom")&"""},""activite"": """& ACTIVITE &""",""id_ordre"": "& j(v("id_ordre")) &", ""statut_ordre"": """&  v("statut_ordre") &""",""ref"":"""&  v("ref") &""", ""quantite"":"""&  v("quantite") &""",""qfeuilles"": """&  v("qfeuilles") &""",""imprimante"": """&  v("imprimante") &""",""date_creation"": """& datejob &""""
			 commande = commande & "}"
		ctr=ctr+1
		rs.movenext
		wend

fermertable rs
commande = "[" & commande & "]"


response.write(commande)

%>