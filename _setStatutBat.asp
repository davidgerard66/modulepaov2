<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%
response.ContentType = "application/json"

			function v(champ)
			
				v = renvoi(rs,champ)
			
			end function
	
	id_com = request.querystring("id_com")
	statut_bat = request.querystring("statut_bat")
	is_bat_web = request.querystring("is_bat_web")
	
	modifiertable mm_frans_string, "insert into impression_statut(id_com,statut) values("&id_com&",'"&statut_bat&"')"
	modifiertable mm_fpc_string, "insert into impression_statut(id_com,statut) values("&id_com&",'"&statut_bat&"')"
	
	
	if Ucase(is_bat_web) = "TRUE" then libelle = statut_bat & " web" else libelle = statut_bat & " email"
		ajoutejournal "PAO",session("id_user"),id_com,libelle,"0"
		
	%>
	
    