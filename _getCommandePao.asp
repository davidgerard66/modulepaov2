<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%
response.ContentType = "application/json"

			function v(champ)
			
				v = renvoi(rs,champ)
			
			end function
id_com = request.querystring("id_com")

sql = "select c.*, cli.email as email,rtrim(i.statut) as statut_bat, i.date_CREATION as date_bat, u.prenom as userNom from commandes c"
sql = sql & " inner join clients cli on c.id_client = cli.id_client "
sql = sql & " left outer join utilisateurs u on u.id_user = c.assigner_user"
sql = sql & " LEFT OUTER JOIN Impression_statut i ON i.id_com = c.id_com AND i.id_enr =( SELECT MAX(id_enr) FROM impression_statut i2 WHERE i2.id_com = c.id_com )"
sql = sql & " where c.id_com =  "  & id_com
'response.write("<h3>"&sql&"</h3>")

ouvrirtable mm_frans_string, rs, sql
ctr=0

		while not rs.eof
		
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
						
			 
			   pao_needed = v("pao_needed")
			   prepress_needed = v("prepress_needed")
			   
			   if pao_needed = "oui" then pao_needed="true" else  pao_needed="false"
			    if prepress_needed = "oui" then prepress_needed="true" else  prepress_needed="false"
			 
			 commande = commande & """Id_com"": "&v("id_com")&", ""Id_web"": "&v("id_com_web")&", ""Canal"": """& v("groupe_canal") &""", ""Confirmation"": """& date_confirmation &""", ""Priorite"": """& v("groupe_priorite")&""", ""Nom"": """& v("Nom prenom")&""", ""Email"": """& v("Email")&""", ""BAT"": """&statut_bat&""", ""pao_needed_raison"": """&v("pao_needed_raison")&""",""pao_needed"": "&pao_needed&",""prepress_needed"": "&prepress_needed &", ""cheminsource"": ""\\\\brian\\DATA\\ED-PAO\\SOURCES\\"", ""Assignation"": """& assignation &""""
			
		ctr=ctr+1
		rs.movenext
		wend

fermertable rs


			
				  sql = " Select cl.*, fic.fichier_nom as fichier_nom, fic.fichier_path as fichier_path, fic.fichier_source as fichier_source,fic.fichier_source_type as fichier_source_type,  a.groupe_stock_modele as typeArticle from commandes_lignes cl "
				  sql = sql & " left outer join articles a on a.ref=cl.ref "
			sql = sql & " left outer join commandes_lignes_fichiers as fic on fic.id_ligne = cl.id_enr "
			sql = sql & " where cl.id_com = " & id_com & " and ( cl.ref not like 'ac%' and cl.ref not like 'e%' and cl.ref not like 'dg%' and cl.ref not like 't%' ) order by cl.id_enr asc"
			
			'response.write(sql)
			ouvrirtable mm_frans_string, rs, sql
			ctr=0
					
					
					
					while not rs.eof
					fichier_path = v("fichier_path")
					fichier_nom = v("fichier_nom")
					fichier_source = v("fichier_source")
					fichier_source_type = v("fichier_source_type")
					
				
					
							if ctr > 0 then contenu = contenu & ","
							contenu = contenu &"{""index"":"&ctr+1&",""id_ligne"": "&v("id_enr")&", ""ref"": """&v("ref")&""", ""quantite"": "& v("quantite") &",""typearticle"": """&UCASE(v("typearticle"))&""",""imprime"": """&v("impression")&""",""fichier_source"":"""&fichier_source&""",""fichier_source_type"":"""&fichier_source_type&""",""fichier"": """&fichier_nom&""",""chemin"": """&replace(fichier_path,"\","\\")&""""
					        
							if fichier_nom <> "" then 
							     
								datemodif =  fichierdatemodification(fichier_path&fichier_nom)
								if datemodif<>"" then 
								existe="true" 
								else 
								existe="false"
								end if
							else
								existe="false"
							end if
							
							contenu = contenu & ", ""existe"":"&existe&",""date_modification"":"""&datemodif&""""
							
							existe_source="false"
							if fichier_source <> "" then 
								if fichierexiste("D:\ED-PAO\SOURCES\"&fichier_source_type&"\"&fichier_source&".pdf") then existe_source="true" 
							end if
							
							contenu = contenu & ", ""existe_source"":"&existe_source
							
							
							contenu = contenu & "}"
							
							
					ctr=ctr+1
					rs.movenext
					wend
			
 
 
 commande = commande & ",""contenu"":["& contenu &"]"
 commande = commande & "}"
 
response.write(commande)

%>