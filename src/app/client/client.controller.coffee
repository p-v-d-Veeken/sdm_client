angular.module 'vault'
.controller 'ClientController', ($scope, Paillier, $timeout) ->
  'ngInject'

  $scope.keyringBundle = []
  $scope.password = ''
  privateKeyringData = {}
  $scope.keyringForm = null
  $scope.filesApi = null
  $scope.errors = {}

  $scope.types = {"Key","Value"}
  $scope.equations = {"Equal","Smaller","Greater or equal"}

  $scope.constraints = []

  $scope.addItem = (constraint)->
    $scope.constraints.push(angular.copy(constraint))

  loadPrivateKeyRing = ->
    if privateKeyringData.aesKey? && privateKeyringData.privateKeyRing? && privateKeyringData.hash? && $scope.password.length > 0
      Paillier.loadPrivateKeys $scope.password, privateKeyringData.hash, privateKeyringData.aesKey, privateKeyringData.privateKeyRing
      .then ->
        console.log "loaded and unlocked private keys"
      .catch (e) ->
        throw e

  passwordTimeout = null
  $scope.passwordChanged = ->
    if passwordTimeout?
      $timeout.cancel passwordTimeout
    passwordTimeout = $timeout( ->
      loadPrivateKeyRing()
    , 500)

  $scope.$watchCollection 'keyringBundle', ->
    if $scope.keyringBundle[0]?
      if $scope.keyringBundle[0].lfFileName.indexOf('.bundle') != -1
        delete $scope.errors['filetype']
        JSZip.loadAsync($scope.keyringBundle[0].lfFile).then((zip) ->
          zip.files['pk_ring.pai'].async("string").then (publicKeyRing) ->
            Paillier.loadPublicKeys publicKeyRing
            .then ->
              console.log "Loaded public keyring"
            .catch (e) ->
              throw e
          zip.files['pass_hash.pai'].async("string").then (hash) ->
            privateKeyringData.hash = hash
            loadPrivateKeyRing()
          zip.files['sk_ring.pai'].async("uint8array").then (privateKeyRing) ->
            privateKeyringData.privateKeyRing = privateKeyRing
            loadPrivateKeyRing()
          zip.files['key.pai'].async("uint8array").then (aesKey) ->
            privateKeyringData.aesKey = aesKey
            loadPrivateKeyRing()
        ).catch ->
          $scope.filesApi.removeAll()
          $scope.keyringBundle = []
      else
        $scope.errors['filetype'] = "Wrong file type"
