angular.module 'vault'
.factory 'EncodingHelper', ->
  'ngInject'

  class EncodingHelper
    bin2hex: (data) ->
      hex = []
      data.forEach((c) ->
        hex.push((c >>> 4).toString(16))
        hex.push((c & 0xF).toString(16))
      )
      CryptoJS.enc.Hex.parse(hex.join(""))

    hex2bin: (data) ->
      bytes = []
      c = 0
      while c < data.length
        bytes.push parseInt(data.substr(c, 2), 16)
        c += 2
      bytes

    string2bin: (string) ->
      array = new Uint8Array(new ArrayBuffer(string.length))
      i = 0
      while i < string.length
        array[i] = string.charCodeAt i & 0xff
        i++
      array

    bin2string: (bin) ->
      str = ""
      buf = new Uint8Array bin
      for i in [0...buf.length]
        str += String.fromCharCode buf[i]
      str

  new EncodingHelper()