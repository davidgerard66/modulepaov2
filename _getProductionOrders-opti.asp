<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%
response.ContentType = "application/json"

			function v(champ)
				v = renvoi(rs,champ)
			end function

if request.querystring("id_com")<>"" then id_com = request.querystring("id_com")

date_debut = "01/01/1900"
date_fin = date()+1
if request.querystring("jobDateDebut")<>"" then date_debut  = request.querystring("jobDateDebut")
if request.querystring("jobDateFin")<>"" then date_fin  = Cdate(request.querystring("jobDateFin"))  +1


' todo ajouter la valeur vernis total aux ordres

sql = "SELECT  q.*, rtrim(h.hotfolder) as code_planche,  " &_
	  " h.scodix as scodix , fics.id_com as id_com, fics.id_ligne as id_ligne," &_
	  " rtrim(c.groupe_priorite) as priorite, rtrim(hp.papier) as papier, round(q.quantite/hcp.imposition,0)+3 as feuilles," &_
	  " cl.vernistotal as vernistotal FROM  Production_queue q"
	  
sql = sql & " left outer join hotfolders h  on q.ref = h.ref left outer join hotfolders_CODES_plancheur hcp on hcp.code_planche = h.hotfolder  left outer join hotfolders_papiers hp on hp.hotfolder = h.indigonew "


sql = sql & " inner join commandes_lignes_fichiers fics on fics.id_enr = q.id_fichier"
sql = sql & " inner join commandes c on fics.id_com = c.id_com"
sql = sql & " inner join commandes_lignes cl on cl.id_enr = fics.id_ligne"

if id_com <> "" then 
sql = sql & " where fics.id_com = " & id_com
else
sql = sql & " where (q.statut='new') and c.statut_commande = 'confirme' and c.id_com > 16011418 and fics.id_com >= 16011418 and q.date_creation >= '"&date_debut&"' and q.date_creation <= '"&date_fin&"' "



select case request.querystring("statut_plancheur")
case ""
if ucase(request.querystring("imprimeur"))="PHASER" then sql = sql & "  and ( q.imprimeur = 'PHASER'  )" else  sql = sql & "  and (q.statut_plancheur=2) and ( q.imprimeur is null or q.imprimeur <> 'PHASER'  )"
' and q.fichier_planche is not null"

case else
sql = sql & "  and (q.statut_plancheur="&request.querystring("statut_plancheur")&") and ( q.imprimeur is null or q.imprimeur <> 'PHASER'  )"

end select

end if

sql = sql & " order by q.date_creation desc "
'response.write("<h3>"&sql&"</h3>")

ouvrirtable mm_frans_string, rs, sql
ctr=0

		while not rs.eof
		
			if ctr>0 then data = data & ","
			 data = data & "{"
			 
			 finition = ""
			 scodix = trim(v("scodix"))
			 if scodix = "oui" then finition = "SX"
		
			 
			  code_planche = v("code_planche")
			 if code_planche = "" then code_planche = "N/A"
			 
			feuilles = v("feuilles")
			if feuilles ="" then feuilles = 0
			
			vernistotal = lcase(v("vernistotal"))
			if scodix = "" and (vernistotal="oui") then finition = "UV" 
			
			if finition = "" then finition ="NON"
		
			
			'fichier_planche = replace(v("fichier_planche"),"\","\\")
			
			
		'	if ucase(v("horizon")) = "OUI" then decoupe = "Horizon" else decoupe = "Duplo"
			
			ref = v("ref")
			if left(ucase(ref),1)="M" then genre = "Mar" else genre = "Nais"
			
			
			' fichier_carte = v("fichier_path") & v("fichier_nom")
			' fichier_carte = replace(fichier_carte,"\","\\")

			 priorite =  ucase(v("priorite"))
			 if priorite = "CLAIM" then priorite = "EXPRESS"
			 
			 date_creation = left(v("date_creation"),13)
			 date_creation = replace(date_creation,"/2016","")
			 
			 data = data & """id_ordre"":"&v("id_enr")&",""Id_com"":"&v("id_com")&",""id_ligne"":"&v("id_ligne")&",""id_fichier"":"&v("id_fichier")&",""date_creation"":"""& date_creation &""",""quantite"":"&  v("quantite")  & ",""feuilles"": "& feuilles  & ",""genre"":"""& genre &""",""ref"":"""& ref &""",""code_planche"":"""& ucase(code_planche) &""",""papier"":"""& ucase(v("papier")) &""",""finition"":"""& finition &""",""statut"":"""& v("statut") &""",""date_statut"":"""& v("date_statut") &""",""imprimeur"":"""& v("imprimeur") &""",""priorite"":"""& priorite &""""
			 data = data & "}"
		ctr=ctr+1
		rs.movenext
		wend

fermertable rs
data = "[" & data & "]"


response.write(data)

%>