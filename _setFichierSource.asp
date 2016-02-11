<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%

id_ligne = request.querystring("id_ligne")
fichier_source_type = request.querystring("fichier_source_type")
fichier_source = request.querystring("fichier_source")


modifiertable mm_frans_string, "update commandes_lignes_fichiers set fichier_source = '"&fichier_source&"',fichier_source_type='"&fichier_source_type&"'  where id_ligne = " & id_ligne


%>
