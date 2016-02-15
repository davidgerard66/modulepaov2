<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%


			function v(champ)
			
				v = renvoi(rs,champ)
			
			end function
	
	
	
	id_com = request.querystring("id_com")
	cbon = false
	ouvrirtable mm_frans_string, rs, "select * from commandes_lignes_fichiers fic inner join production_queue q on fic.id_enr = q.id_fichier " &_	
		" where q.statut in ('new','rippé') and fic.id_com = " & id_com
		
		if not rs.eof then ' ca crains ya deja des jobs en cours
		response.write("Impossible de mettre en production. Il y a déjà des jobs valides en cours")
		ajoutejournal "PAO",session("id_user"),id_com,"Echec de Mise en production - doublon de Job","0"		
		else
		cbon = true
		end if	
		
		fermertable rs
	
	
	if cbon then 
	
				if  not MetEnProduction(id_com) then 
								
								prepress_needed = "oui"
								pao_needed_raison = "aucun fichier"
									'mis a jour production
								modifiertable mm_frans_string, "update commandes set  pao_needed_raison = '" & pao_needed_raison & "' , prepress_needed='"&prepress_needed&"' where id_com = " & id_com 
								response.write("erreur " & pao_needed_raison)
								
				else
				modifiertable mm_frans_string, "update commandes set  pao_needed='non', pao_needed_raison = '" & pao_needed_raison & "' , prepress_needed='non' where id_com = " & id_com 
				end if
							response.write(id_com & " envoyée en impression avec succés.")
							ajoutejournal "PAO",session("id_user"),id_com,"Mise en production","0"			
	
	end if
	
	
%>
	    
	
    