angular.module 'vault'
.directive 'keyringHandler', ($timeout) ->
  'ngInject'
  restrict: 'E'
  templateUrl: 'app/shared/directives/keyringhandler/index.html'
  scope:
    onPublicKeyring: '=',
    onPrivateKeyring: '=',
    paillier: '='
  link: ($scope) ->
    $scope.keyringBundle = []
    $scope.filesApi = null
    $scope.errors = {}
    $scope._loaded = false
    fileData = {}
    $scope.password = ''

    loadPrivateKeyRing = ->
      if fileData["key.pai"]? && fileData["sk_ring.pai"]? && fileData["pass_hash.pai"]? && $scope.password.length > 0
        $scope.paillier.loadPrivateKeys $scope.password, fileData["pass_hash.pai"], fileData["key.pai"], fileData["sk_ring.pai"]
        .then ->
          $scope.onPrivateKeyring()
        .catch (e) ->
          throw e

    passwordTimeout = null
    $scope.passwordChanged = ->
      if passwordTimeout?
        $timeout.cancel passwordTimeout
      passwordTimeout = $timeout( ->
        loadPrivateKeyRing()
      , 500)

    $scope.bundleKeyring = ->
      if $scope.paillier.publicKeyRing.isLoaded() && $scope.paillier.privateKeyRing.isLoaded()
        zip = new JSZip()
        zip.file "pass_hash.pai", $scope.paillier.privateKeyRing.hashedPassword.toString()
        zip.file "key.pai", $scope.paillier.privateKeyRing.aesKey.toByteArray()
        zip.file "sk_ring.pai", $scope.paillier.privateKeyRing.toByteArray()
        zip.file "pk_ring.pai", $scope.paillier.publicKeyRing.toString()
        zip.generateAsync({type:"blob"}).then((blob) ->
          saveAs blob, "keys.bundle"
        , (err) ->
          console.error err
        )

    $scope.$watchCollection 'keyringBundle', ->
      $scope._loaded = false
      if $scope.keyringBundle[0]?
        if $scope.keyringBundle[0].lfFileName.indexOf('.bundle') != -1
          delete $scope.errors['filetype']
          fileData = {}
          JSZip.loadAsync($scope.keyringBundle[0].lfFile).then((zip) ->
            zip.files['pk_ring.pai'].async("string").then (publicKeyRing) ->
              fileData['pk_ring.pai'] = publicKeyRing
              $scope.paillier.loadPublicKeys fileData['pk_ring.pai']
              .then ->
                $scope.onPrivateKeyring()
              .catch (e) ->
                throw e
            zip.files['pass_hash.pai'].async("string").then (hash) ->
              fileData['pass_hash.pai'] = hash
              loadPrivateKeyRing()
            zip.files['sk_ring.pai'].async("uint8array").then (privateKeyRing) ->
              fileData['sk_ring.pai'] = privateKeyRing
              loadPrivateKeyRing()
            zip.files['key.pai'].async("uint8array").then (aesKey) ->
              fileData['key.pai'] = aesKey
              loadPrivateKeyRing()
          ).catch ->
            $scope.filesApi.removeAll()
            $scope.keyringBundle = []
        else
          $scope.errors['filetype'] = "Wrong file type"
      else
        $scope.filesApi.removeAll() if $scope.filesApi?
        $scope.keyringBundle = []
