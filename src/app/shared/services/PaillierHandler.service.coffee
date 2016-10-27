angular.module 'vault'
.factory 'PaillierHandler', (HashedPassword, AESKey, EncodingHelper, PublicKey, PrivateKey) ->
  'ngInject'

  class PrivateKeyRing
    constructor: ->
      this._loaded = false
      this._iv = ''
      this._enc_keyring = ''
      this.keys = {}
      this.hashedPassword = null
      this.aesKey = null

    isLoaded: ->
      this._loaded

    load: (password, hash, aesKey, data) ->
      this.hashedPassword = new HashedPassword hash
      this.hashedPassword.validate password
      this.aesKey = new AESKey aesKey
      this.aesKey.decrypt this.hashedPassword.get('hash')
      this._iv = EncodingHelper.bin2hex data.slice(0, 16)
      this._enc_keyring = EncodingHelper.bin2hex data.slice(16, data.length)
      keyring = JSON.parse(CryptoJS.AES.decrypt(
        CryptoJS.lib.CipherParams.create(
          {ciphertext: this._enc_keyring}),
        CryptoJS.enc.Hex.parse(this.aesKey.get('key')),
        {mode: CryptoJS.mode.CBC, padding: CryptoJS.pad.Pkcs7, iv: this._iv})
      .toString(CryptoJS.enc.Utf8))
      for uid, data of keyring
        this.keys[uid] = new PrivateKey(data)
      this._loaded = true

    toByteArray: ->
      EncodingHelper.hex2bin(this._iv.toString()).concat EncodingHelper.hex2bin(this._enc_keyring.toString())

  class PublicKeyRing

    constructor: ->
      this._loaded = false
      this.keys = {}

    isLoaded: ->
      this._loaded

    toString: ->
      JSON.stringify this.keys

    load: (json) ->
      keyring = JSON.parse json
      for uid, data of keyring
        this.keys[uid] = new PublicKey(data)
      this._loaded = true


  class PaillierHandler
    constructor: ->
      this.privateKeyRing = new PrivateKeyRing()
      this.publicKeyRing = new PublicKeyRing()

    loadPublicKeys: (data) ->
      $this = this
      return new Promise (resolve, reject) ->
        try
          $this.publicKeyRing = new PublicKeyRing()
          $this.publicKeyRing.load data
          console.log "Public key loaded"
          resolve()
        catch e
          reject e

    loadPrivateKeys: (password, hash, aesKey, data) ->
      $this = this
      return new Promise (resolve, reject) ->
        try
          $this.privateKeyRing = new PrivateKeyRing()
          $this.privateKeyRing.load password, hash, aesKey, data
          console.log "Private key loaded"
          resolve()
        catch e
          reject(e)

  new PaillierHandler()
