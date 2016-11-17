angular.module 'vault'
.controller 'ClientController', ($scope, VaultApi, PaillierHandler, EncodingHelper) ->
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

  encryptData = (m) ->
    $scope.paillier.publicKeyRing.keys[$scope.clientId].encrypt2Base64(EncodingHelper.string2bigint(m))

  decryptData2Num = (c) ->
    parseInt($scope.paillier.privateKeyRing.keys[$scope.clientId].decrypt(EncodingHelper.base64Tobigint(c)).toString())

  decryptData2String = (c) ->
    EncodingHelper.bin2string(
      $scope.paillier.privateKeyRing.keys[$scope.clientId].decrypt(EncodingHelper.base64Tobigint(c)).toByteArray()
    )

  $scope.executeSearch = ->
    if !$scope.clientId?
      return
    VaultApi.postClientsByClientIdRecordsGet({
      'clientId': $scope.clientId
      'data': {
        'query': $scope.constraints.map((constraint) ->
          {
            'column': constraint.type
            'value': encryptData constraint.compare
            'operator': constraint.equation
          }
        )
        'keyringData': {
          'keyring': $scope.paillier.privateKeyRing.toString() # TODO serve correct keyring data for verification
        }
      }
    }).then( (data) ->
      for i in [0...data.length]
        data[i].key = decryptData2String data[i].key
        data[i].value = decryptData2Num data[i].value
      console.log(data)
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
          'key': encryptData $scope.newRecord.key
          'value': encryptData $scope.newRecord.value
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