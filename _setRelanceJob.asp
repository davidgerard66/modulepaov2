<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%
			function v(champ)
				v = renvoi(rs,champ)
			end function
	id_com = request.querystring("id_com")
	id_ordre = request.querystring("id_ordre")
	imprimante = request.querystring("imprimante")
	raison_ordre = request.querystring("raison_ordre")
	quantite_feuilles = request.querystring("quantite")
	
		' genere nouvel ordre	
					modifiertable mm_frans_string,"  insert into production_queue (gache) values('oui')"
					ouvrirtable mm_frans_string,rso,"select top 1 id_enr from production_queue where gache='oui' order by id_enr desc"
							nouvel_id_ordre = renvoi(rso,"id_enr")
					fermertable rso
	
	 'on recup les val de l'ordre de base, sans la panche qui sera planche en mode auto et envoye direct
	 ouvrirtable mm_frans_string,rso,"select * from production_queue where id_enr = " & id_ordre
	 	  ordre_ref = renvoi(rso,"ref")
		  ordre_id_fichier = renvoi(rso,"id_fichier")
		  ordre_quantite = renvoi(rso,"quantite")
		  ordre_quantite_feuilles = renvoi(rso,"quantite_feuilles")
		  if ordre_quantite_feuilles = "" then ordre_quantite_feuilles="0"
		  ordre_date_planche =  renvoi(rso,"date_planche")
		  ordre_composant =  renvoi(rso,"composant")
	 fermertable rso
	 
	 
	 imposition = renvoiImpositionFromRef(ordre_ref)
	 if imposition <> "" then 
	    qfeuilleshorspasse = quantite_feuilles - 3
		if qfeuilleshorspasse<1 then qfeuilleshorspasse=1
	 quantite_cartes = 	 round(qfeuilleshorspasse * imposition,0)
	 else
	 quantite_cartes=0
	 end if
	
	' faut annuler le job source ou pas? 
	if cint(quantite_feuilles) < cint(ordre_quantite_feuilles)  then 
			
			' on a un gars qui relance moins de feuilles que l'original, donc en gros
			'il en a pété qu'une partie
			' la quantite pété = quantite_feuilles			 du nouveau job
			'on annule pas le job source, mais on indique qu'il a perdu quantite_feuilles de feuilles
				modifiertable mm_frans_string, "update production_queue  set id_job_gache="&nouvel_id_ordre&" where id_enr = " & id_ordre
			    ajoutejournal "IMPRIMERIE",session("id_user"),id_com,"gache "& quantite_feuilles  &" fls",id_ordre
	else
			'si on refait le mm nombre de feuills ou plus c que le job source doit etre annule
			modifiertable mm_frans_string, "update production_queue  set statut='annule' where id_enr = " & id_ordre
			ajoutejournal "IMPRIMERIE",session("id_user"),id_com,"Job defectueux. nouveau job de "&quantite_feuilles&" fls : "&nouvel_id_ordre,id_ordre
	
	end if
		
		modifiertable mm_frans_string, "update production_queue  set id_fichier="&ordre_id_fichier&",quantite=" & quantite_cartes & ", quantite_feuilles="&quantite_feuilles&",ref='" & ordre_ref & "', statut='relance', date_statut='" & now() & "', imprimeur='Indigo', imprimante='"&imprimante&"', type_ordre='relance', raison_ordre='"&raison_ordre&"' ,statut_plancheur=0, composant='"&ordre_composant&"' where id_enr = " & nouvel_id_ordre
		
		' retour
		response.write(nouvel_id_ordre)
	
	
%>
	    
	
    