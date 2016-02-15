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
						statut_bat = "AUCUN" 
				        else 
						statut_bat = v("statut_bat") & " le " & v("date_bat")
						end if
						
			 
			   pao_needed = v("pao_needed")
			   prepress_needed = v("prepress_needed")
			   production_autorise = v("production_autorise")
			   
			   if pao_needed = "oui" then pao_needed="true" else  pao_needed="false"
			    if prepress_needed = "oui" then prepress_needed="true" else  prepress_needed="false"
			 if production_autorise = "oui" then production_autorise = "true" else production_autorise = "false"
			 
			if  v("id_com_web")="" then id_com_web="0" else id_com_web =  v("id_com_web")
			 
			 commande = commande & """Id_com"": "&v("id_com")&", ""Id_web"": "&id_com_web&", ""Id_client"": "&v("id_client")&", ""Canal"": """& v("groupe_canal") &""", ""Confirmation"": """& date_confirmation &""", ""Priorite"": """& v("groupe_priorite")&""", ""Nom"": """& v("Nom prenom")&""", ""Email"": """& v("Email")&""", ""BAT"": """&statut_bat&""", ""pao_needed_raison"": """&v("pao_needed_raison")&""",""pao_needed"": "&pao_needed&",""prepress_needed"": "&prepress_needed &",""production_autorise"": "&production_autorise &", ""cheminsource"": ""\\\\brian\\DATA\\ED-PAO\\SOURCES\\"", ""Assignation"": """& assignation &""""
			
		ctr=ctr+1
		rs.movenext
		wend

fermertable rs


			
				  sql = " Select cl.*, fic.imprimeur as imprimeur,fic.fichier_nom as fichier_nom, fic.fichier_path as fichier_path, fic.fichier_source as fichier_source,fic.fichier_source_type as fichier_source_type,  a.groupe_stock_modele as typeArticle " &_
				  " , q.id_enr as id_ordre, q.statut as statut_ordre, q.statut_plancheur as statut_plancheur" &_
				  " from commandes_lignes cl "
				  sql = sql & " left outer join articles a on a.ref=cl.ref "
			sql = sql & " left outer join commandes_lignes_fichiers as fic on fic.id_ligne = cl.id_enr "
			sql = sql & " left outer join production_queue as q on q.id_fichier = fic.id_enr "
			sql = sql & " where cl.id_com = " & id_com & " and ( cl.ref not like 'ac%' and cl.ref not like 'e%' and cl.ref not like 'dg%' and cl.ref not like 't%' ) order by cl.id_enr asc"
			
			'response.write(sql)
			ouvrirtable mm_frans_string, rs, sql
			ctr=0
					
					
					
					while not rs.eof
					fichier_path = v("fichier_path")
					fichier_nom = v("fichier_nom")
					fichier_source = v("fichier_source")
					fichier_source_type = v("fichier_source_type")
					
					id_ordre = v("id_ordre")
					statut_ordre = v("statut_ordre")
					statut_plancheur = v("statut_plancheur")
				
					
							if ctr > 0 then contenu = contenu & ","
							contenu = contenu &"{""index"":"&ctr+1&",""id_ligne"": "&v("id_enr")&", ""ref"": """&v("ref")&""", ""quantite"": "& v("quantite") &",""typearticle"": """&UCASE(v("typearticle"))&""",""imprimeur"": """&v("imprimeur")&""",""imprime"": """&v("impression")&""",""fichier_source"":"""&fichier_source&""",""fichier_source_type"":"""&fichier_source_type&""",""id_ordre"": """&id_ordre&""",""statut_ordre"": """&statut_ordre&""",""statut_plancheur"": """&statut_plancheur&""",""fichier"": """&fichier_nom&""",""chemin"": """&replace(fichier_path,"\","\\")&""""
					        
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