<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%
response.ContentType = "application/json"

			function v(champ)
			
				v = renvoi(rs,champ)
			
			end function
id_com = request.querystring("id_com")

notes = "["

ouvrirtable mm_fpc_string,rs,"select n.id_enr as idenr ,n.note as lanote,n.date_creation as datecrea,u.utilisateur as nom,important from notes as n WITH (NOLOCK) inner join utilisateurs as u on n.id_user = u.id_user where id_com =" & id_com & " order by n.date_creation desc" 
																												
														ctr=0

		while not rs.eof
		
			if ctr>0 then notes = notes & ","
															
																if v("important")="oui" then important="true" else important="false"
																date_creation  = left(v("datecrea"),16)
																nom = v("nom")
																note = replace(v("lanote"),"""","\""")
																
							notes = notes & "{""note_important"": " & important & ", ""note_date"": """&date_creation&""", ""note_nom"": """&nom&""", ""note_note"": """&note&"""}"
																
															rs.movenext
															ctr=ctr+1
															wend
															
                                                fermertable rs 
												notes = notes & "]"
                                               
response.write(notes)

%>