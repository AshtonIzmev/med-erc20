# med-erc20
Proposal for the implementation of an Ethereum ERC20 token with the following economic characteristics:
* The token is melting, that is to say that its quantity decreases each day by a fixed percentage transferred to a specific account (the United States Department of the Treasury for example)
* The token is funded each month by a fixed universal income independent of the account balance
* A specific smart contract allows banks to collect citizens' token savings and inject this savings into the economy instead of monetary creation in the form of debt issuance

## med-erc20 (fr)
Proposition d'implémentation d'un token Ethereum ERC20 avec les caractéristiques économiques suivantes :
* Le token est fondant, c'est-à-dire que sa quantité diminue chaque jour d'un pourcentage fixe reversé dans un compte spécifique (celui de la trésorerie générale par exemple)
* Le token est alimenté chaque mois par un revenu universel fixe indépendant du solde du compte
* Un smart contract spécifique permet aux banques de récupérer l'épargne en token des citoyens et d'injecter cette épargne dans l'économie en lieu et place de la création monétaire sous forme d'émission de dette

# Getting started
## Dev suite
### Node
Install Node https://nodejs.org/en/  
Follow theses steps if using Ubuntu : https://doc.ubuntu-fr.org/nodejs

Verify the install  
`node -v && npm -v`
### Suite Etherem
Install Truffle  
`npm install -g truffle`

Install ganache-cli  
`npm install -g ganache-cli`

## Compile and test
In order to test our solidity code, we need a test blockchain. We can use Ganache with the following command in *./sol/truffle*  
`ganache-cli -p 8545 --networkId 1338`  
The port 8545 has been declared in _truffle.js_  and links truffle and ganache.  
Launch the tests by using the following command in *./sol/truffle*:  
`truffle test`
