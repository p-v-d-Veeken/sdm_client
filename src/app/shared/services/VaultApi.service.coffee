angular.module 'vault'
  .factory 'VaultApi', (VaultApiFunc, apiEndpoint) ->
    'ngInject'

    if apiEndpoint?
      endpoint = apiEndpoint
    else
      endpoint = undefined
    return new VaultApiFunc endpoint
