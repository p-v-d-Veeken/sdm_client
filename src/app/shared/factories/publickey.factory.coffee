angular.module 'vault'
.factory 'PublicKey', (EncodingHelper)->
  'ngInject'

  byte_length = 8

  class PublicKey
    constructor: (data) ->
      n_buffer = EncodingHelper.string2bin(window.atob(data.n))
      @n = new BigInteger n_buffer
      @bits = (n_buffer.length - 1) * byte_length
      @n2 = @n.square()
      @g = @n.add BigInteger.ONE
      @rncache = new Array()

    add: (a, b) ->
      a.multiply(b).remainder @n2

    randomize: (a) ->
      if @rncache.length > 0
        rn = @rncache.pop()
      else
        rn = @getRN()
      a.multiply(rn).mod(@n2)

    getRN: ->
      r = undefined
      rng = new SecureRandom
      loop
        r = new BigInteger @bits, rng
        unless r.compareTo @n >= 0
          break
      r.modPow @n, @n

    precompute: (n) ->
      for i in [0...n]
        @rncache.push @getRN()

    encrypt: (m) ->
      @randomize @n.multiply(m).add(BigInteger.ONE).mod(@n2)

  PublicKey