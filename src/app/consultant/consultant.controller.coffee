angular.module 'vault'
.controller 'ConsultantController', ($scope, $http, VaultApi, PaillierHandler) ->
  'ngInject'

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

  $scope.updateQuery = ->
    $scope.search.set = $scope.search.column? && $scope.search.column.length > 0
    $scope.equations = $scope.types[$scope.search.column].equations if $scope.types[$scope.search.column]?

  $scope.constraints = []

  $scope.addItem = ->
    if $scope.search.column? && $scope.search.operator? && $scope.search.value?
      $scope.constraints.push(angular.copy($scope.search))
      $scope.search = {}

  $scope.deleteConstraint = (index) ->
    $scope.constraints = $scope.constraints.splice index, 1
    $scope.constraints = [] if $scope.constraints.length < 2

  $scope.add = {}

  $scope.clients = []

  $scope.paillier = PaillierHandler

  $scope.generateKeyring = (index) ->
    console.log("generating keyring")

  $scope.privateKeyringLoaded = ->
    VaultApi.postClientsGet({
      'keyringData': {
        'keyring': $scope.paillier.privateKeyRing.toString() # TODO serve correct keyring data for verification
      }
    }).then( (data) ->
      $scope.clients = data
    , (error) ->
      console.log error
    )

  $scope.publicKeyringLoaded = ->

  $scope.client = {}

  $scope.searchDB = ->
    VaultApi.postClientsByClientIdRecordsGet({
      'clientId':$scope.client.id
      'data':{
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
    }})

  $scope.addClient = ->
    $scope.clients.push(angular.copy($scope.add))
    VaultApi.postClientsPost({
      'data':{
        'client':$scope.add
        'keyringData': {
          'keyring': $scope.paillier.privateKeyRing.toString() # TODO serve correct keyring data for verification
        }
      }
    }).then( (data) ->
      console.log("Added a new user")
    , (error) ->
      console.log error
    )
    $scope.add = {}

  $scope.addRecord = ->
    VaultApi.postClientsByClientIdRecordsPost({
      'clientId':$scope.client.id
      'data':{
        'record': {
          'key': base64js.fromByteArray(new Uint8Array(
            $scope.paillier.publicKeyRing.keys[$scope.clientId].encrypt($scope.record.key).toByteArray()))
          'value': base64js.fromByteArray(new Uint8Array(
            $scope.paillier.publicKeyRing.keys[$scope.clientId].encrypt($scope.record.value).toByteArray()))
        }
        'keyringData': {
          'keyring': $scope.paillier.privateKeyRing.toString() # TODO serve correct keyring data for verification
        }
      }
    }).then( (data) ->
      console.log("Added a record")
      $scope.client = {}
      $scope.record = {}
    , (error) ->
      console.log error
    )

  $scope.deleteRecord = (index) ->
    VaultApi.postClientsByClientIdRecordsByRecordIdDelete({
      'clientId':$scope.client.id
      'recordId':index
      'keyringData': {
        'keyring': $scope.paillier.privateKeyRing.toString() # TODO serve correct keyring data for verification
      }
    }).then( (data) ->
      $scope.records = data
    , (error) ->
      console.log error
    )