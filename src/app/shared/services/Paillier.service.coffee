angular.module 'vault'
.factory 'Paillier', ->
  'ngInject'

  parseHex = (data) ->
    hex = []
    data.forEach((c) ->
      hex.push((c >>> 4).toString(16))
      hex.push((c & 0xF).toString(16))
    )
    CryptoJS.enc.Hex.parse(hex.join(""))

  class PrivateKeyRing
    this.keys = {}
    validatePassword: (password, hash) ->
      hash_triple = hash.split ":"
      iterations = hash_triple[0]
      salt = CryptoJS.enc.Hex.parse(hash_triple[1])
      stored_hash = hash_triple[2]
      first_hash = CryptoJS.PBKDF2(password, salt,
        keySize: 256 / 32
        iterations: iterations).toString(CryptoJS.enc.Hex)
      second_hash = CryptoJS.PBKDF2(first_hash, salt,
        keySize: 256 / 32
        iterations: iterations)
      if stored_hash == second_hash.toString()
        first_hash
      else
        throw new Error("Invalid password")

    generateKey: (passwordHash, aesKey) ->
      iv = parseHex aesKey.slice(0, 16)
      key_enc = parseHex aesKey.slice(16, aesKey.length)
      CryptoJS.AES.decrypt(
        CryptoJS.lib.CipherParams.create(
          {ciphertext: key_enc}),
        CryptoJS.enc.Hex.parse(passwordHash),
        {mode: CryptoJS.mode.CBC, padding: CryptoJS.pad.Pkcs7, iv: iv})
      .toString(CryptoJS.enc.Hex)

    load: (password, hash, aesKey, data) ->
      passwordHash = this.validatePassword password, hash
      return if passwordHash == null
      key = this.generateKey passwordHash, aesKey
      iv = parseHex data.slice(0, 16)
      encryptedKeyRing = parseHex data.slice(16, data.length)
      this.keys = JSON.parse(CryptoJS.AES.decrypt(
        CryptoJS.lib.CipherParams.create(
          {ciphertext: encryptedKeyRing}),
        CryptoJS.enc.Hex.parse(key),
        {mode: CryptoJS.mode.CBC, padding: CryptoJS.pad.Pkcs7, iv: iv})
      .toString(CryptoJS.enc.Utf8))

  class PublicKeyRing
    this.keys = {}
    load: (data) ->
      this.keys = JSON.parse data


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

  return new Paillier()