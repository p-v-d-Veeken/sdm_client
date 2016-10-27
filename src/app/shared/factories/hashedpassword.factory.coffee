angular.module 'vault'
.factory 'HashedPassword', ->
  'ngInject'

  class HashedPassword
    @_iterations = 1
    @_salt = ''
    @_stored_hash = ''
    @_hash = ''

    constructor: (hash) ->
      hash_triple = hash.split ":"
      @_iterations = hash_triple[0]
      @_salt = CryptoJS.enc.Hex.parse(hash_triple[1])
      @_stored_hash = hash_triple[2]

    validate: (password) ->
      first_hash = CryptoJS.PBKDF2(password, @_salt,
        keySize: 256 / 32
        iterations: @_iterations).toString(CryptoJS.enc.Hex)
      second_hash = CryptoJS.PBKDF2(first_hash, @_salt,
        keySize: 256 / 32
        iterations: @_iterations)
      if @_stored_hash == second_hash.toString()
        @_hash = first_hash
      else
        throw new Error("Invalid password")

    hash: (password) ->
      first_hash = CryptoJS.PBKDF2(password, @_salt,
        keySize: 256 / 32
        iterations: @_iterations).toString(CryptoJS.enc.Hex)
      second_hash = CryptoJS.PBKDF2(first_hash, @_salt,
        keySize: 256 / 32
        iterations: @_iterations)
      @_stored_hash = second_hash.toString()
      @_hash = first_hash.toString()

    set: (name, value) ->
      switch name
        when 'iterations' then @_iterations = value
        when 'salt' then @_salt = value
        else throw new Error 'Illegal argument'


    get: (name) ->
      switch name
        when 'iterations' then @_iterations
        when 'salt' then @_salt
        when 'stored hash' then @_stored_hash
        when 'hash' then @_hash
        else throw new Error 'Illegal argument'

    toString: ->
      @_iterations + ":" + @_salt + ":" + @_stored_hash

  HashedPassword