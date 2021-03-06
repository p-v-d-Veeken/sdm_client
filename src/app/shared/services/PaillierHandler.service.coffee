angular.module 'vault'
.factory 'PaillierHandler', (HashedPassword, AESKey, EncodingHelper, PublicKey, PrivateKey) ->
  'ngInject'

  class PrivateKeyRing
    constructor: ->
      @_loaded = false
      @_iv = ''
      @_enc_keyring = ''
      @keys = {}
      @hashedPassword = null
      @aesKey = null

    isLoaded: ->
      @_loaded

    load: (password, hash, aesKey, data) ->
      @hashedPassword = new HashedPassword hash
      @hashedPassword.validate password
      @aesKey = new AESKey aesKey
      @aesKey.decrypt @hashedPassword.get('hash')
      @_iv = EncodingHelper.bin2hex data.slice(0, 16)
      @_enc_keyring = EncodingHelper.bin2hex data.slice(16, data.length)
      keyring = JSON.parse(CryptoJS.AES.decrypt(
        CryptoJS.lib.CipherParams.create(
          {ciphertext: @_enc_keyring}),
        CryptoJS.enc.Hex.parse(@aesKey.get('key')),
        {mode: CryptoJS.mode.CBC, padding: CryptoJS.pad.Pkcs7, iv: @_iv})
      .toString(CryptoJS.enc.Utf8))
      for uid, data of keyring
        @keys[uid] = new PrivateKey(data)
      @_loaded = true
      
    toString: ->
      jsonObj = {}
      for id, key of @keys
        jsonObj[id] = key.serialize paillierHandler.publicKeyRing.keys[id]
      JSON.stringify jsonObj

    toByteArray: ->
      EncodingHelper.hex2bin(@_iv.toString()).concat EncodingHelper.hex2bin(@_enc_keyring.toString())

  class PublicKeyRing

    constructor: ->
      @_loaded = false
      @keys = {}

    isLoaded: ->
      @_loaded

    toString: ->
      JSON.stringify @keys

    load: (json) ->
      keyring = JSON.parse json
      for uid, data of keyring
        @keys[uid] = new PublicKey(data)
      @_loaded = true


  class PaillierHandler
    constructor: ->
      @privateKeyRing = new PrivateKeyRing()
      @publicKeyRing = new PublicKeyRing()

    loadPublicKeys: (data) ->
      $this = this
      return new Promise (resolve, reject) ->
        try
          $this.publicKeyRing.load data
          console.log "Public key loaded"
          resolve()
        catch e
          reject e

    loadPrivateKeys: (password, hash, aesKey, data) ->
      $this = this
      return new Promise (resolve, reject) ->
        try
          $this.privateKeyRing.load password, hash, aesKey, data
          console.log "Private key loaded"
          resolve()
        catch e
          reject(e)

    encrypt: (value, id) ->
      result = ""
      for item in new String(value).split(" ")
        result = result + paillierHandler.publicKeyRing.keys[id].encrypt2Base64(EncodingHelper.string2bigint(item)) + " "
      result.slice(0,-1)

    decryptNumber: (value, id) ->
      parseInt(paillierHandler.privateKeyRing.keys[id].decrypt(EncodingHelper.base64Tobigint(value)).toString())

    decryptText: (value, id) ->
      result = ""

      for item in value.split(" ")
        result += EncodingHelper.bin2string(
          paillierHandler.privateKeyRing.keys[id].decrypt(EncodingHelper.base64Tobigint(item)).toByteArray()
        ) + " "
      result.slice(0,-1)

  paillierHandler = new PaillierHandler()
  paillierHandler
