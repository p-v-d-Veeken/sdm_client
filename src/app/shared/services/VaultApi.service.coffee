angular.module 'vault'
  .factory 'VaultApi', (VaultApiFunc, apiEndpoint) ->
    'ngInject'

    endpoint = apiEndpoint if apiEndpoint? else undefined
    return new VaultApiFunc endpoint
