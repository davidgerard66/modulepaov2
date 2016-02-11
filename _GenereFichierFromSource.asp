<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%

fichier_source = request.querystring("fichier_source")
destination = request.querystring("destination")




root = "D:\ED-PAO\SOURCES\"
response.write(root & fichier_source&".pdf<br>"&destination)
deplacement_fichier root & fichier_source&".pdf",destination

if fichierexiste(root & fichier_source) then response.write("true")

%>
