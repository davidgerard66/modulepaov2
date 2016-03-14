<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%
'response.ContentType = "application/json"
 if request.querystring("id_user")="1" then session("id_user")="1"
 
if session("id_user")="" then 
response.write("vous devez etre connecte")
response.End()
end if

			function v(champ)
			
				v = renvoi(rs,champ)
			
			end function


id_ordre = request.querystring("id_ordre")


	ouvrirtable mm_frans_string,rs,"select  fic.id_com as id_com, p.ref as ref, p.quantite as quantite  from production_queue p inner join commandes_lignes_fichiers fic on fic.id_enr = p.id_fichier where p.statut in('new','relance') and p.id_enr = " & id_ordre
	
			if rs.eof then 
			ajoutejournal "IMPRIMERIE",session("id_user"),id_com,"Erreur envoi repiquage job "&id_ordre&" existe pas ou statut nest pas new ",id_ordre
			response.end
			end if
			id_com = v("id_com")
			qte = v("quantite")
			ref= v("ref")
			
	fermertable rs

			
			modifiertable mm_frans_string,"update production_queue  set statut='rippé',  date_statut='"&now()&"' where id_enr = " & id_ordre
			 modifiertable mm_fpc_string   ,"insert into rip_historique(id_com,ref,date_envoi,url_fichier,qte_ref,uniqueid,imprimante) values("&id_com&",'"&ref&"','"&angnow(now())&"','',"&qte&",'"&id_ordre&"','phaser')"
			ajoutejournal "IMPRIMERIE",session("id_user"),id_com,"Repiquage ok job "&id_ordre,id_ordre

%>