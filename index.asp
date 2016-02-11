<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
<%
if session("id_user")="" then 
session("redir")=request.ServerVariables("SCRIPT_NAME")
response.redirect("http://brian/ed/identification.asp")
end if
%>

<!--#include virtual="ed/_commonfunction.asp" -->
<%
Response.ContentType = "text/html"
Response.AddHeader "Content-Type", "text/html;charset=UTF-8"
Response.CodePage = 65001
Response.CharSet = "UTF-8"
%>
<!-- index.html -->

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>PAO EN COURS</title>

    <!-- CSS -->
    <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootswatch/3.2.0/sandstone/bootstrap.min.css">
    <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css">
	<link rel="stylesheet" href="pao.css">
<link rel="stylesheet" href="css/jquery-ui.min.css">

<script src="//code.jquery.com/jquery-1.11.3.min.js"></script>
<script src="//code.jquery.com/ui/1.11.4/jquery-ui.js"></script>

    <!-- JS -->
    <script src="http://ajax.googleapis.com/ajax/libs/angularjs/1.4.0/angular.min.js"></script>
    <script src="https://code.angularjs.org/1.2.28/angular-route.min.js"></script>
    
    <script src="app.js"></script>
  
</head>
<body>


<div class="container-fluid" id="AppliPao" ng-app="AppliPao" ng-controller="mainController" style='margin-top:-50px !important'>
  
   <div class="row">
       
       <div class="col-lg-1"></div>
       
       <div class="col-lg-10" id="conteneur">
                   

              <div ng-view id="ngview"></div>
              

              <!-- divgrille liste des commandes en cours -->

              
    
              <!-- fin div grille liste des commandes en cours -->
              
              
                

              <!-- fin div grille liste des commandes en cours -->
		</div>
 <div class="col-lg-1"></div>
 </div></div>
<script>
    function dragStart(event) {
        event.dataTransfer.setData("Text", event.target.id);
        // document.getElementById("demo").innerHTML = "Started to drag the p element";
    }

    function allowDrop(event,elt) {
        event.preventDefault();
        elt.addClass('droptarget_actif');

    }
    function leaveDrop(elt) {

        elt.removeClass('droptarget_actif');

    }
    function drop(event,elt) {
        var fichierbin;
        event.preventDefault();
        var url = event.dataTransfer.getData("Text");

        var destination = (elt.find('#fichier').val());
        var nomfichier_destination = (elt.find('#nomfichier').val());
        var cheminfichier_destination = (elt.find('#cheminfichier').val());

        var id_com = (elt.find('#id_com').val());
        var id_ligne = (elt.find('#id_ligne').val());
        elt.html('Opération en cours...');
        if (event.dataTransfer.files.length>0) // on a droppe unfjchier
        {
            nom_fichier = event.dataTransfer.files[0].name;
            nom_fichier=nom_fichier.toUpperCase();
            if (nom_fichier.indexOf(".PDF")<1 && nom_fichier.indexOf(".INDT")<1 && nom_fichier.indexOf(".JPG")<1) { alert('Seul les fichiers INDT et PDF sont autorisés');return false}
            var reader = new FileReader();
            reader.onload = function (event) {
                fichierbin =  event.target.result;


                angular.element(document.getElementById('scope')).scope().Telecharge(nom_fichier,destination,fichierbin,id_ligne,id_com);
            };
            reader.readAsDataURL(event.dataTransfer.files[0]);
        } else {
            // on a dropppe une url

            console.log('id_com'+id_com);
            angular.element(document.getElementById('ngview')).scope().Telecharge(encodeURIComponent(url),encodeURIComponent(destination),fichierbin,id_ligne,id_com);
        }
    }
</script>
<iframe id='template2pdfFrame' width=0 height=0></iframe>

</body>
</html>
