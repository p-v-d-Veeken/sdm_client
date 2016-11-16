angular.module 'vault'
.controller 'ClientController', ($scope, VaultApi, PaillierHandler) ->
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
    if !$scope.clientId?
      return
    VaultApi.postClientsByClientIdRecordsGet({
      'clientId': $scope.clientId
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
    for uid, _ of $scope.paillier.publicKeyRing.keys
      $scope.clientId = parseInt(uid)
      return

  $scope.createRecord = ->
    if !$scope.clientId?
      return
    VaultApi.postClientsByClientIdRecordsPost({
      'clientId': $scope.clientId
      'data': {
        'record': {
          'key': base64js.fromByteArray(new Uint8Array(
            $scope.paillier.publicKeyRing.keys[$scope.clientId].encrypt(
              new BigInteger(EncodingHelper.string2bin($scope.newRecord.key))
            ).toByteArray()))
          'value': base64js.fromByteArray(new Uint8Array(
            $scope.paillier.publicKeyRing.keys[$scope.clientId].encrypt(
              new BigInteger(EncodingHelper.string2bin($scope.newRecord.value))
            ).toByteArray()))
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
