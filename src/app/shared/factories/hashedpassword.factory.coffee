angular.module 'vault'
.factory 'HashedPassword', ->
  'ngInject'

  class HashedPassword
    this._iterations = 1
    this._salt = ''
    this._stored_hash = ''
    this._hash = ''

    constructor: (hash) ->
      hash_triple = hash.split ":"
      this._iterations = hash_triple[0]
      this._salt = CryptoJS.enc.Hex.parse(hash_triple[1])
      this._stored_hash = hash_triple[2]

    validate: (password) ->
      first_hash = CryptoJS.PBKDF2(password, this._salt,
        keySize: 256 / 32
        iterations: this._iterations).toString(CryptoJS.enc.Hex)
      second_hash = CryptoJS.PBKDF2(first_hash, this._salt,
        keySize: 256 / 32
        iterations: this._iterations)
      if this._stored_hash == second_hash.toString()
        this._hash = first_hash
      else
        throw new Error("Invalid password")

    hash: (password) ->
      first_hash = CryptoJS.PBKDF2(password, this._salt,
        keySize: 256 / 32
        iterations: this._iterations).toString(CryptoJS.enc.Hex)
      second_hash = CryptoJS.PBKDF2(first_hash, this._salt,
        keySize: 256 / 32
        iterations: this._iterations)
      this._stored_hash = second_hash.toString()
      this._hash = first_hash.toString()

    set: (name, value) ->
      switch name
        when 'iterations' then this._iterations = value
        when 'salt' then this._salt = value
        else throw new Error 'Illegal argument'


    get: (name) ->
      switch name
        when 'iterations' then this._iterations
        when 'salt' then this._salt
        when 'stored hash' then this._stored_hash
        when 'hash' then this._hash
        else throw new Error 'Illegal argument'

    toString: ->
      this._iterations + ":" + this._salt + ":" + this._stored_hash

  HashedPassword