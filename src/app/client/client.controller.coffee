angular.module 'vault'
.controller 'ClientController', ($scope, PaillierHandler, PrivateKey, EncodingHelper) ->
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
    sk = $scope.paillier.privateKeyRing.keys['0']
    m = new BigInteger("6636747413342380331600365822169624645239508640912621320494065920357926858938818198333336836641864983269025899284720802015208440121628529987474708195910712191229859798535346745685053929630732425872825069446287233429656338375386748699416695823764256715596402673384700777201040011641973500476744532386423151844248901868899370713812716440565030835682840044693876614204759559720022169411277787519152639569600745394650530040049289488887079554111856933614540484710265196490699661203549101453296906991301079075403498164132671052103945001458408785823057692272376670432887530439676240226371734154619001747015239538752336432200")
    #c = sk._pk.encrypt(m)
    console.log(sk.decrypt(m).toString())
    ###console.log(sk)
    c = new BigInteger(EncodingHelper.string2bin($scope.phrase))
    m = sk.decrypt(c).toByteArray()
    console.log(new BigInteger(m).toString())
    console.log(EncodingHelper.bin2string([73, 117, 60, 42, -101, 96, 21, -103, -72, -111, 104, -6, 8, 23, -89, 66, 109, 17, -20, 79, 37, 37, 10, -43, 104, 60, -102, 63, 100, 68, 116, 27, -90, 12, -57, 35, 7, 100, 122, 30, -6, 66, 17, 2, 44, -71, 124, 121, -12, 32, -52, -31, 34, -43, 91, 60, 97, 36, -107, -38, 68, 29, 81, -64, 94, -6, -15, 4, -2, 11, -108, -67, 55, 48, -64, -116, -82, -19, -2, -32, -13, 114, 53, -83, 39, 56, -65, 80, -95, 2, 3, -41, 39, -118, 36, -60, -111, 40, -66, -57, 77, 71, 88, 43, 2, -57, -112, 125, -29, 39, -116, 101, 13, 33, 28, -108, -13, -127, 94, 34, -66, 124, -8, -112, 119, -105, 72, -37, -47, -58, 13, 94, 82, -57, -59, -15, -21, -58, -70, -76, 79, -104, -58, -73, 19, -125, -103, -80, -101, 68, -18, 127, -100, -16, -22, -52, 10, 79, 34, 8, 16, 124, 41, -18, 55, -113, -118, -20, -86, -102, -79, 27, -124, -42, 70, -59, 114, -81, 39, 91, 111, 93, -39, -103, -37, 79, -69, 15, -36, 42, -74, -28, -48, -81, -94, 89, -58, -94, 119, 14, 69, 80, 92, 74, -29, -11, -93, 72, 24, 111, 102, -71, -15, 47, -85, 79, 77, -82, -57, -46, -54, 60, 125, 77, -88, 99, 90, 45, 95, 63, 70, -31, 58, -9, 25, -8, -19, 41, -35, -46, -102, -101, -89, 65, -28, 53, -74, 107, -66, -45, 102, -70, 90, -110, 31, -105]))###

  $scope.publicKeyringLoaded = ->
    pk = $scope.paillier.publicKeyRing.keys[0]
    console.log(pk.encrypt(new BigInteger("80085")).toString())

  $scope.phrase = ''
  $scope.test_phrase = ->
    console.log $scope.phrase