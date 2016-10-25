angular.module 'vault'
.factory 'HexHandler', ->
  'ngInject'

  class HexHandler
    parseHex: (data) ->
      hex = []
      data.forEach((c) ->
        hex.push((c >>> 4).toString(16))
        hex.push((c & 0xF).toString(16))
      )
      CryptoJS.enc.Hex.parse(hex.join(""))

    toHex: (data) ->
      bytes = []
      c = 0
      while c < data.length
        bytes.push parseInt(data.substr(c, 2), 16)
        c += 2
      bytes

  new HexHandler()