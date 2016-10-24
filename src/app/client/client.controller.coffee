angular.module 'vault'
.controller 'ClientController', ($scope, Paillier) ->
  'ngInject'

  $scope.paillier = Paillier
  
  $scope.types = {"Key","Value"}
  $scope.equations = {"Equal","Smaller","Greater or equal"}

  $scope.constraints = []

  $scope.addItem = (constraint)->
    $scope.constraints.push(angular.copy(constraint))
    
  $scope.privateKeyringLoaded = ->

  $scope.publicKeyringLoaded = ->
