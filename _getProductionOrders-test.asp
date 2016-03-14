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
	  " rtrim(h.scodix) as scodix , fics.id_com as id_com, fics.id_ligne as id_ligne, rtrim(fics.fichier_path) as fichier_path, rtrim(fics.fichier_nom) as fichier_nom," &_
	  " rtrim(c.groupe_priorite) as priorite, rtrim(c.groupe_activite) as groupe_activite, rtrim(hp.papier) as papier, round(q.quantite/hcp.imposition,0)+3 as feuilles," &_
	  " rtrim(cl.vernistotal) as vernistotal FROM  Production_queue q"
	  
sql = sql & " left outer join hotfolders h  on q.ref = h.ref left outer join hotfolders_CODES_plancheur hcp on hcp.code_planche = h.hotfolder  left outer join hotfolders_papiers hp on hp.hotfolder = h.indigonew "
sql = sql & " inner join commandes_lignes_fichiers fics on fics.id_enr = q.id_fichier"
sql = sql & " inner join commandes_lignes cl on cl.id_enr = fics.id_ligne"
sql = sql & " inner join commandes c on fics.id_com = c.id_com"


sql = "select * from production_orders_vue "

'if id_com <> "" then 
'sql = sql & " where fics.id_com = " & id_com
'else
'sql = sql & " where (q.statut='new') and c.statut_commande = 'confirme' and c.id_com > 16011418 and fics.id_com >= 16011418 and q.date_creation >= '"&date_debut&"' and q.date_creation <= '"&date_fin&"' "


if id_com <> "" then 
sql = sql & " where id_com = " & id_com
else
sql = sql & " where (statut='new') and date_creation >= '"&date_debut&"' and date_creation <= '"&date_fin&"' "



select case request.querystring("statut_plancheur")
	case ""
			
			select case  ucase(request.querystring("imprimeur"))  ' todo ajouter imprimeur de papier coupé
			case "PHASER"
					sql = sql & "  and ( imprimeur = 'PHASER'  )"   ' cas phaser
			case "INDIGON"
					sql = sql & "  and (statut_plancheur=2) and ((ref not like 'm%') or ( groupe_priorite = 'EXPRESS' or groupe_activite='VIERGE')) and ( imprimeur is null or imprimeur <> 'PHASER'  )"  ' cas indigo
			case "INDIGO"
					sql = sql & "  and (statut_plancheur=2) and (ref like 'm%') and (groupe_priorite <> 'EXPRESS' and groupe_activite <> 'VIERGE' ) and  (imprimeur is null or imprimeur <> 'PHASER'  )"  ' cas indigo
			case else  
					sql = sql & "  and (statut_plancheur=2) and ( imprimeur is null or imprimeur <> 'PHASER'  )"  ' cas indigo
			end select
	' and q.fichier_planche is not null"
	case else
	sql = sql & "  and (statut_plancheur="&request.querystring("statut_plancheur")&") and ( imprimeur is null or imprimeur <> 'PHASER'  )"
end select

end if

sql = sql & " order by date_creation desc "
'response.write("<h3>"&sql&"</h3>")

ouvrirtable mm_frans_string, rs, sql
ctr=0

		while not rs.eof
	
			if ctr>0 then data = data & ","
		'	 data = data & "{"
			 
			' finition
			 finition = "NON"
			 vernistotal = lcase(rs.fields.item("vernistotal").value)
			 if  (rs.fields.item("scodix").value) = "oui" then 
			 					finition = "SX"
								else
								if (vernistotal="oui") then finition = "UV" 
								end if
			
			
	
			  code_planche = rs.fields.item("code_planche").value
			 if code_planche = "" then code_planche = "N/A"
			 
			feuilles = rs.fields.item("feuilles").value
			if feuilles ="" then feuilles = 0

			ref = v("ref")
			if left(ucase(ref),1)="M" then genre = "Mar" else genre = "Nais"
			
			 if ucase(request.querystring("imprimeur")) = "PHASER" then
			 fichier_carte = replace (v("fichier_path") & v("fichier_nom"),"\","\\")
			 else
			 fichier_carte=""
			 end if

			 priorite =   replace(ucase(V("groupe_priorite")),"NORMAL","")
			 if priorite = "CLAIM" or rs.fields.item("groupe_activite").value ="VIERGE" then priorite = "EXPRESS"
			
			 
			 date_creation = left(v("date_creation"),13)
			 date_creation = replace(date_creation,"/2016","")
			 
		
		
			 data = data & ( "{""id_ordre"":"&rs.fields.item("id_enr").value&",""Id_com"":"&rs.fields.item("id_com").value&",""id_ligne"":"&rs.fields.item("id_ligne").value&",""id_fichier"":"&rs.fields.item("id_fichier").value&",""date_creation"":"""& date_creation &""",""quantite"":"&  rs.fields.item("quantite").value  & ",""feuilles"": "& feuilles  & ",""genre"":"""& genre &""",""ref"":"""& ref &""",""code_planche"":"""& ucase(code_planche) &""",""papier"":"""& ucase(rs.fields.item("papier").value) &""",""finition"":"""& finition &""",""fichier_carte"":"""& fichier_carte &""",""statut"":"""& rtrim(rs.fields.item("statut").value) &""",""date_statut"":"""& left(rs.fields.item("date_statut").value,16) &""",""imprimeur"": """& rtrim(rs.fields.item("imprimeur").value) &""",""priorite"":"""& priorite &"""}" )
'			 data = data & "}"
		ctr=ctr+1
		rs.movenext
		wend

fermertable rs
data = "[" & data & "]"


response.write(data)

%>