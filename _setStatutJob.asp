<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%
response.ContentType = "application/json"

			function v(champ)
			
				v = renvoi(rs,champ)
			
			end function
	
	id_job = request.querystring("id_job")
	statut_job = request.querystring("statut_job")
	id_com = request.querystring("id_com")
	
	
	
	modifiertable mm_frans_string, "update production_queue set statut='"&statut_job&"', statut_plancheur=0, date_statut='"&now()&"' where id_enr = " & id_job
	
	
	
	if statut_job = "annule" then
	
	ouvrirtable mm_frans_string,rs,"select * from production_queue where id_enr = " & id_job
		 fichier_planche = v("fichier_planche")
			 supprimefichier replace(fichier_planche,"c:","\\plancheur")
			 ajoutejournal "IMPRIMERIE",session("id_user"),id_com,"Annulation job pour "&v("ref"),id_job
	fermertable rs
	
	else
	ajoutejournal "IMPRIMERIE",session("id_user"),id_com,"job statut" & statut_job,id_job
	end if
	
		
	%>
	
    