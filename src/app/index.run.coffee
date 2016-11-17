angular.module 'vault'
  .run ($rootScope, $log, $state, $stateParams) ->
    'ngInject'

    $rootScope.$state = $state
    $rootScope.$stateParams = $stateParams

    $log.debug 'runBlock end'
