angular.module 'vault'
  .config ($stateProvider, $urlRouterProvider) ->
    'ngInject'

    $stateProvider
    .state 'client',
      url: '/client'
      data : { pageTitle: 'Client | Vault' }
      views:
        '@':
          templateUrl: 'app/client/index.html'
          controller: 'ClientController'
    .state 'consultant',
      url: '/consultant'
      data : { pageTitle: 'Consultant | Vault' }
      views:
        '@':
          templateUrl: 'app/consultant/index.html'
          controller: 'ConsultantController'

    $urlRouterProvider.otherwise('/client')
