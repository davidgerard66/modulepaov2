<%@LANGUAGE="VBSCRIPT" codepage="65001" %>
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
    <title>Angular Sort and Filter</title>

    <!-- CSS -->
    <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootswatch/3.2.0/sandstone/bootstrap.min.css">
    <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css">
    <style>
        body { padding-top:50px; }
		h1 { text-transform:uppercase}
    </style>

    <!-- JS -->
    <script src="http://ajax.googleapis.com/ajax/libs/angularjs/1.2.23/angular.min.js"></script>
    <script src="app.js"></script>

</head>
<body>


<div class="container" ng-app="sortApp" ng-controller="mainController">
   <h1>Commandes PART en préparation</h1>
  <div class="alert alert-success">
  
  <select style='color:black' ng-model="champFiltre.label" ng-repeat="champFiltre in champsAfiltrer"  >
    <option value="">- {{ champFiltre.label}} -</option>
    <option ng-repeat="commande in commandes | orderBy:champFiltre.champ | unique : champFiltre.champ" value="{{commande[champFiltre.champ]}}">{{commande[champFiltre.champ]}}</option>
   
    
</select>
  </div>
  <form>
    <div class="form-group">
      <div class="input-group">
        <div class="input-group-addon"><i class="fa fa-search"></i></div>
        <input type="text" class="form-control" placeholder="numéro, nom, email..." ng-model="searchCommande">
      </div>      
    </div>
  </form>
  
  <table class="table table-bordered table-striped">
    
    <thead>
      <tr>
       
        <td ng-repeat="champ in champs">
          <a href="#" ng-click="$parent.sortType = champ; $parent.sortReverse = !($parent.sortReverse)">
           {{ champ }}
          <span ng-show="$parent.sortType == champ && !($parent.sortReverse)" class="fa fa-caret-down"></span>
            <span ng-show="$parent.sortType == champ && $parent.sortReverse" class="fa fa-caret-up"></span>  
          </a>
        </td>
      
       
      </tr>
    </thead>
    
    <tbody>
      <tr ng-repeat="commande in commandes | orderBy:sortType:sortReverse | filter:searchCommande | filter:{'Service': filtresPerso.Service}: true ">
         <td ng-repeat="champ in champs"  ng-click="CliqueCellule(commande,champ)">
         {{ commande[champ]}}
         </td>
       
      </tr>
    </tbody>
    
  </table>
 
  <p class="text-center text-muted">&nbsp;</p>
</div>

</body>
</html>
