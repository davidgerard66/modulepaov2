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
epreuve = request.querystring("epreuve")
imprimante = request.querystring("imprimante")
id_com = request.querystring("id_com")


	ouvrirtable mm_frans_string,rs,"select fichier_planche,h.indigonew as indigonew, fic.fichier_nom as fichier_nom, fic.id_com as id_com  from production_queue p inner join hotfolders h on p.ref=h.ref  inner join commandes_lignes_fichiers fic on fic.id_enr = p.id_fichier where p.statut in('new','relance') and p.id_enr = " & id_ordre
	
	if rs.eof then 
	ajoutejournal "IMPRIMERIE",session("id_user"),id_com,"Erreur envoi DFE job "&id_ordre&" existe pas ou statut nest pas new ",id_ordre
	response.end
	end if
		fichier_planche = replace(v("fichier_planche"),"c:","\\plancheur")
		fichier_epreuve = replace(fichier_planche,".",".epreuve.")
	    hotfolder = ucase(v("indigonew"))
		'fichier_nom = v("fichier_nom")
		id_com = v("id_com")
	fermertable rs

'response.write(hotfolder & "-" &fichier_planche )
'response.end()

Set NetworkObject = CreateObject("WScript.Network")  ' objet reseau pour acces aux diques reseaux NetworkObject.MapNetworkDrive "", ServerShare, False, UserName, Password

select case imprimante
case "HP2"
dossierpresse = "\\192.168.1.24\jobs"
case else
dossierpresse = "\\192.168.1.22\jobs"
end select

UserName2 = "unicorn"
Password2 = "HPdfeHPdfe#1"
NetworkObject.MapNetworkDrive "", dossierpresse, False, UserName2, Password2

   
temp_fichier_nom = split(fichier_planche,"\")
for each r in temp_fichier_nom
if instr(r,".pdf")>0 then fichier_nom=r
next
fichier_nom = replace(fichier_nom,"_feuilles_unifie","_feuilles")
fichier_nom = replace(fichier_nom,"\","")
fichier_nom = replace(fichier_nom,"/","")


destination =  dossierpresse&"\"&hotfolder&"\@testV2@" & fichier_nom

select case epreuve
case "oui"
			
			Set Pdf = Server.CreateObject("Persits.Pdf")
			Set Doc = Pdf.OpenDocument(fichier_planche)
					
					if instr(hotfolder,"RV")>0 then  ' planche est recto ou recto-verso; opn, extrait la 1er page ou les 2 premieres
					Set NewDoc = Doc.ExtractPages("Page1=1; Page2=2")
					else 
					Set NewDoc = Doc.ExtractPages("Page1=1")
					end if
			
			NewDoc.Save  fichier_epreuve
			doc.close
			set doc = nothing
			set pdf = nothing
			
			
			deplacement_fichier fichier_epreuve, destination
			ajoutejournal "IMPRIMERIE",session("id_user"),id_com,"Epreuve pour job "&id_ordre&" sur "&imprimante,id_ordre
			
case else

			deplacement_fichier fichier_planche, destination
			
			'ajoutejournal "IMPRIMERIE",session("id_user"),id_com, left( replace(fichier_planche & " vers " & destination,"\","\\"),240)  ,id_ordre
			
			modifiertable mm_frans_string,"update production_queue  set statut='rippé', imprimante='"&imprimante&"', date_statut='"&now()&"' where id_enr = " & id_ordre
			ajoutejournal "IMPRIMERIE",session("id_user"),id_com,"Envoi DFE job "&id_ordre&" sur "&imprimante,id_ordre
end select
%>