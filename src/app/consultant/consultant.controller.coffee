angular.module 'vault'
.controller 'ConsultantController', ($scope, VaultApi, Paillier) ->
  'ngInject'

  $scope.decrypted = ''
  $scope.data = {
    publicKeyRing: null,
    privateKeyRing: null,
    paillierKey: null,
    encrypted: null
  }
  $scope.file = {
    publicKeyRing: [],
    privateKeyRing: [],
    paillierKey: [],
    encrypted: []
  }

  $scope.$watchCollection 'file.publicKeyRing', ->
    if $scope.file.publicKeyRing[0]?
      load $scope.file.publicKeyRing[0], 'publicKeyRing'

  $scope.$watchCollection 'file.privateKeyRing', ->
    if $scope.file.privateKeyRing[0]?
      load $scope.file.privateKeyRing[0], 'privateKeyRing'

  $scope.$watchCollection 'file.paillierKey', ->
    if $scope.file.paillierKey[0]?
      load $scope.file.paillierKey[0], 'paillierKey'

  $scope.$watchCollection 'file.encrypted', ->
    if $scope.file.encrypted[0]?
      load $scope.file.encrypted[0], 'encrypted'

  load = (file, destination) ->
    if !file
      return
    reader = new FileReader()
    reader.onload = (e) ->
      $scope.data[destination] = e.target.result
      console.log destination + " loaded"
    reader.readAsText file.lfFile

  console.log VaultApi

