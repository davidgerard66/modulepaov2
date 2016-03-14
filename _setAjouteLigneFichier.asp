<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%


			function v(champ)
			
				v = renvoi(rs,champ)
			
			end function
id_com = request.querystring("id_com")
id_ligne = request.querystring("id_ligne")
ref = request.querystring("ref")
indice = request.querystring("indice")
imprime = request.querystring("imprime")
quantite = request.querystring("quantite")
fichier_path = request.querystring("fichier_path")





ajoutelignefichier id_com,id_ligne,ref,indice,imprime,quantite,fichier_path

response.write("Ajout ok")
													
%>
