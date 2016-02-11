<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%
assigner_user_id = request.querystring("Id_user")
assigner_user_nom = request.querystring("nom_user")
id_com = request.querystring("Id_com")
id_user = session("id_user")
modifiertable mm_frans_string , "update commandes set assigner_user="&assigner_user_id&", assigner_date='"&now()&"' where id_com = " & id_com
modifiertable mm_frans_string,  "INSERT INTO log_pao(id_com,id_user,activite) values("&id_com&","&id_user&",'Assignée à " & assigner_user_nom  & "') "
' destrcution du cache
application("dernier_id_com") = 0
%>