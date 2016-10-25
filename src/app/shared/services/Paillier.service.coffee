angular.module 'vault'
.factory 'Paillier', (HashedPassword, AESKey) ->
  'ngInject'

  parseHex = (data) ->
    hex = []
    data.forEach((c) ->
      hex.push((c >>> 4).toString(16))
      hex.push((c & 0xF).toString(16))
    )
    CryptoJS.enc.Hex.parse(hex.join(""))

  toHex = (data) ->
    bytes = []
    c = 0
    while c < data.length
      bytes.push parseInt(data.substr(c, 2), 16)
      c += 2
    bytes

  class PrivateKeyRing
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
      this._iv = parseHex data.slice(0, 16)
      this._enc_keyring = parseHex data.slice(16, data.length)
      this.keys = JSON.parse(CryptoJS.AES.decrypt(
        CryptoJS.lib.CipherParams.create(
          {ciphertext: this._enc_keyring}),
        CryptoJS.enc.Hex.parse(this.aesKey.get('key')),
        {mode: CryptoJS.mode.CBC, padding: CryptoJS.pad.Pkcs7, iv: this._iv})
      .toString(CryptoJS.enc.Utf8))
      this._loaded = true

    toByteArray: ->
      toHex(this._iv.toString()).concat toHex(this._enc_keyring.toString())

  class PublicKeyRing
    this._loaded = false
    this.keys = {}

    isLoaded: ->
      this._loaded

    toString: ->
      JSON.stringify this.keys

    load: (data) ->
      this.keys = JSON.parse data
      this._loaded = true


  class Paillier
    constructor: ->
      this.privateKeyRing = new PrivateKeyRing()
      this.publicKeyRing = new PublicKeyRing()

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
          reject e

  new Paillier()
