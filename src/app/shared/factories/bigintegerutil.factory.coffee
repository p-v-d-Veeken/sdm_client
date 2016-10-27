angular.module 'vault'
.factory 'BigIntegerUtil', ->
  'ngInject'

  class BigIntegerUtil
    sqrt: (n) ->
      a = BigInteger.ONE
      b = n.shiftRight(5).add(new BigInteger("8"))

      while b.compareTo(a) >= 0
        mid = a.add(b).shiftRight(1)
        if mid.multiply(mid).compareTo(n) > 0
          b = mid.subtract(BigInteger.ONE)
        else
          a = mid.add(BigInteger.ONE)
      a.subtract(BigInteger.ONE)

    modPow: (base, exp, mod) ->
      base.modPow(exp, mod)

  new BigIntegerUtil()