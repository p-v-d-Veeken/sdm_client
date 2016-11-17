angular.module 'vault'
.factory 'PublicKey', (EncodingHelper, BigIntegerUtil)->
  'ngInject'

  byte_length = 8 #haha, chill

  class PublicKey
    constructor: (data) ->
      n_buffer = EncodingHelper.string2bin(window.atob(data.n))
      @n = new BigInteger n_buffer
      @bits = (n_buffer.length - 1) * byte_length
      @nSquare = @n.square()
      @g = @n.add BigInteger.ONE
      @rncache = new Array()

    add: (a, b) ->
      a.multiply(b).remainder @nSquare

    randomize: (a) ->
      if @rncache.length > 0
        rn = @rncache.pop()
      else
        rn = @getRN()
      a.multiply(rn).mod(@nSquare)

    precompute: (n) ->
      for i in [0...n]
        @rncache.push @getRN()

    encrypt: (m) ->
      @rawObfuscate(@rawEncryptNoObfuscation(m))

    encrypt2Base64: (m) ->
      base64js.fromByteArray(
        new Uint8Array(
          @encrypt(m).toByteArray()
        )
      )

    rawEncryptNoObfuscation: (m) ->
      @n.multiply(m).add(BigInteger.ONE).mod(@nSquare)

    rawObfuscate: (m) ->
      BigIntegerUtil.modPow(BigIntegerUtil.randomBigInt(@n, @bits), @n, @nSquare).multiply(m).mod(@nSquare)

    serialize: ->
      {
        'alg': 'PAI-GN1'
        'kty': 'DAj'
        'n': base64js.fromByteArray(new Uint8Array(@n.toByteArray()))
        'key_ops': ['encrypt']
      }

  PublicKey