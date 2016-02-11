<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%
response.ContentType = "application/json"

			function v(champ)
			
				v = renvoi(rs,champ)
			
			end function
			function v2(champ)
			
				v2 = renvoi(rs2,champ)
			
			end function
			
			function renvoi_groupe_picking()
			select case ucase(v("groupe_stock_modele"))
				case "SERVICE"
				renvoi_groupe_picking = "SERVICES"
				CASE else
					 laref = ucase(v("ref"))
					 if UCASE(v("id_emplacement"))="EXPED" then renvoi_groupe_picking = "DIVERS"
					 if left(laref,1)="E" then renvoi_groupe_picking = "ENVELOPPES"
					 if left(laref,2)="AC" then renvoi_groupe_picking = "ACCESSOIRES"
					 if 	renvoi_groupe_picking="" then renvoi_groupe_picking="CARTES"			 					  					  
				
			end select
			end function
			

			function creer_ligne_picking(groupe,art_en_cours,q,emplacement,impression,vernistotal,designation,id_ligne)
				ligne_picking = "{""Groupe"":""@groupe@"", ""Article"":""@ref@"", ""Quantite"":@q@, ""Emplacement"":""@emplacement@"", ""Impression"":""@impression@"", ""Vernistotal"":""@vernistotal@"",""Designation"":""@designation@"",""id_ligne"":@id_ligne@,""pret"":false}"
				
				designation = replace(designation,""""," ")
				designation = replace(designation,"'"," ")
				
				
				ligne_picking = replace(ligne_picking,"@groupe@",groupe)
				ligne_picking = replace(ligne_picking,"@ref@",art_en_cours)
				ligne_picking = replace(ligne_picking,"@q@",q)
				ligne_picking = replace(ligne_picking,"@emplacement@",emplacement)
				ligne_picking = replace(ligne_picking,"@impression@",impression)
				ligne_picking = replace(ligne_picking,"@vernistotal@",vernistotal)
				ligne_picking = replace(ligne_picking,"@designation@",designation)
				ligne_picking = replace(ligne_picking,"@id_ligne@",id_ligne)
				
				creer_ligne_picking = ligne_picking
			end function
			
			
id_com = request.querystring("id_com")

sql = "SELECT cl.id_enr as id_ligne,a.ref AS ref, cl.designation, cl.quantite, a.id_emplacement, a.Groupe_stock_modele, cl.impression, replace(cl.vernistotal,'OUI','VERNIS') as vernistotal FROM         Commandes_Lignes cl INNER JOIN                       Articles a ON cl.ref = a.ref WHERE     (cl.id_com = @id_com@) AND (cl.ref NOT LIKE '%*%') UNION ALL SELECT  cl.id_enr as id_ligne,   a.ref AS ref, a.designation, ceiling(cl.quantite * k.quantite), a.id_emplacement, a.Groupe_stock_modele, cl.impression, replace(cl.vernistotal,'OUI','VERNIS') as vernistotal FROM         Commandes_Lignes cl INNER JOIN                       KIT_lignes k ON cl.ref = k.KIT INNER JOIN                      Articles a ON k.ref = a.ref WHERE     (cl.id_com = @id_com@) AND (cl.ref LIKE '%*%')   ORDER BY a.ref"

sql = replace(sql,"@id_com@",id_com)


'response.write("<h3>"&sql&"</h3>")

ouvrirtable mm_frans_string, rs, sql
ctr=0
nb_ligne=0
art_en_cours = ""

		while not rs.eof
			
			art = v("ref")
			
			
			if ctr=0 then 
			art_en_cours =  art
				
				
				gsm = v("groupe_stock_modele")
				designation = 	v("designation")			
				emplacement = v("id_emplacement")
				impression  = 		v("impression")	
				vernistotal = v("vernistotal")	
				id_ligne = v("id_ligne")
				groupe = renvoi_groupe_picking()
			
			end if
			
			
			if renvoi_groupe_picking()="CARTES" then 
										
										if art <>art_en_cours and art_en_cours <> "" then
												ligne_en_cours = creer_ligne_picking(groupe,art_en_cours,q,emplacement,impression,vernistotal,designation,id_ligne)
												if nb_ligne > 0 then commande = commande & ","
												commande = commande & ligne_en_cours
												nb_ligne=nb_ligne+1	
										end if
										
										art_en_cours = art
										q = v("quantite")
										gsm = v("groupe_stock_modele")
										designation = 	v("designation")			
										emplacement = v("id_emplacement")
										impression  = 		v("impression")	
										vernistotal = v("vernistotal")	
										id_ligne = v("id_ligne")
										groupe = renvoi_groupe_picking()	
										
										ligne_en_cours = creer_ligne_picking(groupe,art_en_cours,q,emplacement,impression,vernistotal,designation,id_ligne)
										if nb_ligne > 0 then commande = commande & ","
										commande = commande & ligne_en_cours
										nb_ligne=nb_ligne+1	
										art_en_cours =""
			
			
			else  ' c un picking pur ou un sercvice
						
						if art <> art_en_cours or art_en_cours =""then  ' on sauve la ligne de picking et en recree une nouvelle
							
							
							if art_en_cours <> "" then
								ligne_en_cours = creer_ligne_picking(groupe,art_en_cours,q,emplacement,impression,vernistotal,designation,id_ligne)
								if nb_ligne > 0 then commande = commande & ","
								commande = commande & ligne_en_cours
								nb_ligne=nb_ligne+1
							end if
										
										art_en_cours = art
										q = v("quantite")
										gsm = v("groupe_stock_modele")
										designation = 	v("designation")			
										emplacement = v("id_emplacement")
										impression  = 		v("impression")	
										vernistotal = v("vernistotal")	
										id_ligne = v("id_ligne")
										groupe = renvoi_groupe_picking()			
							
							else ' si c la meme ref, on additionne les quantités
							
									 q= cint(q) + cint(v("quantite"))
									
														
						
						end if
			
			end if
			
			
			
			
			
			
			
			
		ctr=ctr+1
		rs.movenext
		wend
						if art_en_cours <> "" then	
							ligne_en_cours = creer_ligne_picking(groupe,art_en_cours,q,emplacement,impression,vernistotal,designation,id_ligne)
							if nb_ligne > 0 then commande = commande & ","
							commande = commande & ligne_en_cours
							nb_ligne=nb_ligne+1
						end if
fermertable rs


' infocoimmande
sql = "select * from commandes where id_com = " & id_com
ouvrirtable mm_frans_string, rs, sql

if v("groupe_canal")="STAN" then adr_livraison = libelle_livraisoncommande_de(id_com) else adr_livraison = libelle_livraisoncommande(id_com)
adr_livraison = replace(adr_livraison,"""","'")
adr_livraison = replace(adr_livraison,chr(13),"\n")
  
  entete = """id_com"":"&id_com&",""pays_livraison"":"""&v("pays")&""",""nom"":"""&v("nom prenom")&""",""societe"":"""&v("societe")&""",""groupe_canal"":"""&v("groupe_canal")&""",""groupe_activite"":"""&v("groupe_activite")&""",""adr_livraison"":"""&adr_livraison&""",""statut_commande"":"""&v("statut_commande")&""",""Transporteur"":"""&v("transport_mode")&""""



fermertable rs



commande = "{"& entete & ",""contenu"":["&commande&"]}"
response.write(commande)
			
%>