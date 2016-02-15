<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%
response.ContentType = "application/json"

			function v(champ)
			
				v = renvoi(rs,champ)
			
			end function
	
	id_com = request.querystring("id_com")
	pao_needed = request.querystring("pao_needed")
	pao_needed_raison = replace(request.querystring("pao_needed_raison"),"'","''")
	production_autorise = request.querystring("production_autorise")
	prepress_needed = request.querystring("prepress_needed")
	
	
	
	
	modifiertable mm_frans_string, "update commandes set pao_needed='"&pao_needed&"', prepress_needed='"&prepress_needed&"', pao_needed_raison='"&pao_needed_raison&"', production_autorise='"&production_autorise&"' where id_com = " & id_com
	
	
	
	'ajoutejournal "IMPRIMERIE",session("id_user"),id_com,"Annulation job pour "&v("ref"),"0"
	
	
		
	%>
	
    