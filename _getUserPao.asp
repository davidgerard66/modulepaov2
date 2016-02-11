<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<%

response.write("{""Nom"":""" & session("nom_user")&""",""Id"":"&session("id_user")&"}")

%>