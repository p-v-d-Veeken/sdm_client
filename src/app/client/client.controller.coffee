angular.module 'vault'
.controller 'ClientController', ($scope, Paillier) ->
  'ngInject'

  $scope.paillier = Paillier
  
  $scope.types = {
    "KEY": {
      name: "Key"
      value: "KEY"
      equations: {
        "Equal": "="
      }
    }
    "VALUE": {
      name: "Value"
      value: "VALUE"
      equations: {
        "Smaller": "<"
        "Greater or equal": ">="
      }
    }
  }
  $scope.search = {
    set: false
  }

  $scope.constraints = []
  
  $scope.updateQuery = ->
    $scope.search.set = $scope.search.type? && $scope.search.type.length > 0
    $scope.equations = $scope.types[$scope.search.type].equations if $scope.types[$scope.search.type]?

  $scope.addItem = (constraint)->
    $scope.constraints.push(angular.copy(constraint))
    
  $scope.privateKeyringLoaded = ->

  $scope.publicKeyringLoaded = ->
