angular.module 'vault'
.factory 'EncodingHelper', ->
  'ngInject'

  class EncodingHelper
    bin2hex: (data) ->
      hex = ""
      hex += ('0' + (byte & 0xFF).toString(16)).slice(-2) for byte in data
      CryptoJS.enc.Hex.parse hex

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