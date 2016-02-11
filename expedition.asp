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
    <title>Expéditions</title>

    <!-- CSS -->
    <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootswatch/3.2.0/sandstone/bootstrap.min.css">
    <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css">

    <!-- JS -->
    <script src="http://ajax.googleapis.com/ajax/libs/angularjs/1.4.0/angular.min.js"></script>
  
    <script src="app.js"></script>
<script src="//code.jquery.com/jquery-1.11.3.min.js"></script>
<style>
.zones td { height:110px;width:80px;}
.boite {
background-color:#F9F9F9;
background-image:url(texture_carton.png);
border:1px #e2e2e2 solid; 
padding:4px; 
text-align:center;
margin:4px;
}
.boitetrouve {
border:2px red solid;
}
.conteneur {	

border-radius:8px;
border:0px #e2e2e2 solid;
padding:8px;
background-color:#ecf0f1;
margin-bottom:20px;
font-size:36px;
font-family:Verdana, Geneva, sans-serif;
}
.conteneur table {
	font-size:18px;
}

.cartes {
	
	min-height:600px;
	}
.enveloppes {	

	min-height:145px;
}
.accessoires {	
	
	min-height:140px;
}
.divers {	
	
	min-height:100px;
}
.expedier {	
	background-color:#f4f4f4;
	min-height:150px;
	color:white;
}
.expediable {background-color:#2ecc71;}
.alertes {font-size:24px;}
.livraison pre{
	font-size:15px;
	}
.recu {
	background-color:green !important;
	color:white !important;
	}
.bouton_picking_ok {background-color:#f4f4f4;}

#transporteur {
	font-size:24px;
	line-height:24px;
	 height:40px; 
	 color:orange;
	 padding:4px;
	}
</style>
</head>
<body>


<div class="container-fluid" id="AppliExpeditions" ng-app="AppliPao" ng-controller="mainController" ng-init="LoadGrille('new')" >
  
   <div class="row">
          <div class="col-lg-1">
          
          </div>
       
       <div class="col-lg-10" id="conteneur">
                   
               <h2>Expédition,  vous êtes connecté en tant que <span style='color:green'><%=session("nom_user")%></span> </h2>
             
              
              <form>
                <div class="form-group">
                  <div class="input-group">
                    <div class="input-group-addon"><i class="fa fa-search"></i></div>
                    <input type="text" class="form-control" placeholder="numéro de commande ED" ng-model="searchBoite">
                  </div>      
                </div>
              </form>
            
            
            <ul id="menuTabs" class="nav nav-tabs">
            
  <li  ng-class="{'active': showZA==true}" >
  <a ng-click="LoadZA()" style='float:left'>Zones d'attente <span></span><i style='margin-left:10px;' class='glyphicon glyphicon-refresh'></i></a> 
  </li>
  
  <li  ng-class="{'active': showExpedition==true}" >
  <a ng-click="LoadExpedition(searchBoite)" style='float:left'>Réception \ expédition <span><i style='margin-left:10px;' class='glyphicon glyphicon-refresh'></i></a>
  </li>
        
  
			</ul>
   
   
  
  
  
  
                <div id='loaderZA' ng-show="isLoading"></div>
              <!-- divgrille liste des commandes en cours -->
              <div id='divZA' ng-show="showZA">
                  
                  
                  <div ng-repeat="zone in zoneAttentes" class="zones">
                  
                  <h2>{{ zone.nom}}</h2>
                  <table class="table table-bordered table-striped">
                                      
                    <tbody>
                      <tr  ng-repeat="rang in range(zone.data.rangs) track by $index" >
                        <td  ng-repeat="colonne in range(zone.data.colonnes) track by $index" >{{$parent.$index+1}}{{$index+1}}
                        		
                                <p class="boite" ng-class="{'boitetrouve' : boite.id_com ==searchBoite}" ng-repeat="boite in boitesEnZa |  filter:{zone: zone.nom, casier: ($parent.$index+1).toString() + ($index+1).toString()}">{{boite.id_com}} : {{boite.label}}</p>
                                
                        
                         </td>
                        
                       
                      </tr>
                    </tbody>
                    
                  </table>
                  </div>
                  
              </div>
              <!-- fin div grille liste des commandes en cours -->
              
              
              
              
              <!-- divgrillecommandes en cours -->
              <div id='divExpedition' ng-show="showExpedition" style='padding-top:4px;'>
                  
                  <div class="row">
	                   
                       <div class="col-lg-12">
                        
                                <div class="row">
                                 <div class="col-lg-9">
                               
    							<h2 class='alert alert-info'>{{commande.id_com}} - {{commande.id_com_web}} {{commande.groupe_canal}} {{commande.groupe_activite}} -  {{commande.pays_livraison | uppercase}} - {{commande.nom |uppercase}} <span ng-if="commande.societe">- {{commande.societe |uppercase}}</h2>
                               
                                </div>
                                 <div class="col-lg-3 livraison">
                                  
                                 <select id="transporteur" class="form-control"  ng-model="commande.Transporteur" ng-options="t.nom as t.nom for t in transporteurs">
                                 
                                 </select>
							   <pre>{{commande.adr_livraison}}</pre>
						
                                 </div>
                                </div>
                       
                       </div>
				</div>
                
                  <div class="row">
	                   
                       <div class="col-lg-12">
                      
                        <div class="alert alert-warning">
    							<span class='alertes'>LOGO VERNIS XMAS </span>  <button class="btn-lg btn-danger">CONFIRMER OK</button>   ------
                                <span class='alertes'>PERFORATION SUR M22-004-G  </span>  <button class="btn-lg btn-danger">CONFIRMER OK</button>                		
                        </div>
                       </div>
				</div>

                  <div class="row">
                    <div class="col-lg-8">

                    <div class="conteneur cartes ">
						<h3>CARTES</h3>
                        <ul>
                        <li ng-repeat="article in commande.contenu | filter:{Groupe:'CARTES'}" >
                        {{article.Article}} X {{article.Quantite}}
                        		
                                
                                     <table class="table table-bordered table-striped" style='margin-left:25px; width:890px;'>
                                    
                                    <thead>
                                      <tr>
                                       <td>Aperçu</td><td>Prod Id</td><td>Contenu</td><td>Statut</td><td>Actions</td>
                                      </tr>
                                    </thead>
                                    
                                    <tbody>
                                      <tr  ng-repeat="ordre in productions | filter:{id_ligne:article.id_ligne}">
                                            
                                              <td> <a target="_blank" href='http://plancheur/?abn121638'><img src="http://plancheur/podpdf/preview/abn121638/15071333-218369-1-(MV06-107-G%20x%2030)-recto.jpg" width=180></a>  </td>
                                              <td> #{{ordre.id_ordre}}<br> {{ordre.imprimeur}} </td>
                                             
                                              <td>{{ordre.ref}} x {{ordre.quantite}}</td>
                                              <td><p ng-class="{'recu':ordre.statut=='receptionne'}">{{ordre.statut}}</p></td>
                                              <td>
                                              <ul class="list-unstyled"><li>
                                              <a ng-click="Expedition_receptionne_ordre(ordre)" class='btn btn-success'>Réceptionner</a>
                                              <a class='btn btn-success'>Réceptionner et ranger</a>
                                             
                                              </li></ul>
                                              </td>
                                              
                                      </tr>
                                    </tbody>
                                    
                                  </table>
                                  
                                
                                    
                                
                        </li>
                        </ul>
                        
                        
                        
                    </div>



                    </div>
                    <div class="col-lg-4">

                    <div class="conteneur enveloppes">
<h3>ENVELOPPES</h3>
<ul>
                        <li ng-repeat="article in commande.contenu | filter:{Groupe:'ENVELOPPES'}" >
                        {{article.Article}} X {{article.Quantite}}
                       <button ng-click="article.pret=!(article.pret)" class='bouton_picking_ok' ng-class="{'recu':article.pret}" ng-show="expediable">OK</button>
                        </li>
                        </ul>
                        
                    </div>
                    <div class="conteneur accessoires">
<h3>ACCESSOIRES</h3>
<ul>
                        <li ng-repeat="article in commande.contenu | filter:{Groupe:'ACCESSOIRES'}" >
                       {{article.Article}} X {{article.Quantite}} 
                       <a href='http://www.faire-part-creatif.com/faire-part-mariage/faire-part-mariage-photos/rubans/1000/{{article.Article}}.jpg' target='_blank'>
                       <img src="http://www.faire-part-creatif.com/faire-part-mariage/faire-part-mariage-photos/rubans/200/{{article.Article}}.jpg" width="40" style="float:right">
                       </a>
                      <button ng-click="article.pret=!(article.pret)" class='bouton_picking_ok' ng-class="{'recu':article.pret}" ng-show="expediable">OK</button>
                        </li>
                        </ul>
                        
                    </div>
                    <div class="conteneur divers">
<h3>DIVERS</h3>
<ul>
                        <li ng-repeat="article in commande.contenu | filter:{Groupe:'DIVERS'}" >
                        {{article.Article}} X {{article.Quantite}}
                        <button ng-click="article.pret=!(article.pret)" class='bouton_picking_ok' ng-class="{'recu':article.pret}" ng-show="expediable">OK</button>
                        </li>
                        </ul>
                        
                    </div>
                     <div class="conteneur expedier" ng-class="{'expediable': expediable}" style="text-align:center;line-height:150px;font-size:70px;">

                          EXPEDIER

                    </div>


</div>

</div>

                  <div class="row">

                  bas de page avec boutons


                  </div>
                
                  
              </div>
              <!-- fin div grille liste des commandes en cours -->
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
        
     </div>   
       <div class="col-lg-1"></div>

</div>



</div>
</body>
</html>
