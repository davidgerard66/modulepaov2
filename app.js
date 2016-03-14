// app.js
angular.module('AppliPao', ['ngRoute'])

.config(function($routeProvider) {  // ROUTEUR MAISON
		  $routeProvider
		   .when('/Journal', {
			templateUrl: 'rubriques/journal.html',
			controller: 'mainController'
		  })
		  .when('/JournalIndigo', {
			templateUrl: 'rubriques/journalimprimerie.html',
			controller: 'mainController'
		  })
		  .when('/Commandes/:statut_bat/:groupe_canal', {
			templateUrl: 'rubriques/Commandes.html',
			controller: 'mainController'
		  })
		  .when('/Imprimerie/:imprimeur', {
			  templateUrl: 'rubriques/imprimerie.html',
			  controller: 'mainController'
		  })
		  .when('/Commande/:idcommande', {
			  templateUrl: 'rubriques/commande.html',
			  controller: 'mainController'
		  })
		  .when('/Plancheur/:statut_planche', {
			  templateUrl: 'rubriques/plancheur.html',
			  controller: 'mainController'
		  })
  })

.factory('Onglets', function() {
	return {
		onglets : [
		{	Label:'France > A TRAITER',	Title:'Commandes en attente de PAO',
			Route:'/Commandes/New/Part' },

		{	Label:'Allemagne > A TRAITER',Title:'Commandes Allemande en attente de PAO',
			Route:'/Commandes/STAN/STAN' },

		{	Label:'Autres > A TRAITER',	Title:'Commandes export,revendeurs etc, en attente de PAO',
			Route:'/Commandes/new/AUTRES' },

		{	Label:'BAT en cours', Title:'Commandes avec BAT non validé',
			Route:'/Commandes/bat/tout' },

		{	Label:'A préparer presse', Title:'Commandes fichiers manquants ou a préparer pour impression',
			Route:'/Commandes/prepress/tout' },

	//	{	Label:'Journal', Title:'Log de tous les évènements à l\'horizon, aucun rapport avec les trous noirs',
	//		Route:'/Journal' },

		{	Label:'Imprimerie',	Title:'Imprimerie c l\'imprimerie... ',
			Route:'/Imprimerie/Indigo' 
		},
		{	Label:'Imprimerie Naiss + exp',	Title:'Imprimerie c l\'imprimerie... ',
			Route:'/Imprimerie/IndigoN' 
		},

		{	Label:'Histo Indigo', Title:'Historique rip',
			Route:'/JournalIndigo'
		},

		{	Label:'Repiquage', Title:'Impressions Phaser en attente',
			Route:'/Imprimerie/Phaser'
		},
		{	Label:'Plancheur', Title:'Attente plancheur',
			Route:'/Plancheur/0'
		},
		{	Label:'Bloqués', Title:'Bloqué plancheur',
			Route:'/Plancheur/1'
		}
		
		]};
})

.controller('mainController', function($scope,Onglets, $http, $compile, $httpParamSerializer,$timeout, $route, $routeParams, $location, $rootScope) {

   $scope.UserData =[]
   $scope.commandes = [];
   $scope.expediable = false;
   $scope.encours = "";
   $scope.isLoading=true;
   $scope.Imprimante='';
   $scope.showJobSendingLog=false;
   $scope.readyToSend = false;
   $scope.maxSendingJobs = 70;
   $scope.casejob=[];
   $scope.isSendingJobs = false;
   $scope.pendingJobs =0;
   $scope.Onglets = Onglets.onglets; // LISTE ONGLET EN FACTORY = une sorte de variable globale..
	$scope.rafraichissement = 60;
	$scope.transporteurs = [{nom:'GLS'},{nom:'COLISSIMO'},{nom:'TNT'},{nom:'CLIENT'}];
	$scope.showZA = false;
	$scope.showExpedition = false;
	$scope.zoneAttentes=[{"nom":"Z1","data":{"rangs":4,"colonnes":6,"byColonne":2}},
		{"nom":"Z2","data" :{"rangs":4,"colonnes":6,"byColonne":2}},
		{"nom":"Z3","data" :{"rangs":4,"colonnes":6,"byColonne":2}}];


		$scope.boitesEnZa = [{"id_com":16002551,"label":"M22-004 x 50","zone":"Z1","casier":12},
			{"id_com":16002489,"label":"M22-005 x 50","zone":"Z1","casier":12},
			{"id_com":16002311,"label":"M052 x 150","zone":"Z1","casier":14},
			{"id_com":16002489,"label":"MC22-005 x 150","zone":"Z1","casier":23},
			{"id_com":16002311,"label":"M052 x 150","zone":"Z1","casier":12},
			{"id_com":15091818,"label":"M06-117-g x 120","zone":"Z1","casier":33}
		];

		$scope.contient = function(boite,str2) {
			 (boite.id_com).indexOf(str2) ;
			 };
		$scope.LoadZA = function() {
			$scope.showZA = true;
			$scope.showExpedition = false;
		};

		$scope.LoadExpedition = function(idcom) {
			console.log("ok");
			$scope.showZA = false;
			$scope.showExpedition = true;
			

			// chargement picking list
			$http.get('_getCommandeExpedition.asp',{params : {id_com : idcom}}).
				success(function(data, status, headers, config) {
					$scope.commande = data;
					$scope.isLoading=false;

				}).
				error(function(data, status, headers, config) {
					// log error
					$scope.isLoading=false;
					console.log("erreur de l'application");
				});

			// chargement production list
			$http.get('_getProductionOrders.asp',{params : {id_com : idcom}}).
				success(function(data, status, headers, config) {
					$scope.productions = data;
					$scope.isLoading=false;
					$scope.ActualiseExpediable();
				}).
				error(function(data, status, headers, config) {
					// log error
					$scope.isLoading=false;
					console.log("erreur de l'application");
				});
		};

		$scope.Expedition_receptionne_ordre = function(ordre) {


			ordre.statut = 'Receptionné';
			$scope.ActualiseExpediable();


		};
       	$scope.ActualiseExpediable = function(){
			$scope.expediable =true;
			for (var ordre in $scope.productions) {
				var statut = $scope.productions[ordre].statut;
				if (statut!='Receptionné') {$scope.expediable =false;}
			}

		};



   $http.get('_getUserPao.asp').
    success(function(data, status, headers, config) {
      $scope.User = data;
    }).
    error(function(data, status, headers, config) {
      // log error
	  alert("erreur de l'application reucperaion de user impossible");
	});

  
  $scope.sortType     = 'Id_com'; // set the default sort type
  $scope.sortReverse  = false;  // set the default sort order
  $scope.searchCommande   = '';     // set the default search/filter term
  
  $scope.toto=function(v){
	//if (typeof filtre == 'undefined'){return;} 
	 alert($scope.filtre[v]) 
  };
  // champs afficher dans la grille
  $scope.filtreperso = {};
  
  $scope.champsCommandes = [
   				   'Id_com',
                   'Id_web',
				   'Canal',
				   'Activite',
				   'Confirmation',
				   'Option',
				   'Priorite',
				   'Nom',
				   'BAT',
	  'jobs_indigo',
	  'jobs_phaser',
				   'Assignation'
				   ];

    $scope.champsJournal = [
   				   {'champ':'user.nom','label':'Utilisateur'},
                   {'champ':'date_creation','label':'effectué le'},
				   {'champ':'id_com','label':'Commande'},
					{'champ':'id_ordre','label':'JOB'},
					{'champ':'ref','label':'Réf'},
					{'champ':'quantite','label':'Qte cartes'},
				{'champ':'qfeuilles','label':'Qte feuilles'},
				{'champ':'imprimante','label':'Imprimante'},
				   {'champ':'Action','label':'Action'},
				   ];

$scope.champsJournalImprimerie = [
   				  
                   {'champ':'date_creation','label':'effectué le'},
				   {'champ':'id_com','label':'Commande'},
					{'champ':'id_ordre','label':'JOB'},
					{'champ':'ref','label':'Réf'},
					{'champ':'quantite','label':'Qte cartes'},
				{'champ':'qfeuilles','label':'Qte feuilles'},
				{'champ':'imprimante','label':'Imprimante'},
				   {'champ':'Action','label':'Action'},
				   ];


	$scope.champsProductionOrders = [
		{'champ':'Id_com','label':'Commande'},
		{'champ':'priorite','label':'Priorité'},
		//{'champ':'id_ordre','label':'Job'},
		//{'champ':'imprimeur','label':'Imprimeur'},
		{'champ':'date_creation','label':'Date ordre'},
		{'champ':'code_planche','label':'Format'},
		{'champ':'papier','label':'Papier'},
		//{'champ':'scodix','label':'SX'},
		//{'champ':'vernistotal','label':'UV'},
		{'champ':'finition','label':'Finition'},
		//{'champ':'decoupe','label':'Découpe'},
		{'champ':'ref','label':'Référence'},
		{'champ':'feuilles','label':'Nb feuilles'}
		//{'champ':'quantite','label':'Qté'},
		//{'champ':'fichier_planche','label':'Fichier planche'},
		//{'champ':'type_ordre','label':'type d\'ordre'}
		//{'champ':'raison_ordre','label':'motif'}
	];
	
	 $scope.champsCommandelignes = [
   				   {'champ':'index','label':'Idx'},
				   {'champ':'typearticle','label':'Type'},
				   {'champ':'ref','label':'Article'},
                   {'champ':'quantite','label':'Qté'},
				   {'champ':'imprime','label':'Imp'},
				   {'champ':'fichier','label':'fichier'},
				    {'champ':'fichier_source','label':'source'},
				   {'champ':'chemin','label':'dossier'},
				   //{'champ':'id_ordre','label':'Id job'},
				   {'champ':'imprimeur','label':'Imprimeur'},
				   {'champ':'statut_ordre','label':'Etat du job'},				
				   {'champ':'statut_expedition','label':'Statut Expedition'},
				   {'champ':'actions','label':'Epreuves'}
				   ];
  
  // champs filtrable 
  $scope.champsAfiltrer = [ 
                            {'champ':'Option', 'label':'Option'},
							{'champ':'Confirmation','label':'Date confirmation'},
							{'champ':'BAT','label':'Statut du BAT'},
							{'champ':'Priorite','label':'recla ,express..'},							
							{'champ':'Assignation','label':'Assigné à'}
							
						  ];


		$scope.champsAfiltrerImprimerie = [
			{'champ':'g', 'label':'Genre'},
			{'champ':'papier', 'label':'Papier'},
			//{'champ':'scodix','label':'Scodix'},
			//{'champ':'vernistotal','label':'Vernis'},
			{'champ':'finition','label':'Finition'},
			//{'champ':'decoupe','label':'Découpe'},
			{'champ':'priorite','label':'Priorité'},
			{'champ':'code_planche','label':'Format'}
		];

  $scope.CliqueCellule = function(commande,champ) {

	  var urlCommande = '/Commande/' + commande.Id_com;



	  $location.path( urlCommande );
	  /*
			 $scope.isLoading=true;
			  var idcom = commande.Id_com;



			if (!$scope.showCommande.hasOwnProperty(idcom)) {

					 var menutabs = angular.element(document.getElementById('menuTabs'));

					 menutabs.append("<li id='tab"+idcom+"'
					  ng-class=\"{'active': showCommande["+idcom+"]==true}\">
					  <a ng-click='LoadCommande("+idcom+")'
					   style='float:left;width:100%;padding-left:20px;padding-right:20px;'>"+idcom+"</a>
					   <i ng-click='RemoveTab("+idcom+")' style='margin-left:-15px;color:#FB606B'
					    class='glyphicon glyphicon-remove-sign'></i></li>");
					 var tab = angular.element(document.getElementById('tab'+idcom));
					 $compile(tab)($scope);

							}

					 $scope.FermeCommandesTabs();
					 $scope.showCommande[idcom]=true;
					 $scope.LoadCommande(idcom);
 */
			  };
 
 
  $scope.fermeOnglet = function(onglet_id){

  console.log('fermeture onglet' + Onglets.onglets[onglet_id].Title);
  	Onglets.onglets.splice(onglet_id,1);
    //var nouvel_onglet_actif = onglet_id
    var notredirected=true;
    while (notredirected) {
    
    	if (typeof Onglets.onglets[onglet_id] != 'undefined') {

    		notredirected = false;
    		console.log("redirection vers onglet" + Onglets.onglets[onglet_id].Route)
    		$location.path(Onglets.onglets[onglet_id].Route);
    }
    onglet_id--;
}
    



  };

  $scope.isReadyToProduce = function(commande) {

        var isready = true; // tous les fichiers existent
  		angular.forEach(commande.contenu, function (ligne, key) {
					  
					if( ligne.chemin!='' && ligne.typearticle!='SERVICE') { 
					    if (!ligne.existe ) {isready=false}
					} 
																});

  		if (!isready) {
  			alert("il manque des fichiers pour finaliser l'opération");
  			return false;
  		} else {return true}

  }

  $scope.commandeHasJobs = function(lacommande) {

        var hasjob = false; 

        if (lacommande != undefined) {

       
  		angular.forEach(lacommande.contenu, function (ligne, key) {
					  
					if( ligne.id_ordre!="" && ligne.statut_ordre!='annule') { 
						console.log(ligne.ref)
					   hasjob =  true
					}
					
																});

  		if (hasjob) {
  			return true
  		}

  	}

  }



  $scope.miseEnProduction = function(commande) {
var confirmation_user = confirm('etes vous sur de passer cette commande en production : ' + commande.Id_com + '?');
if (!confirmation_user) {return false}
 $scope.isLoading=true;
     if (!($scope.isReadyToProduce(commande))) {return false}

     	$http.get('_setMiseEnProduction.asp',{params : {id_com : commande.Id_com}}).
					success(function(data, status, headers, config) {
				 
					   $scope.isLoading=false;
					   alert(data)

					  }).
					error(function(data, status, headers, config) {
					  // log error
						$scope.isLoading=false;
						alert(data)
					  console.log("erreur de la mise en production");
					});


  }

  $scope.LoadCommande = function(idcom) {
	  if (idcom==undefined) { idcom = $scope.commande.Id_com}
	 console.log("actualisation de la commande "+ idcom);
	 $scope.isLoading=true;
	 $scope.isPetitLoading=false;


				  // on cree un nouvel onglet s'il n'existe pas
				  var onglet_existe = false;
				  angular.forEach(Onglets.onglets, function (onglet, key) {
					  if (onglet.Label == idcom) {
						  onglet_existe = true
					  }
					  ;
				  });
				  if (!onglet_existe) {
					  Onglets.onglets.push({
						  Label: idcom, Title: 'Commande' + idcom,
						  Route: $location.path(),Closable: true
					  });
				  }
				  // fin creation onglet

			 $http.get('_getCommandePao.asp',{params : {id_com : idcom}}).
					success(function(data, status, headers, config) {
					   $scope.commande = data;
					   $scope.isLoading=false;
					 console.log("fermeture loader loadcommande");
					   $scope.LoadNotes();
					   $scope.LoadJournal();

					  }).
					error(function(data, status, headers, config) {
					  // log error
						$scope.isLoading=false;
					  console.log("erreur de l'application");
					});

	  };

   $scope.LoadGrille = function(statut_bat, groupe_canal) {
	       if (groupe_canal == 'tout') {groupe_canal=''}
		   $scope.isLoading=true;
           console.log(statut_bat);
	   $http.get('_getCommandesPao.asp',{params : {statut_bat : statut_bat, groupe_canal : groupe_canal}}).
				success(function(data, status, headers, config) {

						  if (statut_bat == 'prepress') { 
								
								$scope.commandes.prepress = data;
								$scope.commandes.filtre = data;
								}
						 if (statut_bat == 'New') {
								$scope.commandes[groupe_canal] = data;
								$scope.commandes.filtre = data;
						 }
						 if (statut_bat == 'bat')   {
								$scope.commandes.bat = data;
								$scope.commandes.filtre = data;
													}
					   if (statut_bat == 'BATOK') {
						  
						   $scope.commandes[groupe_canal] = data;
						   $scope.commandes.filtre = data;
					   }
						
													
				  $scope.commandes.grille = data;
				  $scope.isLoading=false;
				
				  }).
				error(function(data, status, headers, config) {
				  // log error
					$scope.isLoading=false;
				  alert("erreur de l'application");
				});
   };
   

$scope.supprimerFiltres  = function(){

$scope.searchCommande='';
//alert($scope.filtreperso.scodix);
 angular.forEach($scope.filtreperso, function (filtre, key) {
					 $scope.filtreperso[key]='';
					 });

};
   
    $scope.Assigne = function(commande, User){
	  		    
					
					if (commande.Assignation == User.Nom ) {return false} // on assigne pas  un trucdeja assigne a la mm personne, c con
						 $scope.isLoading=true;
						
						   $http.get('_setAssignation.asp',{params : {Id_com : commande.Id_com, Id_user : User.Id, Nom_user:User.Nom}}).
							success(function(data, status, headers, config) {
								$scope.LoadGrille('new');
							  }).
							error(function(data, status, headers, config) {
							  // log error
								$scope.isLoading=false;
							  console.log("erreur de l'application2");
							});
						
						
	  				  };
	


$scope.validecontrole = function(commande) {

var visa_user = confirm("Confirmer que le controle est effectué?");
if (visa_user) {
			$scope.isLoading = true;
			$http.get('http://www.faire-part-creatif.com/edc/modifiercontrole.asp', {params: {id_com: commande.Id_web, redirect :'non'}}).
						success(function (data, status, headers, config) {
							alert('Controle ok');
							$scope.LoadCommande();
						}).
						error(function (data, status, headers, config) {
							$scope.isLoading = false;
							$scope.LoadCommande();
							console.log("erreur de l'application l499");
						});

};

};

	$scope.deverouilleStan = function(commande) {
		// cette fonction supprime les fichiers d'une commande allemande groupe_canal = 'stan'
		// et re-init les champs sendpdf du detailcommande du site allemand
		// afin que la pao allemande puisse remettre les fichiers en place
 var visa_user = confirm("cette opération va supprimer les fichiers existants et redonner la main a la PAO Stanhope, etes vous sur ?");

		if (visa_user) {

			// 1 - on supprime les fichiers
			$scope.isLoading = true;
			$http.get('_supprimerfichiers.asp', {params: {id_com: commande.Id_com}}).
				success(function (data, status, headers, config) {

					// 2 - les fichiers sont supprimés, on déverouille le backoff allemand

					$http.get('_deverouillestan.asp', {params: {id_com: commande.Id_web}}).
						success(function (data, status, headers, config) {
							$scope.isLoading = true;
							alert('la pao STAN est déverouillé. la page va etre actualisée');
							$scope.LoadCommande();
						}).
						error(function (data, status, headers, config) {
							// log error
							$scope.isLoading = false;
							console.log("erreur de l'application2");
						});


				}).
				error(function (data, status, headers, config) {
					// log error
					$scope.isLoading = false;
					console.log("erreur de l'application2");
				});

		}
	};

	 $scope.LanceShell = function(path, extension, ouvrir_avec){
	  		    
						 $scope.isLoading=true;
						
						if (extension != '') {   path = path.replace('.pdf',extension) }
						    if (ouvrir_avec =='') {ouvrir_avec = 'default'}
						   $http.get('http://localhost:3000/'+path+'/'+ouvrir_avec).
							success(function(data, status, headers, config) {
								$scope.isLoading=false;
								console.log("fermeture loader3");
							  }).
							error(function(data, status, headers, config) {
							  // log error
								$scope.isLoading=false;
							  
							});
						
						
	  				  };
	
	

		$scope.FichierSourceExiste = function(ref,type){
								console.log("test de la source");
								var url_source = 'http://brian/ED-PAO/sources/'+type+'/' + ref + '.pdf';
											var request = new XMLHttpRequest();
											request.open('HEAD', url_source, false);
											request.send();
												if(request.status == 200) {
													$scope.isPetitLoading = false;
													return true
												} else {
													return false
												}
			
			};
			
	
		$scope.isTemplate2PdfDone = function(source,fichier_source_type,id_ligne) {
			
				if (!$scope.FichierSourceExiste(source,fichier_source_type) && $scope.nbEssais<8) { 
				$scope.nbEssais +=1;
				$timeout(function(){ $scope.isTemplate2PdfDone(source,fichier_source_type); } , 2000);
			} else {
				
				$scope.isPetitLoading=false;
				console.log("template2pdf termine");
				$timeout(function(){ $scope.LoadCommande($scope.commande.Id_com); } , 1000);
				}
			
			};
			

			 $scope.setFichierSource = function(idcom,lignecmd,fichier_source_type){
							
									// source
									var ref = lignecmd.ref;
									 var source = prompt("Attribuer la source '" + fichier_source_type+"'" , ref);
									 
									if (source!=null){	
				
										$scope.persistFichierSource(lignecmd.id_ligne,source,fichier_source_type);						
											   if (!$scope.FichierSourceExiste(source,fichier_source_type)) 
												   
												   {
												
												var action = confirm("la source " + source + " " + fichier_source_type+" est introuvable. Voulez-vous la générer à partir du template? ");
												if (action==true) {
														   
																$scope.isPetitLoading=true;
																if (fichier_source_type.toUpperCase()=='VIERGES') {vierge = 'oui'} else {vierge=''}
																$('#template2pdfFrame').attr('src','http://faire-part-creatif.com/wysiwyg4/template2pdf.asp?ref='+source+'&vierge='+vierge);
															
																$scope.nbEssais = 1;
																$timeout(function(){ $scope.isTemplate2PdfDone(source,fichier_source_type,lignecmd.id_ligne); } , 4000);
															  
																 }
												  }
												   else {
													   $scope.LoadCommande($scope.commande.Id_com);
													   }
										}
			 };

$scope.persistFichierSource = function(id_ligne, fichier_source, fichier_source_type) {
	
	 											$http.get('http://brian/ed/modules/pao/_setFichierSource.asp',{params : {
													 id_ligne : id_ligne,
													 fichier_source : fichier_source,
													 fichier_source_type : fichier_source_type
													 }}).
												success(function(data, status, headers, config) {
													return true												  
											    }).
												error(function(data, status, headers, config) {
												 		return false
												 
												});
	};
									
 $scope.GenereFichier = function(idcom,lignecmd){
											
						// source
						var fichier_source =  lignecmd.fichier_source;
						if (!fichier_source) { alert('aucune source pour ce fichier, merci d\'en attribuer une'); return false}
						
						
				$http.get('http://brian/ed/modules/pao/_genereFichierFromSource.asp',{params : {fichier_source : lignecmd.fichier_source_type+'\\'+lignecmd.fichier_source, destination : lignecmd.chemin+lignecmd.fichier}}).
							success(function(data, status, headers, config) {
								console.log("fermeture _genereFichierFromSource");
								$scope.LoadCommande();
							  }).
							error(function(data, status, headers, config) {
							   alert('erreur dans _genereFichierFromSource '+ idcom)
							});
	  				  };   
   
  
   $scope.Telecharge = function(source,destination,fichierbin,id_ligne,id_com){
						 $scope.isLoading=true;
						 // on a recu quoi ? une url pour dl ou un fichier local pour copie?
						if (fichierbin) { // on a recu un fichier

									fichierbin = fichierbin.replace(/^data:image\/(png|jpg|jpeg);base64,/, "");
									fichierbin = fichierbin.replace(/^data:application\/octet-stream;base64,/,"");
									fichierbin = fichierbin.replace(/^data:application\/pdf;base64,/,"");
									fichierbin = fichierbin.replace(/^data:application\/force-download;base64,/,"");

								 var fd = { id_com : id_com,
											nom_fichier : source,
											destination : destination,
											id_ligne : id_ligne,
											fichier : fichierbin} ;

							var req = {
											 method: 'POST',
											 url: 'http://brian/ed/modules/pao/_postFichier.asp',
											 headers: {'Content-Type': 'application/x-www-form-urlencoded'},
											 data: $httpParamSerializer(fd)
											};

											$http(req)
											.success(function(data, status, headers, config) {
													
													console.log('fichierenregistre');$scope.isLoading=false;
													$timeout(function(){  
													$scope.LoadCommande(); } , 1500);
													
													console.log("fermeture loader3");
												  })
										     .error(function(data, status, headers, config) {
												    // log error
													alert( data)
												    console.log('fichier pas enregistre' + status);
												    $scope.isLoading=false;
													$location.path('/Commande/'+id_com); //on actualise du coup
												});

										}else{
											// on a recu une url
											 $http.get('http://localhost:3000/download/'+source+'/'+destination).
												success(function(data, status, headers, config) {
													console.log('telechargeok, loadcommande('+id_com+')');
$scope.isLoading=false;
													$timeout(function(){  
													$scope.LoadCommande(); } , 1500);
													 console.log("redir ok")
												  }).
												error(function(data, status, headers, config) {
												  // log error
												  $scope.isLoading=false;
												  console.log('telecharge pas ok' + status);
													 $location.path('/Commande/'+id_com); //on actualise du coup
												});
										}
  };

// duplique igne dans commande
$scope.ajoutelignefichier = function(commande,id_ligne,fichier_path,ref,quantite,imprime){

    var id_com =commande.Id_com;
    var indice =commande.contenu.length+1;

var confirmation_user = confirm('Confirmez-vous la création de la ligne ' + ref + ' x ' + quantite + ' imprimé:'+imprime+'?');
if (confirmation_user) {

	$http.get('_setAjoutelignefichier.asp',{params:{
													id_com : id_com,
													id_ligne : id_ligne,
													ref : ref,
													indice : indice,
													imprime : imprime,
													quantite :quantite,
													fichier_path : fichier_path,
	}}).
				success(function(data, status, headers, config) {
					alert(data)
					$scope.LoadCommande();
				}).
				error(function(data, status, headers, config) {
					// log error
					alert("erreur ajouteligne L719");
					$scope.LoadCommande();
				});


			} // confirmation user

};

   // generation des data 
   $scope.LoadJournal = function() {
		   $scope.isLoading=true;
		   id_com = $routeParams.idcommande;
		   $http.get('_getJournalPao.asp',{params:{id_com:id_com}}).
			success(function(data, status, headers, config) {
			    $scope.journal = data;
			    $scope.isLoading=false;

			  }).
			error(function(data, status, headers, config) {
			  // log error
			    $scope.isLoading=false;
			    alert("erreur de l'application");
			});
   };
		$scope.LoadJournalImprimerie = function() {

			$scope.isLoading=true;
			$http.get('_getJournalPao.asp',{params:{etape:'imprimerie'}}).
				success(function(data, status, headers, config) {
					$scope.journal = data;
					$scope.isLoading=false;

				}).
				error(function(data, status, headers, config) {
					// log error
					$scope.isLoading=false;
					alert("erreur de l'application journalimprimerie");
				});
		};

		$scope.showJournalImprimerie = function() {
			if ($scope.showJobSendingLog) {$scope.showJobSendingLog=false} else {$scope.showJobSendingLog=true}
		};

   // generation des data 
   $scope.LoadImprimerie = function(jobDateDebut, jobDateFin) {
       imprimeur = $routeParams.imprimeur;
       if (imprimeur != 'Phaser' && imprimeur != 'Indigo' && imprimeur != 'IndigoN') {alert('route incorrecte'); return false}
	   if (imprimeur =='Phaser') {$scope.showPhaser = true}
	   $scope.isLoading=true;
	console.log("$scope.jobDateDebut : "+$scope.jobDateDebut);
	   $http.get('_getProductionOrders.asp',{params:{'imprimeur' : imprimeur, 'jobDateDebut' : jobDateDebut, 'jobDateFin' : jobDateFin}}).
		   success(function(data, status, headers, config) {
			   $scope.productionOrders = data;
			   $scope.isLoading=false;
			   console.log("productionOrders chargés");
		   }).
		   error(function(data, status, headers, config) {
			   // log error
			   $scope.isLoading=false;
			   alert("erreur de l'application");
		   });

	  // $scope.LoadJournalImprimerie();
		 
   };

    $scope.LoadPlancheur = function(statut_planche) {
    
	   $scope.isLoading=true;
	
	   $http.get('_getProductionOrders.asp',{params:{'imprimeur' : 'Indigo','statut_plancheur' :  statut_planche}}).
		   success(function(data, status, headers, config) {
			   $scope.productionOrders = data;
			   $scope.isLoading=false;
			   console.log("productionOrders chargés");
		   }).
		   error(function(data, status, headers, config) {
			   // log error
			   $scope.isLoading=false;
			   alert("erreur de l'application");
		   });
	 
   };


   $scope.nbJobsExpress = function(){
				
				var nbexpress=0
				angular.forEach($scope.productionOrders, function (job, key) {
					if (job.priorite=='EXPRESS') {nbexpress++}
				});
				return nbexpress;

   }

		$scope.SommeChamp = function(tableau,prop) { // fait la somme  du champ d'un tableau
			var result=0;
			console.log("calcul somme des valeurs de " + prop);
				for (var objet in tableau) {

					result += (tableau[objet][prop]);

					}
			return result;


		}

		$scope.setImprimante = function(imprimante){
			if ($scope.Imprimante == imprimante) { $scope.Imprimante =''} else {	$scope.Imprimante = imprimante }
		};

		$scope.updateJobSelection = function(id_ordre) {
			if ($scope.casejob[id_ordre]==true) {$scope.casejob[id_ordre]=false} else {$scope.casejob[id_ordre]=true}
			$scope.isReadyToSendJobs();
		};

		$scope.isReadyToSendJobs =  function(filteredJobs) {

			for (var job in filteredJobs) {
				$scope.casejob[filteredJobs[job].id_ordre]=true;
			}
			$scope.readyToSend=true;
			//return true

		};

		$scope.imprimeJobs =  function(filteredJobs) {
			$scope.jobsAImprimer=[];
			for (var job in filteredJobs) {
				var id_ordre = filteredJobs[job].id_ordre;
				if ($scope.casejob[id_ordre]==true) {
					var newJob = new function() {
						this.id_ordre = id_ordre;
						this.statut    = 'new';
					};
					$scope.jobsAImprimer.push(newJob);
				}
			}
			$scope.pendingJobs = $scope.jobsAImprimer.length
			if ($scope.pendingJobs>$scope.maxSendingJobs){alert('Trop de jobs a imprimer simultanement');return false}

			if ($scope.pendingJobs>0) {
				$scope.isSendingJobs = true;
				angular.forEach($scope.jobsAImprimer, function (job, key) {
					//alert(job.id_ordre);
					if ($scope.imprimeur == 'Indigo' || $scope.imprimeur == 'IndigoN' || $scope.imprimeur == undefined) {$scope.sendToIndigo(job.id_ordre, false, false) } else {$scope.sendToPhaser(job.id_ordre, true)};

				});
			}

		};

		$scope.sendToIndigo = function(id_ordre,  epreuve, avec_confirm) {

			var presse = $scope.Imprimante;
			if (presse=='') {alert('choississez une imprimante de sortie pour le job');return false}
			if (avec_confirm) {
			var confirmation_user = confirm('Impression sur ' + presse + '?');}
			else {var confirmation_user=true}

			if (confirmation_user) {
				if (epreuve) {epreuve='oui'}
				$scope.isLoading=true;
				$http.get('_sendToIndigo.asp',{params : {id_ordre : id_ordre, imprimante: $scope.Imprimante, epreuve : epreuve}}).
					success(function(data, status, headers, config) {
						$scope.pendingJobs  = $scope.pendingJobs - 1;
						if ($scope.pendingJobs==0) {$scope.isSendingJobs=false;$location.path('/Imprimerie/Indigo');}
						$scope.isLoading=false;
						if (epreuve=='oui') {$scope.LoadJournalImprimerie()}
					}).
					error(function(data, status, headers, config) {
						$scope.pendingJobs  = $scope.pendingJobs - 1;
						alert("erreur envoi du job " + id_ordre);
						alert(data);
						if ($scope.pendingJobs==0) {
							$scope.isSendingJobs=false;
							$location.path('/Imprimerie/'+$scope.Imprimeur);
							$scope.isLoading=false;
						}
					});
			}
		};

		$scope.sendToPhaser = function(id_ordre, avec_confirm) {
		
			if (avec_confirm) {
			var confirmation_user = confirm('Impression sur Phaser des jobs sélectionnés terminée ? ');}
			else {var confirmation_user=true}

			if (confirmation_user) {
				$scope.isLoading=true;
	
				$http.get('_sendToPhaser.asp',{params : {id_ordre : id_ordre}}).
					
					success(function(data, status, headers, config) {
						$scope.pendingJobs  = $scope.pendingJobs - 1;
						if ($scope.pendingJobs==0) {$scope.isSendingJobs=false;$scope.LoadImprimerie();}
						$scope.isLoading=false;
					}).
					error(function(data, status, headers, config) {
						$scope.pendingJobs  = $scope.pendingJobs - 1;
						alert("erreur envoi du job " + id_ordre);
						alert(data);
						if ($scope.pendingJobs==0) {
							$scope.isSendingJobs=false;
							$location.path('/Imprimerie/Phaser');
							$scope.isLoading=false;
						}
					});
			}
		};

$scope.RelanceJob = function(id_ordre,quantite,imprimante,raison_ordre, id_com) {


	//alert('[specimen]relance a lidentique du job ' + id_com+' '+id_ordre + ' x ' + quantite + ' sur ' + imprimante + ' car ' + raison_ordre   );
	
	if ( imprimante==undefined || raison_ordre==undefined) { alert('il faut remplir les choix.');return false};
	var confirmation_user = confirm('Confirmer la réédition du job ' + id_ordre + ' x ' + quantite + ' feuilles sur' + imprimante +'??');
if (confirmation_user) {

	

			$http.get('_setRelanceJob.asp',{params : {
													 id_com : id_com,
													 id_ordre : id_ordre,
													 imprimante: imprimante, 
													 raison_ordre : raison_ordre,
													 quantite : quantite}}).

								success(function(data, status, headers, config) {
										
										alert('le nouveau job est le ' + data)
										$scope.showRelance=false;
								}).
								error(function(data, status, headers, config) {
									alert('erreur L897 ' + data)
								});



		} // end confirmation_user

};

		$scope.StopImpression = function(commande) {
			
			var confirmation_user = confirm('Annulation des jobs de ' + commande.Id_com + '?');

			if (confirmation_user) {
				
				$scope.isLoading=true;
				
				$scope.annuleJobs(commande.Id_com);
				$scope.setStatutCommande(commande.Id_com,'oui','non','annulation job','non');
				$scope.isLoading=false;
				$scope.LoadCommande();

			}
		};


		$scope.annuleJobs = function(id_com) {
 				
 				$http.get('_setStopImpression.asp',{params : {id_com : id_com}}).
				  success(function(data, status, headers, config) {
				   alert('tous les jobs de la commande sont annulés')
				  }).
				error(function(data, status, headers, config) {
					alert("erreur annulation jobs");
				});

		};
		
		$scope.setStatutJob = function(id_job,statut_job,id_com){

				  $http.get('_setStatutJob.asp',{params : {id_job : id_job, statut_job: statut_job, id_com : id_com}}).
				  success(function(data, status, headers, config) {
				 
				  }).
				error(function(data, status, headers, config) {
					alert("erreur statut_job");
				});
			 
	   };
	   $scope.setStatutCommande = function(id_com,pao_needed,prepress_needed,pao_needed_raison,production_autorise){

				  $http.get('_setStatutCommande.asp',{params : {id_com : id_com,pao_needed:pao_needed,prepress_needed:prepress_needed,pao_needed_raison:pao_needed_raison, production_autorise:production_autorise }}).
				  success(function(data, status, headers, config) {
				 
				  }).
				error(function(data, status, headers, config) {
					alert("erreur statut_commande");
				});
			 
	   };


	   $scope.setPAO_visa_expedition = function(commande){

				//alert(commande.PAO_visa_expedition);
 				$http.get('_setPAO_visa_expedition.asp',{params : {id_com : commande.Id_com , PAO_visa_expedition : commande.PAO_visa_expedition  }}).
				  success(function(data, status, headers, config) {
				    console.log("visapaoexped ok")
				  }).
				error(function(data, status, headers, config) {
					alert("erreur l1061 visapaoexped");
				});
	   };




		// generation des notes
	   $scope.LoadNotes = function() {
			   $http.get('_getCommandeNotes.asp',{params : {id_com : $scope.commande.Id_com}}).
				success(function(data, status, headers, config) {
					$scope.commande.notes = data;
				  }).
				error(function(data, status, headers, config) {
					alert("erreur de chargement des notes");
				});
	   };

	   $scope.FermeCommandesTabs = function(){
				   for (var idcom in $scope.showCommande) {
					$scope.showCommande[idcom]=false;
					}
		   };

		   $scope.RemoveTab = function(idcom){
			 var tabidcom = angular.element(document.getElementById('tab'+idcom)).remove();
			 var dividcom = angular.element(document.getElementById('div'+idcom)).remove();
			$scope.LoadGrille('new');
			   };


			$scope.EnvoyerBat = function(commande,pao_comment){


//alert(pao_comment);
//return false;

					 if (!($scope.isReadyToProduce(commande))) {return false}

					 if (confirm("Etes-vous sûr de vouloir envoyer le BAT à " + commande.Email+"?")) {

			$scope.isLoading=true;

				  $http.get('http://plancheur/ed/modules/pao/_setBatEnvoye.asp',{params : {Id_com : commande.Id_com,
																						  	Id_com_web : commande.Id_web,
																						  	Id_client : commande.Id_client,
																						  	pao_comment : pao_comment
																						  }}).
				success(function(data, status, headers, config) {
					
						if (data.bat_web ==true) {
							alert("Le bat a été préparé et envoyé avec success sur espace client")
						} else {
							alert("Le bat a été préparé placé dans le hotfolderbatMail")
						}
						$scope.setStatutBat(commande.Id_com,'BAT',data.bat_web, pao_comment)
						$scope.LoadCommande();
				 		$scope.isLoading=false;

				  }).
				error(function(data, status, headers, config) {
				  // log error

					$scope.isLoading=false;
					alert("erreur envoi du bat L811");
				});
			 }
	   };
   
	   		$scope.setStatutBat = function(id_com,statut_bat, is_bat_web,pao_comment){

				  $http.get('_setStatutBat.asp',{params : {Id_com : id_com,statut_bat: statut_bat, is_bat_web : is_bat_web,pao_comment : pao_comment}}).
				  success(function(data, status, headers, config) {
				 
				  }).
				error(function(data, status, headers, config) {
					
					alert("erreur enregistrement du statut_bat L830");
				});
			 
	   };


   var url = $location.path()
   $scope.showFiltreDate = false;
   for( var param in $routeParams) {
            // Remove from the url all params inside $stateParams
            console.log(param)
			url = url.replace('/' + $routeParams[param], '');
        }
		console.log("Route : " + url);

		switch(url) {
    case '/Journal':
	       $scope.LoadJournal();
		document.title = 'Journal ';

        break;
    case '/JournalIndigo':
	       $scope.LoadJournalImprimerie();
		document.title = 'HistoIndigo ';

        break;
    case '/Commandes':
        $scope.LoadGrille($routeParams.statut_bat,$routeParams.groupe_canal);
        document.title = 'CMD '+ $routeParams.statut_bat+' - '+$routeParams.groupe_canal ;
        break;

	case '/Imprimerie':
		  $scope.imprimeur = $routeParams.imprimeur
		  $scope.showFiltreDate = true; 
		  $scope.LoadImprimerie();
		  document.title = 'Imprimerie' ;
		  break;

	case '/Commande':
		$scope.LoadCommande($routeParams.idcommande);
		document.title = $routeParams.idcommande ;
		break;

	case '/Plancheur':
		
		document.title = 'Plancheur ' + $routeParams.statut_planche ;
		$scope.LoadPlancheur($routeParams.statut_planche);
		break;


			default:
        console.log("pas de route")
} 
  $scope.url = $location.path();
  
   
   
})

// filtre custom pour retourner valeur unique d'une liste
.filter('unique', function() {
	
    return function(input, key) {
		if (typeof input == 'undefined'){return;} 
        var unique = {};
        var uniqueList = [];
        for(var i = 0; i < input.length; i++){
            if(typeof unique[input[i][key]] == "undefined"){
                unique[input[i][key]] = "";
                uniqueList.push(input[i]);
            }
        }
        return uniqueList;
    };

})

.filter('startFrom', function() {
    return function(input, start) {
    	if (typeof input == 'undefined'){return;} 
        start = +start; //parse to int
        return input.slice(start);
    }
})

.directive("datepicker", function () {
  return {
    restrict: "A",
    require: "ngModel",
    link: function (scope, elem, attrs, ngModelCtrl) {
      var updateModel = function (dateText) {
        scope.$apply(function () {
          ngModelCtrl.$setViewValue(dateText);
        });
      };
      var options = {
        dateFormat: "dd/mm/yy",
        onSelect: function (dateText) {
          updateModel(dateText);
        }
      };
      elem.datepicker(options);
    }
  }
});