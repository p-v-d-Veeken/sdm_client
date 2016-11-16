angular.module 'vault'
.factory 'PrivateKey', (EncodingHelper, PublicKey, BigIntegerUtil) ->
  'ngInject'

  class PrivateKey
    constructor: (data) ->
      @_lambda = new BigInteger(EncodingHelper.string2bin(window.atob(data.lambda)))
      @_pk = new PublicKey(data.pub)
      pPlusQ = @_pk.n.subtract(@_lambda).add(BigInteger.ONE)
      pMinusQ = BigIntegerUtil.sqrt(pPlusQ.multiply(pPlusQ).subtract(@_pk.n.multiply(new BigInteger("4"))))
      @_q = (pPlusQ.subtract(pMinusQ)).divide(new BigInteger("2"))
      @_p = pPlusQ.subtract(@_q)
      @_qSquare = @_q.multiply(@_q)
      @_pSquare = @_p.multiply(@_p)
      @_pInverse = @_p.modInverse(@_q)
      @_hp = @hFunction(@_p, @_pSquare)
      @_hq = @hFunction(@_q, @_qSquare)

    lFunction: (x, p) ->
      x.subtract(BigInteger.ONE).divide(p)

    hFunction: (x, xSquare) ->
      @lFunction(BigIntegerUtil.modPow(@_pk.g, x.subtract(BigInteger.ONE), xSquare), x).modInverse(x)

    crt: (mp, mq) ->
      u = mq.subtract(mp).multiply(@_pInverse).mod(@_q)

      mp.add(u.multiply(@_p))

    decrypt: (c) ->
      decryptedToP = @lFunction(BigIntegerUtil.modPow(c, @_p.subtract(BigInteger.ONE), @_pSquare), @_p)
      .multiply(@_hp).mod(@_p)
      decryptedToQ = @lFunction(BigIntegerUtil.modPow(c, @_q.subtract(BigInteger.ONE), @_qSquare), @_q)
      .multiply(@_hq).mod(@_q)

      @crt(decryptedToP, decryptedToQ)

    serialize: (pub) ->
      sk = {}
      sk.kty = "DAJ"
      sk.key_ops = ["decrypt"]
      sk.pub = pub.serialize()
      sk.lamda = btoa @_lambda.toString()

      sk

  PrivateKey