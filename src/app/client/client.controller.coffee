angular.module 'vault'
.controller 'ClientController', ($scope, VaultApi, PaillierHandler, PrivateKey, EncodingHelper) ->
  'ngInject'

  $scope.paillier = PaillierHandler

  $scope.types = {
    "KEY": {
      name: "Key"
      value: "KEY"
      equations: {
        "∈": "in",
        "=": "=",
      }
    }
    "VALUE": {
      name: "Value"
      value: "VALUE"
      equations: {
        "<": "<"
        "≤": "<="
        "=": "="
        ">": ">"
        "≥": ">="
      }
    }
  }
  $scope.search = {
    set: false
  }

  $scope.constraints = []
  $scope.results = []

  $scope.newRecord = {
    key: ''
    value: 0
  }

  $scope.updateQuery = ->
    $scope.search.set = $scope.search.type? && $scope.search.type.length > 0
    $scope.equations = $scope.types[$scope.search.type].equations if $scope.types[$scope.search.type]?

  $scope.addItem = ->
    if $scope.search.type? && $scope.search.equation? && $scope.search.compare?
      $scope.constraints.push(angular.copy($scope.search))
      $scope.search = {}

  $scope.deleteConstraint = (index) ->
    $scope.constraints = $scope.constraints.splice index, 1
    $scope.constraints = [] if $scope.constraints.length < 2

  $scope.executeSearch = ->
    VaultApi.postClientsByClientIdRecordsGet({
      'clientId': 0 # TODO set the right client id
      'data': {
        'query': $scope.constraints.map((constraint) ->
          {
            'column': constraint.type
            'value': constraint.compare
            'operator': constraint.equation
          }
        )
        'keyringData': {
          'keyring': $scope.paillier.privateKeyRing.toString() # TODO serve correct keyring data for verification
        }
      }
    }).then( (data) ->
      console.log data
    , (error) ->
      console.log error
    )

  $scope.privateKeyringLoaded = ->

  $scope.publicKeyringLoaded = ->

  $scope.createRecord = ->
    VaultApi.postClientsByClientIdRecordsPost({
      'clientId': 0 # TODO set the right client id
      'data': {
        'record': {
          'key': $scope.newRecord.key
          'value': $scope.newRecord.value
        }
        'keyring': {
          'keyring': $scope.paillier.privateKeyRing.toString() # TODO serve correct keyring data for verification
        }
      }
    }).then( (data) ->
      console.log data
      $scope.newRecord = {
        key: ''
        value: 0
      }
    , (error) ->
      console.log error
    )
