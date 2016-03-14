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
			   statut_commande = v("statut_commande")
			  
				if v("statut_bat") = "" then
						statut_bat = "AUCUN" 
				        else 
						statut_bat = v("statut_bat") & " le " & v("date_bat")
						statut_bat_court = v("statut_bat")
						end if
						
			 
			   ref_client = replace(v("client_refcommande"),"""","""""")
			   ref_client = replace(ref_client,chr(13),"")
			   ref_client = replace(ref_client,chr(10),"")
			   
			   pao_needed = v("pao_needed")
			   prepress_needed = v("prepress_needed")
			   production_autorise = v("production_autorise")
			   PAO_visa_expedition = v("PAO_visa_expedition")
				
			   if pao_needed = "oui" then pao_needed="true" else  pao_needed="false"
			   if prepress_needed = "oui" then prepress_needed="true" else  prepress_needed="false"
			   if production_autorise = "oui" then production_autorise = "true" else production_autorise = "false"
			   if PAO_visa_expedition = "oui" then PAO_visa_expedition = "true" else PAO_visa_expedition = "false"
			 
			 
			 
			if  v("id_com_web")="" then id_com_web="0" else id_com_web =  v("id_com_web")
				
				 ' recup controle sur site : fait/pas fait
								    controle="non"
									pao_controle_ok=""
									pao_controle_ok_date=""	
									
				    if id_com_web<>"0" then
					
					 ouvrirtable mm_fpc_string,rsc,"select * from fpc_commandes where id_com =  " & id_com_web & " and  controle='oui'"
					 
					 		if not rsc.eof then 
							
								    controle="oui"
									pao_controle_ok = renvoi(rsc,"pao_controle_ok")
									pao_controle_ok_date =left( renvoi(rsc,"pao_controle_ok_date"),16)
									
								
							end if
					 
					 fermertable  rsc				
					
					end if
				 
				 
				 ' FIN RECUP controle sur site
			 
			 commande = commande & """Id_com"": "&v("id_com")&", ""Id_web"": "&id_com_web&", ""Id_client"": "&v("id_client")&", ""Canal"": """& v("groupe_canal") &""",""statut_commande"":"""&statut_commande&""", ""date_statut_commande"": """& date_confirmation &""", ""Priorite"": """& v("groupe_priorite")&""",""ref_client"": """& ref_client &""", ""Nom"": """& v("Nom prenom")&""", ""Email"": """& v("Email")&""", ""BAT"": """&statut_bat&""",""BATcourt"": """&statut_bat_court&""", ""pao_needed_raison"": """&v("pao_needed_raison")&""",""pao_needed"": "&pao_needed&",""prepress_needed"": "&prepress_needed &",""production_autorise"": "&production_autorise &",""PAO_visa_expedition"":"&PAO_visa_expedition&", ""cheminsource"": ""\\\\brian\\DATA\\ED-PAO\\SOURCES\\"", ""controle"": """& controle &""", ""pao_controle_ok"": """& pao_controle_ok &""", ""pao_controle_ok_date"": """& pao_controle_ok_date &""", ""Assignation"": """& assignation &""""
			
		ctr=ctr+1
		rs.movenext
		wend

fermertable rs


			
				  sql = " Select cl.*, fic.imprimeur as imprimeur,fic.fichier_nom as fichier_nom, fic.fichier_path as fichier_path, fic.fichier_source as fichier_source,fic.fichier_source_type as fichier_source_type,  a.groupe_stock_modele as typeArticle " &_
				  " , q.id_enr as id_ordre, q.statut as statut_ordre, q.receptionne as receptionne, q.reception_refuse as reception_refuse,q.range as range,q.range_emplacement as range_emplacement ,q.date_reception as date_reception, q.date_reception_refuse as date_reception_refuse,q.date_rangement as date_rangement,q.statut_plancheur as statut_plancheur" &_
				  " from commandes_lignes cl "
				  sql = sql & " left outer join articles a on a.ref=cl.ref "
			sql = sql & " left outer join commandes_lignes_fichiers as fic on fic.id_ligne = cl.id_enr "
			sql = sql & " left outer join (select * from production_queue where statut not in('annule','relance') and (composant is null or composant<>'oui') ) as q on q.id_fichier = fic.id_enr "
			sql = sql & " where cl.id_com = " & id_com & " and ( cl.ref not like 'ac%' and cl.ref not like 'e%' and cl.ref not like 'dg%' and cl.ref not like 't%' ) order by cl.id_enr asc, q.id_enr desc"
			
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
					
					receptionne = v("receptionne")
					reception_refuse = v("reception_refuse")
					statut_expedition = ""
					select case reception_refuse
					case "oui"
						statut_expedition = "Réception refusée le " & v("date_reception_refuse")
					case else
							select case receptionne
							case "oui"
							statut_expedition = "Réceptionné"
							if v("range")="oui" then statut_expedition = statut_expedition & " rangé en " & v("range_emplacement") & " le " & v("date_rangement")
							case else
							statut_expedition = ""
							end select
					end select
					
					statut_plancheur = v("statut_plancheur")
					imprimeur = v("imprimeur")
					ref = v("ref")
					format_ref_attendu = renvoiformatref(replace(ref,"*",""))	
					info_format=""
						if format_ref_attendu<>"" then 
							format_ref_attendu = split(format_ref_attendu,";")
									'response.write("@@@@"&ubound(format_ref_attendu)&"<hr>")
									
									if ubound(format_ref_attendu)=6 then
										
										longueur_attendu = format_ref_attendu(0)
										hauteur_attendu = format_ref_attendu(1)
										pages_attendu = format_ref_attendu(2)
										scodix = format_ref_attendu(3)
										if ucase(scodix) = "OUI" then scodix="SX" else scodix=""
										horizon = format_ref_attendu(4)
										if ucase(horizon) = "OUI" then decoupe="horizon" else decoupe="duplo"
										imposition = format_ref_attendu(5)
										hotfolder_indigo = format_ref_attendu(6)
										info_format = "Format réf: " & longueur_attendu & "x" & hauteur_attendu &" "& estrecto &" "& imposition &" poses " & scodix &" "& decoupe &" HF " &hotfolder_indigo																						
									
									end if
						end if
						
											
				    datemodif=""
					taille=""
					
					supportpdf = "carte"  ' le fichier est un fichier carte ou une planche, on initialise a carte
					erreurfichier="false"
					if v("id_enr")<>id_ligne then
					
					nb_pages_pdf=""
					longueur=""
					hauteur=""
					
							
									if ctr > 0 then contenu = contenu & ","
									contenu = contenu &"{""index"":"&ctr+1&",""id_ligne"": "&v("id_enr")&", ""ref"": """&v("ref")&""",""infoformat"": """&info_format&""", ""quantite"": "& v("quantite") &",""typearticle"": """&UCASE(v("typearticle"))&""",""imprimeur"": """&imprimeur&""",""imprime"": """&ucase(v("impression"))&""",""fichier_source"":"""&fichier_source&""",""fichier_source_type"":"""&fichier_source_type&""",""id_ordre"": """&id_ordre&""",""statut_ordre"": """&statut_ordre&""",""statut_expedition"": """&statut_expedition&""",""statut_plancheur"": """&statut_plancheur&""",""fichier"": """&fichier_nom&""",""chemin"": """&replace(fichier_path,"\","\\")&""""
									
									if fichier_nom <> "" then 
										 
										 infofichier = fichierinfo(fichier_path&fichier_nom)
										 if infofichier <> "" then 
												
												infofichier = split(infofichier,"@")
												datemodif = left(infofichier(0),16)
												taille = infofichier(1)
												
												infopdf = split(infofichier(2),";")
												
												if ubound(infopdf)=2 then
														
														nb_pages_pdf = infopdf(0)
														longueur = infopdf(1)
														hauteur = infopdf(2)
													    if longueur >= 320  and hauteur >= 320 then supportpdf="planche"
														
															 ' detection coherence format théoique et fichier phydique
															IF  imprimeur <> "INDIGO" THEN
															erreur_format = "Repiquage"
															else
															
																		if longueur_attendu <>0 then 
																				
																				 if supportpdf <> "planche" then
																				 erreur_format="ok"
																				 'response.write("<h1>ok</h1>")
																				
																				
																				
																				 gap_longueur = abs(cint(longueur) - cint(longueur_attendu))
																				 gap_hauteur = abs(cint(hauteur) - cint(hauteur_attendu))
																				
																				 if gap_longueur > 1 or gap_hauteur>1 then erreur_format =  " erreur de format pdf(" &longueur &"x" & hauteur &")"
																				
																				 end if
																				 gap_pages = 	 abs(cint(nb_pages_pdf) - cint(pages_attendu))	
																				 if gap_page <>0 then 	erreur_format = erreur_format & " nb pages incorrect"										
																		 
																		 else
																		  erreur_format =  "aucun hotfolder pour " & ref
																		 end if
														      end if
														else
														
														erreurfichier = "true"
												
												end if												
												
												
												
										 end if
										 
										
										if datemodif<>"" then 
										existe="true" 
										else 
										existe="false"
										end if
									else
										existe="false"
									end if
									
									contenu = contenu & ", ""existe"":"&existe&",""support"":""" & supportpdf  & """,""taille"":""" & taille  & """,""nb_pages_pdf"":""" & nb_pages_pdf & """,""longueur_pdf"":""" & longueur & """,""hauteur_pdf"":""" & hauteur &""",""erreurfichier"":" & erreurfichier &",""erreurformat"":""" & erreur_format &""",""date_modification"":"""&datemodif&""""
									
									existe_source="false"
									if fichier_source <> "" then 
										if fichierexiste("D:\ED-PAO\SOURCES\"&fichier_source_type&"\"&fichier_source&".pdf") then existe_source="true" 
									end if
									
									contenu = contenu & ", ""existe_source"":"&existe_source
									
									
									contenu = contenu & "}"
									
									id_ligne = v("id_enr")
					
					end if
							
					ctr=ctr+1
					rs.movenext
					wend
			
 
 
 commande = commande & ",""contenu"":["& contenu &"]"
 commande = commande & "}"
 
response.write(commande)

%>