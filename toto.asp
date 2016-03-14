<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<!--#include virtual="ed/_commonfunction.asp" -->
<%

sql = "SELECT      RTRIM(q.ref) AS Expr1, q.quantite, q.id_enr as id_job,  ROUND(q.quantite / hcp.imposition, 0) + 2 AS feuilles FROM    Production_queue q LEFT OUTER JOIN    hotfolders h ON q.ref = h.ref LEFT OUTER JOIN   hotfolders_codes_plancheur hcp ON hcp.code_planche = h.hotfolder WHERE  (q.id_enr < 8014) AND (q.statut = 'rippé')"

ouvrirtable mm_frans_string,rs,sql

while not rs.eof

id_job = renvoi(rs,"id_job")
feuilles = renvoi(rs,"feuilles")
if feuilles<>"" then
 modifiertable mm_frans_string,"update production_queue set quantite_feuilles="&feuilles&" where quantite_feuilles is null and id_enr=" & id_job
 end if


rs.movenext
wend
fermertable rs
%>