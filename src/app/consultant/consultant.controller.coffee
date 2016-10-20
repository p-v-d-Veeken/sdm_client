angular.module 'vault'
.controller 'ConsultantController', ($scope, VaultApi, Paillier, $timeout) ->
  'ngInject'

  $scope.decrypted = ''
  $scope.paillier = Paillier
  $scope.password = ''
  $scope.data = {
    publicKeyRing: null,
    privateKeyRing: null,
    aesKey: null,
    encrypted: null,
    hash: null
  }
  $scope.file = {
    publicKeyRing: [],
    privateKeyRing: [],
    aesKey: [],
    encrypted: [],
    hash: []
  }

  nop = ->
  
  loadPrivateKeyRing = ->
    if $scope.data.aesKey? && $scope.data.privateKeyRing? && $scope.data.hash? && $scope.password.length > 0
      $scope.paillier.loadPrivateKeys $scope.password, $scope.data.hash, $scope.data.aesKey, $scope.data.privateKeyRing
      console.log "loaded and unlocked private keys"


  passwordTimeout = null
  $scope.passwordChanged = ->
    if passwordTimeout?
      $timeout.cancel passwordTimeout
    passwordTimeout = $timeout( ->
      loadPrivateKeyRing()
    , 500)
  
  $scope.$watchCollection 'file.publicKeyRing', ->
    if $scope.file.publicKeyRing[0]?
      load $scope.file.publicKeyRing[0], 'publicKeyRing', false
        .then ->
          $scope.paillier.loadPublicKeys $scope.data.publicKeyRing
        .catch ->
          console.log "oops, publicKeyRing loading failed"

  $scope.$watchCollection 'file.privateKeyRing', ->
    if $scope.file.privateKeyRing[0]?
      load $scope.file.privateKeyRing[0], 'privateKeyRing', true
        .then ->
          loadPrivateKeyRing()
        .catch ->
          console.log "oops, privateKeyRing loading failed"

  $scope.$watchCollection 'file.aesKey', ->
    if $scope.file.aesKey[0]?
      load $scope.file.aesKey[0], 'aesKey', true
        .then ->
          loadPrivateKeyRing()
        .catch ->
          console.log "oops, aesKey loading failed"

  $scope.$watchCollection 'file.hash', ->
    if $scope.file.hash[0]?
      load $scope.file.hash[0], 'hash', false
      .then ->
        loadPrivateKeyRing()
      .catch ->
        console.log "oops, hash loading failed"

  $scope.$watchCollection 'file.encrypted', ->
    if $scope.file.encrypted[0]?
      load $scope.file.encrypted[0], 'encrypted', true
        .then ->
          nop()
        .catch ->
          console.log "oops, encrypted file loading failed"

  load = (file, destination, asHex) ->
    new Promise((resolve, reject) ->
      if not file?
        reject()
      else
        reader = new FileReader()
        if asHex
          reader.onload = (e) ->
#            u = new Uint8Array(e.target.result)
#            a = new Array(u.length)
#            i = u.length
#            while (i--)
#              if u[i] < 16
#                prefix = '0'
#              else
#                prefix = ''
#              a[i] = prefix + u[i].toString(16)
#            u = undefined
#            $scope.data[destination] = a
#            bytes = new Uint8Array(e.target.result)
#            hex = []
#            for i in [0...bytes.length]
#                hex.push((bytes[i] >>> 4).toString(16))
#                hex.push((bytes[i] & 0xF).toString(16))
            $scope.data[destination] = new Uint8Array(e.target.result)
            console.log destination + " loaded"
            resolve()
          reader.readAsArrayBuffer file.lfFile
        else
          reader.readAsText file.lfFile
          reader.onload = (e) ->
            $scope.data[destination] = e.target.result
            console.log destination + " loaded"
            resolve()
    )