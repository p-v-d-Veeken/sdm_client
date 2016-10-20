angular.module 'vault'
.controller 'ConsultantController', ($scope, VaultApi, Paillier) ->
  'ngInject'

  $scope.decrypted = ''
  $scope.paillier = Paillier
  $scope.password = ''
  $scope.data = {
    publicKeyRing: null,
    privateKeyRing: null,
    aesKey: null,
    encrypted: null
  }
  $scope.file = {
    publicKeyRing: [],
    privateKeyRing: [],
    aesKey: [],
    encrypted: []
  }

  nop = ->
  
  loadPrivateKeyRing = ->
    if $scope.data.aesKey? && $scope.data.privateKeyRing && $scope.password.length > 0
      $scope.paillier.loadPrivateKeys $scope.password, $scope.data.aesKey, $scope.data.privateKeyRing
      console.log "loaded and unlocked private keys"
  
  $scope.passwordChanged = ->
    loadPrivateKeyRing()
  
  $scope.$watchCollection 'file.publicKeyRing', ->
    if $scope.file.publicKeyRing[0]?
      load $scope.file.publicKeyRing[0], 'publicKeyRing'
        .then ->
          $scope.paillier.loadPublicKeys $scope.data.publicKeyRing
        .catch ->
          console.log "oops, publicKeyRing loading failed"

  $scope.$watchCollection 'file.privateKeyRing', ->
    if $scope.file.privateKeyRing[0]?
      load $scope.file.privateKeyRing[0], 'privateKeyRing'
        .then ->
          loadPrivateKeyRing()
        .catch ->
          console.log "oops, privateKeyRing loading failed"

  $scope.$watchCollection 'file.aesKey', ->
    if $scope.file.aesKey[0]?
      load $scope.file.aesKey[0], 'aesKey'
        .then ->
          loadPrivateKeyRing()
        .catch ->
          console.log "oops, aesKey loading failed"

  $scope.$watchCollection 'file.encrypted', ->
    if $scope.file.encrypted[0]?
      load $scope.file.encrypted[0], 'encrypted'
        .then ->
          nop()
        .catch ->
          console.log "oops, encrypted file loading failed"

  load = (file, destination) ->
    new Promise((resolve, reject) ->
      if not file?
        reject()
      else
        reader = new FileReader()
        reader.onload = (e) ->
          $scope.data[destination] = e.target.result
          console.log destination + " loaded"
          resolve()
        reader.readAsText file.lfFile
    )