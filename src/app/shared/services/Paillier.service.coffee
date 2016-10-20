angular.module 'vault'
.factory 'Paillier', ->
  'ngInject'

  class PrivateKeyRing
    this.keys = {}
    hashPassword: (password) ->
      hash_triple = password.split ":"
      iterations = hash_triple[0]
      salt = CryptoJS.enc.Hex.parse hash_triple[1]
      stored_hash = hash_triple[2]
      first_hash = CryptoJS.PBKDF2 password, salt, {keySize: 256 / 32, iterations: iterations} .toString CryptoJS.enc.Hex
      if stored_hash == CryptoJS.PBKDF2 first_hash, salt, {keySize: 256 / 32, iterations: iterations}
        first_hash
      else
        throw new Error("Invalid password")

    generateKey: (passwordHash, aesKey) ->
      iv = CryptoJS.lib.WordArray.create aesKey.slice(0, 16)
      key_enc = CryptoJS.lib.WordArray.create aesKey.slice(16, aesKey.length)
      CryptoJS.AES.decrypt(
        CryptoJS.lib.CipherParams.create(
          {ciphertext: key_enc}),
        CryptoJS.enc.Hex.parse(passwordHash),
        {mode: CryptoJS.mode.CBC, padding: CryptoJS.pad.Pkcs7, iv: iv})
      .toString(CryptoJS.enc.Hex)

    load: (password, aesKey, data) ->
      passwordHash = hashPassword password
      return if passwordHash == null
      key = generateKey passwordHash, aesKey
      iv = CryptoJS.lib.WordArray.create data.slice(0, 16)
      encryptedKeyRing = CryptoJS.lib.WordArray.create data.slice(16, data.length)
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
      this.publicKeyRing.load data

    loadPrivateKeys: (password, aesKey, data) ->
      this.privateKeyRing.load password, aesKey, data

  return new Paillier()