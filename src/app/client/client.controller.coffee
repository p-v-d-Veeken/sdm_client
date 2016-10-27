angular.module 'vault'
.controller 'ClientController', ($scope, PaillierHandler, EncodingHelper) ->
  'ngInject'

  $scope.paillier = PaillierHandler

  $scope.types = {
    "KEY": {
      name: "Key"
      value: "KEY"
      equations: {
        "=": "="
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

  $scope.phrase = ''

  $scope.constraints = []

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

  $scope.test_phrase = ->
    console.log($scope.phrase)

  $scope.privateKeyringLoaded = ->
    console.log new BigInteger(EncodingHelper.string2bin(window.atob($scope.paillier.privateKeyRing.keys['0'].lambda))).toString()

  $scope.publicKeyringLoaded = ->



  $scope.phrase = ''
  $scope.test_phrase = ->
    console.log $scope.phrase