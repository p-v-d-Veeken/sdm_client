angular.module 'vault'
.factory 'AESKey', (EncodingHelper) ->
  'ngInject'

  class AESKey
    this._iv = ''
    this._key_enc = ''
    this._key = ''

    constructor: (keystring) ->
      this._iv = EncodingHelper.bin2hex keystring.slice(0, 16)
      this._key_enc = EncodingHelper.bin2hex keystring.slice(16, keystring.length)

    decrypt: (hash) ->
      this._key = CryptoJS.AES.decrypt(
        CryptoJS.lib.CipherParams.create({ciphertext: this._key_enc}),
        CryptoJS.enc.Hex.parse(hash),
        {mode: CryptoJS.mode.CBC, padding: CryptoJS.pad.Pkcs7, iv: this._iv})
      .toString(CryptoJS.enc.Hex)

    encrypt: (hash) ->
      this._key_enc = CryptoJS.AES.encrypt(
        CryptoJS.lib.CipherParams.create({ciphertext: this._key}),
        CryptoJS.enc.Hex.parse(hash),
        {mode: CryptoJS.mode.CBC, padding: CryptoJS.pad.Pkcs7, iv: this._iv})
      .toString(CryptoJS.enc.Hex)
      this._key = ''
      # TODO verify this

    get: (name) ->
      switch name
        when 'iv' then this._iv
        when 'encoded' then this._key_enc
        when 'key' then this._key
        else throw new Error 'Illegal argument'

    toByteArray: ->
      EncodingHelper.hex2bin(this._iv.toString()).concat EncodingHelper.hex2bin(this._key_enc.toString())

  AESKey