angular.module 'vault'
  .config ($logProvider, $locationProvider, $httpProvider) ->
    'ngInject'
    # Enable log
    $logProvider.debugEnabled true
    # Set options third-party lib
    # toastrConfig.allowHtml = true

    $locationProvider.html5Mode(false)

    $httpProvider.defaults.useXDomain = true
    delete $httpProvider.defaults.headers.common['X-Requested-With']

