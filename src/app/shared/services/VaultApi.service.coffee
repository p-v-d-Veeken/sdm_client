angular.module 'vault'
  .factory 'VaultApi', (VaultApiFunc, apiEndpoint) ->
    'ngInject'
  
    return new VaultApiFunc apiEndpoint
