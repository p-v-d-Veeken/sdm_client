angular.module 'vault'
.controller 'ClientController', ($scope, VaultApi, PaillierHandler, $mdToast) ->
  'ngInject'

  $scope.paillier = PaillierHandler

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
            'value': $scope.paillier.encrypt constraint.compare, $scope.clientId
            'operator': constraint.equation
          }
        )
        'keyringData': {
          'keyring': $scope.paillier.privateKeyRing.toString() # TODO serve correct keyring data for verification
        }
      }
    }).then( (data) ->
      for i in [0...data.length]
        data[i].key = $scope.paillier.decryptText data[i].key, $scope.clientId
        data[i].value = $scope.paillier.decryptNumber data[i].value, $scope.clientId

      $scope.results = data
    , (error) ->
      $mdToast.show $mdToast.simple().textContent("Oops something went wrong").hideDelay(3000)
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
          'key': $scope.paillier.encrypt $scope.newRecord.key, $scope.clientId
          'value': $scope.paillier.encrypt $scope.newRecord.value, $scope.clientId
        }
        'keyring': {
          'keyring': $scope.paillier.privateKeyRing.toString() # TODO serve correct keyring data for verification
        }
      }
    }).then( ->
      $mdToast.show $mdToast.simple().textContent("Record added").hideDelay(3000)
      $scope.newRecord = {
        key: ''
        value: 0
      }
    , (error) ->
      $mdToast.show $mdToast.simple().textContent("Oops something went wrong").hideDelay(3000)
      console.log error
    )

  $scope.deleteRecord = (index, recordId) ->
    if !$scope.clientId?
      return
    VaultApi.postClientsByClientIdRecordsByRecordIdDelete({
      'clientId': $scope.clientId
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