<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<%
Call Response.AddHeader("Access-Control-Allow-Origin", "http://Brian")
%>

<!--#include virtual="ed/_commonfunction.asp" -->
<%
	server.scripttimeout = 1000
			function v(champ)			
				v = renvoi(rs,champ)
			end function
	
	id_com = request.querystring("id_com")
	Set Pdf = Server.CreateObject("Persits.Pdf")
	
	ServerShare = "\\PLANCHEUR\FICHIERSPOD"
	UserName = "plancheur\creative"
	Password = "Txds4946aaa"
	Set NetworkObject = CreateObject("WScript.Network")
	NetworkObject.MapNetworkDrive "", ServerShare, False, UserName, Password	



	' creation des thumbsnails jpg des bat pdf
	ouvrirtable mm_frans_string,rs, "select * from commandes_lignes_fichiers where id_com = " & id_com
	
	if not rs.eof then 
	
				while not rs.eof 
				
						f = v("fichier_path")&v("fichier_nom")
						response.write(f&"<br>")
						if fichierexiste(f) then
						    response.write("oui")
							Set DocPreview = Pdf.OpenDocument( f )
							ctr=1
								for each page in DocPreview.pages
										Set Preview = page.ToImage("ResolutionX=200; ResolutionY=200")
										response.write(replace(f,".pdf","-"&ctr&".jpg"))
										Preview.Save( replace(f,".pdf","-"&ctr&".jpg") ) 
										ctr=ctr+1
								next
						end if
				rs.movenext
				wend
	
	
	end if
	
	fermertable rs
	 	set preview=nothing
	   
	   set DocPreview = nothing
	   set pdf = nothing


%>