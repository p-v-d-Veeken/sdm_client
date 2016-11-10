angular.module 'vault'
.factory 'PrivateKey', (EncodingHelper, PublicKey) ->
  'ngInject'

  class PrivateKey
    constructor: (data) ->
      @_lambda = new BigInteger(EncodingHelper.string2bin(window.atob(data.lambda)))
      @_pk = new PublicKey(data.pub)
      @_x = @_pk.np1.modPow(@_lambda, @_pk.n2).subtract(BigInteger.ONE).divide(@_pk.n).modInverse(@_pk.n)

    decrypt: (c) ->
      return c.modPow(@_lambda, @_pk.n2)
      .subtract(BigInteger.ONE).divide(@_pk.n)
      .multiply(@_x).mod(@_pk.n)

  PrivateKey