angular.module("vault")
  # TODO uiteindelijk bij deployment parameters juist zetten
  .constant "apiEndpoint", "http://localhost:3010/api"
# .constant "apiEndpoint", "https://api.vault.maketek.nl/api"
  .constant "apiDomain", "localhost"
# .constant "apiDomain", "api.vault.maketek.nl"