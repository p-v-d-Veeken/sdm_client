angular.module 'vault'
.factory 'AESKey', (EncodingHelper) ->
  'ngInject'

  class AESKey
    @_iv = ''
    @_key_enc = ''
    @_key = ''

    constructor: (keystring) ->
      @_iv = EncodingHelper.bin2hex keystring.slice(0, 16)
      @_key_enc = EncodingHelper.bin2hex keystring.slice(16, keystring.length)

    decrypt: (hash) ->
      @_key = CryptoJS.AES.decrypt(
        CryptoJS.lib.CipherParams.create({ciphertext: @_key_enc}),
        CryptoJS.enc.Hex.parse(hash),
        {mode: CryptoJS.mode.CBC, padding: CryptoJS.pad.Pkcs7, iv: @_iv})
      .toString(CryptoJS.enc.Hex)

    encrypt: (hash) ->
      @_key_enc = CryptoJS.AES.encrypt(
        CryptoJS.lib.CipherParams.create({ciphertext: @_key}),
        CryptoJS.enc.Hex.parse(hash),
        {mode: CryptoJS.mode.CBC, padding: CryptoJS.pad.Pkcs7, iv: @_iv})
      .toString(CryptoJS.enc.Hex)
      @_key = ''
      # TODO verify this

    get: (name) ->
      switch name
        when 'iv' then @_iv
        when 'encoded' then @_key_enc
        when 'key' then @_key
        else throw new Error 'Illegal argument'

    toByteArray: ->
      EncodingHelper.hex2bin(@_iv.toString()).concat EncodingHelper.hex2bin(@_key_enc.toString())

  AESKey