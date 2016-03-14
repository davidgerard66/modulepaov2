<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%


			function v(champ)
			
				v = renvoi(rs,champ)
			
			end function
	
	
	
	id_com = request.querystring("id_com")
    nb_job_annules= 0
	ouvrirtable mm_frans_string, rs, "SELECT q.statut as statut, q.id_enr as id_ordre, q.fichier_planche as fichier_planche, q.ref as ref FROM  commandes_lignes_fichiers fic INNER JOIN  Production_queue q ON q.id_fichier = fic.id_enr where  fic.id_com = " & id_com
	
	   while not rs.eof
	   		if v("statut")<>"annule" then 
					
					modifiertable mm_frans_string, "update production_queue set statut='annule' , statut_plancheur=0, date_statut='"&now()&"' where id_enr = " & v("id_ordre")
					fichier_planche = v("fichier_planche")
					supprimefichier replace(fichier_planche,"c:","\\plancheur")
					ajoutejournal "IMPRIMERIE",session("id_user"),id_com,"Annulation job pour "&v("ref"),v("id_ordre")
				  
				nb_job_annules = nb_job_annules + 1
			end if
	   rs.movenext
	   wend
	
    fermertable rs
	 if nb_job_annules > 0 then ajoutejournal "PAO",session("id_user"),id_com,"STOP IMPRESSION","0"		
	
		
		
	

	
%>
	    
	
    