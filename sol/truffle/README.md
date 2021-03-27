## Installation
Pour compiler le code solidity et lancer les tests unitaires, il faut les paquets npm suivants :
  * testrpc
  * ganache-cli
  * truffle

## Execution des tests
Il faut d'abord lancer testrpc sur le port par exemple 1337 dans le dossier _./sol/truffle_
```bash
ganache-cli --network-id 1338
truffle test
```
