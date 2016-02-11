<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%
response.ContentType = "application/json"


			function v(champ) ' je gagne du temps et de la l
				v = renvoi(rs,champ)
			end function

sql = "select  c.id_com,c.id_com_web,rtrim(c.groupe_canal) as groupe_canal,rtrim(c.groupe_activite) as groupe_activite,rtrim(c.groupe_priorite) as groupe_priorite,c.date_statut,rtrim(c.nom) as nom, rtrim(c.prenom)as prenom,c.assigner_user,  c.pao_needed_raison as service, rtrim(i.statut) as statut_bat, i.date_CREATION as date_bat, u.prenom as userNom, fics.indigo as jobs_indigo, fics.phaser as jobs_phaser  from commandes as c with (NOLOCK) "
'sql  = sql & " inner join (select id_com,cl.ref from commandes_lignes cl left outer join hotfolders h on cl.ref = h.ref where  cl.ref in ('NCONTROLE','MCONTROLE','ZEN','MBAT'" & refs & ") or (cl.ref like 'mc%' or cl.ref like 'mt%' or cl.ref like 'mn%') or h.indigonew like '%derpro%' group by id_com,cl.ref ) as cl on cl.id_com = c.id_com"  'on a plus besoin de ca de plus l'ajour de pao_needed_raison
sql = sql & "left outer join (select id_com, SUM(CASE f.imprimeur WHEN 'phaser' THEN 1 ELSE 0 END) phaser, SUM(CASE f.imprimeur WHEN 'indigo' THEN 1 ELSE 0 END) indigo  from commandes_lignes_fichiers f group by id_com) as fics on fics.id_com = c.id_com "
sql = sql & " left outer join utilisateurs u on u.id_user = c.assigner_user"
sql = sql & " LEFT OUTER JOIN Impression_statut i ON i.id_com = c.id_com AND i.id_enr =( SELECT MAX(id_enr) FROM impression_statut i2 WHERE i2.id_com = c.id_com )"

	grille = request.querystring("statut_bat")
	select case ucase(grille)
	
		case "NEW"
			sql = sql & " where c.pao_needed='oui' and c.statut_commande = 'confirme' and i.statut is null "
	
		case "BAT"
			sql = sql & " where c.pao_needed='oui'  and c.statut_commande = 'confirme' and i.statut = 'BAT'"
		
		case "BATOK"
			sql = sql & " where (c.pao_needed='oui' )  and c.statut_commande = 'confirme' and i.statut = 'BATOK'"
		 
		case "PREPRESS"  'commande bat ok mais prepress needed manuelle
			sql = sql & " where c.pao_needed='non' and c.prepress_needed='oui'  and c.statut_commande = 'confirme' " 'and i.statut = 'BATOK'"
		
		case else
			sql = sql & " where c.pao_needed='oui' and c.statut_commande = 'confirme' and i.statut is null "
			
	end select
	
	groupe_canal = request.querystring("groupe_canal")
	select case ucase(groupe_canal)
	
		case "PART"
			sql = sql & " and groupe_canal in ('PART','XMAS') "
	
		case "STAN"
			sql = sql & " and groupe_canal in ('STAN') "
		 
		case "AUTRES"
			sql = sql & " and groupe_canal not in ('PART','XMAS','STAN') "
		case else  'commande bat ok mais prepress needed manuelle
			sql = sql 
		
	
	end select
	
	
	
	

sql = sql & " order by c.id_com desc,service desc "

'response.write("<h3>"&sql&"</h3>")

utilisecache = true
ouvrirtable mm_frans_string, rs, "select max(id_com) as id_com from commandes where groupe_canal = 'part' and statut_commande = 'confirme'"
dernier_id_com = v("id_com")
fermertable rs

if application("dernier_id_com") <> dernier_id_com then 
utilisecache = false
application("dernier_id_com") = dernier_id_com
end if

if application("json_"&grille)="" then utilisecache = false
utilisecache=false
if not utilisecache then 

ouvrirtable mm_frans_string, rs, sql
ctr=0
id_com_en_cours=""
		while not rs.eof
			 
			 ' anti doublon
			 if instr(id_com_en_cours,v("id_com"))<1 then
			 
			 
			 		if ctr>0 then commande = commande & ","
			 commande = commande & "{"
			 
			 	if v("assigner_user") = "" then
				        assignation = "Non assigné" 
				        else 
						assignation = v("userNom")
						end if
			    
				date_confirmation = right(v("date_statut"),4) &"-"& mid(v("date_statut"),4,2) &"-"& left(v("date_statut"),2)
			 
			  
				if v("statut_bat") = "" then
						statut_bat = "A préparer" 
				        else 
						statut_bat = v("statut_bat") & " le " & v("date_bat")
						end if
					
					
				' calcul des alerrtes ,anomalies	
				alerte=""
				select case ucase(grille)
				
						case "NEW"
							 ' alerte pas de traitement de puis la confirmation , plus de 3 jours
							 if renvoidatelimite(rs.fields.item("date_statut").value,3)< date() then  alerte = alerte & "Aucune action"
							
						case "BAT"
							
							 ' alerte pas de bat valide dpeuis lenvoi , plus de 8 jours
							 if renvoidatelimite(rs.fields.item("date_bat").value,8)< date() then  alerte = alerte & "Le client n'a pas validé son bat" 
							
							
						case "PREPRESS" ' commande bat  ok mais prepress needed manuelle
						
					
				end select
					
				 id_com_web = v("id_com_web")
				 if id_com_web = "" then id_com_web = 0
			 
				 commande = commande & """Id_com"": "&v("id_com")&", ""Id_web"": "&id_com_web&", ""Canal"": """& v("groupe_canal") &""",""Activite"": """& v("groupe_activite") &""", ""Confirmation"": """& date_confirmation &""", ""Option"": """& v("service")&""", ""Priorite"": """& v("groupe_priorite")&""", ""Nom"": """& v("Nom prenom")&""", ""Email"": """", ""Alerte"": """&alerte&""", ""jobs_phaser"": """&v("jobs_phaser")&""",""jobs_indigo"": """&v("jobs_indigo")&""",""BAT"": """&statut_bat&""", ""Assignation"": """& assignation &""""
				 commande = commande & "}"
				 id_com_en_cours = id_com_en_cours & "-" & v("id_com")
				 dernier_service = v("service")
			 end if
			 
		ctr=ctr+1
		rs.movenext
		wend

fermertable rs
commande = "[" & commande & "]"
response.write(commande)


' cache maison


select case ucase(request.querystring("statut_bat"))
	
		case "NEW"
			application("json_new")=commande
	
		case "BAT"
			application("json_bat")=commande
		
		case "PREPRESS" ' commande bat  ok mais prepress needed manuelle
		
			application("json_prepress")=commande
			
	end select
	
else

response.write(application("json_"&grille))
end if


%>