angular.module 'vault'
.controller 'ConsultantController', ($scope, $http, VaultApi, PaillierHandler, EncodingHelper, $mdToast) ->
  'ngInject'

  $scope.types = {
    "KEY": {
      name: "Key"
      value: "KEY"
      equations: {
        "∈": "IN",
        "=": "EQUAL",
      }
    }
    "VALUE": {
      name: "Value"
      value: "VALUE"
      equations: {
        "<": "LESS_THAN"
        "≤": "LESS_THAN_OR_EQUAL_TO"
        "=": "EQUAL"
        ">": "GREATER_THAN"
        "≥": "GREATER_THAN_OR_EQUAL_TO"
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
      $mdToast.show $mdToast.simple().textContent("Oops something went wrong").hideDelay(3000)
      console.log error
    )

  $scope.publicKeyringLoaded = ->

  $scope.client = {}

  $scope.searchDB = ->
    if !$scope.client.id?
      $mdToast.show $mdToast.simple().textContent("Client selection required").hideDelay(3000)
      return
    VaultApi.postClientsByClientIdRecordsGet({
      'clientId': $scope.client.id
      'data':{
        'query': $scope.constraints.map((constraint) ->
          {
            'column': constraint.column
            'value': $scope.paillier.encrypt constraint.value, $scope.client.id
            'operator': constraint.operator
          }
        )
        'keyringData': {
          'keyring': $scope.paillier.privateKeyRing.toString() # TODO serve correct keyring data for verification
        }
    }}).then( (data) ->
      if data.length == 0
        $mdToast.show $mdToast.simple().textContent("No records found").hideDelay(3000)
      for i in [0...data.length]
        data[i].key = $scope.paillier.decryptText data[i].key, $scope.client.id
        data[i].value = $scope.paillier.decryptNumber data[i].value, $scope.client.id

      $scope.results = data
    , (error) ->
      $mdToast.show $mdToast.simple().textContent("Oops something went wrong").hideDelay(3000)
      console.log error
    )

  $scope.addClient = ->
    $scope.clients.push(angular.copy($scope.add))
    VaultApi.postClientsPost({
      'data':{
        'client':$scope.add
        'keyringData': {
          'keyring': $scope.paillier.privateKeyRing.toString() # TODO serve correct keyring data for verification
        }
      }
    }).then( ->
      $mdToast.show $mdToast.simple().textContent("User added").hideDelay(3000)
    , (error) ->
      $mdToast.show $mdToast.simple().textContent("Oops something went wrong").hideDelay(3000)
      console.log error
    )
    $scope.add = {}

  $scope.addRecord = ->
    if !$scope.client.id?
      $mdToast.show $mdToast.simple().textContent("Client selection required").hideDelay(3000)
      return
    VaultApi.postClientsByClientIdRecordsPost({
      'clientId':$scope.client.id
      'data':{
        'record': {
          'key': $scope.paillier.encrypt $scope.record.key, $scope.client.id
          'value': $scope.paillier.encrypt $scope.record.value, $scope.client.id
        }
        'keyringData': {
          'keyring': $scope.paillier.privateKeyRing.toString() # TODO serve correct keyring data for verification
        }
      }
    }).then( ->
      $mdToast.show $mdToast.simple().textContent("Record added").hideDelay(3000)
      $scope.client = {}
      $scope.record = {}
    , (error) ->
      $mdToast.show $mdToast.simple().textContent("Oops something went wrong").hideDelay(3000)
      console.log error
    )

  $scope.deleteRecord = (index, recordId) ->
    if !$scope.client.id?
      $mdToast.show $mdToast.simple().textContent("Client selection required").hideDelay(3000)
      return
    VaultApi.postClientsByClientIdRecordsByRecordIdDelete({
      'clientId': $scope.client.id
      'recordId': recordId
      'keyringData': {
        'keyring': $scope.paillier.privateKeyRing.toString() # TODO serve correct keyring data for verification
      }
    }).then( ->
      $mdToast.show $mdToast.simple().textContent("Record deleted").hideDelay(3000)
      $scope.results.splice index, 1
    , (error) ->
      $mdToast.show $mdToast.simple().textContent("Oops something went wrong").hideDelay(3000)
      console.log error
    )
