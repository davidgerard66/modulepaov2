<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%

		id_com = request.querystring("id_com")
	PAO_visa_expedition = request.querystring("PAO_visa_expedition")
	if PAO_visa_expedition = "TRUE" then PAO_visa_expedition="oui" else PAO_visa_expedition="non"
	modifiertable mm_frans_string, "update commandes set pao_visa_expedition = '"&PAO_visa_expedition&"' where id_com = " & id_com
	
	

	%>
	
    