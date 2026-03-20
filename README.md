# dApp Vote Web3

## Description

Ce projet est une application décentralisée (dApp) permettant de voter pour des candidats via la blockchain Ethereum (réseau Sepolia).

Les votes sont enregistrés on-chain, ce qui les rend :

- publics
- immuables
- vérifiables par tous

---

## Groupe

Pierre  
Alexandre  
Hugo

---

## Fonctionnalités

- Lecture des résultats sans connexion (fonctions `view`, gratuites)
- Connexion avec MetaMask
- Vote via transaction blockchain (fonction d'écriture, coûte du gas)
- Cooldown de 3 minutes entre deux votes (vérifié on-chain via `block.timestamp`)
- Affichage du hash de transaction
- Affichage du bloc de confirmation
- Mise à jour en temps réel via les events (`Voted`)
- Explorer blockchain intégré (historique des votes, détails des blocs, parentHash)

---

## Technologies utilisées

- **Solidity** ^0.8.20 — Smart contract
- **Hardhat** — Compilation, déploiement, console interactive
- **Ganache** — Blockchain locale pour le développement
- **Alchemy** — Provider RPC pour Sepolia
- **React** (Vite) — Frontend
- **Ethers.js** v6 — Interaction avec la blockchain
- **MetaMask** — Wallet et signature des transactions
- **Ethereum Sepolia** — Réseau de test public

---

## Structure du projet

```
TD2-3/
├── mon-contrat/                  # Projet Hardhat (smart contract)
│   ├── contracts/
│   │   └── Vote.sol              # Smart contract Solidity
│   ├── scripts/
│   │   └── deploy.js             # Script de déploiement
│   ├── artifacts/                # Bytecode + ABI générés par Hardhat
│   ├── hardhat.config.js         # Config réseaux (Ganache + Sepolia)
│   ├── abi.json                  # ABI extraite du contrat
│   ├── .env                      # Clés privées (non versionné)
│   └── package.json
├── src/                          # Frontend React
│   ├── App.jsx                   # Composant principal
│   ├── config.js                 # Adresse du contrat + chainId
│   ├── abi.json                  # ABI utilisée par le frontend
│   ├── index.css / styles.css    # Styles
│   └── main.jsx                  # Point d'entrée React
├── index.html
├── vite.config.js
└── package.json
```

---

## Smart Contract — `Vote.sol`

### Architecture

Le contrat `Vote.sol` implémente un système de vote décentralisé avec les 4 éléments requis par le TD3 :


| Exigence TD3                   | Implémentation                                                               |
| ------------------------------ | ---------------------------------------------------------------------------- |
| Au moins 2 fonctions `view`    | `getCandidatesCount()`, `getCandidate(index)`, `getTimeUntilNextVote(voter)` |
| Au moins 1 fonction d'écriture | `vote(candidateIndex)` — incrémente le compteur, coûte du gas                |
| Au moins 1 event               | `Voted(address indexed voter, uint256 candidateIndex)`                       |
| Au moins 1 `require()`         | Vérification de l'index candidat + cooldown de 3 minutes entre deux votes    |


### Variables d'état

```solidity
address public owner;                            // Adresse du déployeur
Candidate[] private candidates;                  // Tableau des candidats (struct: name, voteCount)
mapping(address => uint256) public lastVoteTime; // Dernier timestamp de vote par adresse
uint256 public constant COOLDOWN = 3 minutes;    // Délai entre deux votes
```

### Fonctions


| Fonction                              | Type     | Description                                                            |
| ------------------------------------- | -------- | ---------------------------------------------------------------------- |
| `getCandidatesCount()`                | `view`   | Retourne le nombre de candidats                                        |
| `getCandidate(uint256 index)`         | `view`   | Retourne le nom et le nombre de votes d'un candidat                    |
| `getTimeUntilNextVote(address voter)` | `view`   | Retourne le temps restant avant de pouvoir revoter (0 si disponible)   |
| `vote(uint256 candidateIndex)`        | écriture | Vote pour un candidat — vérifie l'index et le cooldown via `require()` |


### Candidats initialisés dans le constructor

1. Léon Blum
2. Jacques Chirac
3. François Mitterrand

---

## Déploiement

### Workflow : Ganache → Sepolia

Le contrat a été développé et testé sur **Ganache** (blockchain locale, instantané, sans coût), puis déployé sur **Sepolia** via **Alchemy** pour le rendre public et persistant.


| Étape              | Réseau  | Commande                                              |
| ------------------ | ------- | ----------------------------------------------------- |
| Compilation        | —       | `npx hardhat compile`                                 |
| Tests console      | Ganache | `npx hardhat console --network ganache`               |
| Déploiement local  | Ganache | `npx hardhat run scripts/deploy.js --network ganache` |
| Déploiement public | Sepolia | `npx hardhat run scripts/deploy.js --network sepolia` |


### Configuration Hardhat

Le fichier `hardhat.config.js` configure deux réseaux :

- **Ganache** — `http://127.0.0.1:8545`, chainId `1337`
- **Sepolia** — URL Alchemy + clé privée via `dotenv` (fichier `.env`)

La clé privée et l'URL Alchemy ne sont jamais en dur dans le code : elles sont lues depuis `.env` qui est exclu du versioning via `.gitignore`.

---

## Contrat déployé sur Sepolia

Adresse :  
`0xFe3574bb29A3959db85e6778ecF29eaE4C01b009`

Lien Etherscan :  
[https://sepolia.etherscan.io/address/0xFe3574bb29A3959db85e6778ecF29eaE4C01b009](https://sepolia.etherscan.io/address/0xFe3574bb29A3959db85e6778ecF29eaE4C01b009)

---

## Lancer le projet

### Frontend

```bash
npm install
npm run dev
```

Ouvrir [http://localhost:5173](http://localhost:5173) dans le navigateur.

### Smart Contract (recompiler / redéployer)

```bash
cd mon-contrat
npm install
npx hardhat compile
npx hardhat run scripts/deploy.js --network sepolia
```

Après redéploiement, mettre à jour l'adresse dans `src/config.js`.

---

## Prérequis

- **MetaMask** installé et configuré sur le réseau Sepolia
- **ETH de test** — faucet : [https://cloud.google.com/application/web3/faucet/ethereum/sepolia](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)
- **Node.js** installé
- **Ganache** (optionnel, pour le développement local)

---

## Concepts utilisés

- **Smart Contract Solidity** — variables d'état, struct, mapping, modifier, require, events
- **Compilation & déploiement avec Hardhat** — artifacts, ABI, bytecode
- **Blockchain locale (Ganache)** vs **réseau public (Sepolia)**
- **Provider RPC (Alchemy)** — relais des transactions vers le réseau Ethereum
- **Transactions blockchain** — gas, confirmation, inclusion dans un bloc
- **Signature cryptographique (ECDSA)** — preuve d'identité sans partager la clé privée
- **Events on-chain** — traces immuables écoutables en temps réel depuis le frontend
- **Immutabilité** — parentHash reliant chaque bloc au précédent

---

## Récapitulatif TD3


| Étape                    | Réseau  | Ce qui s'est passé                                       |
| ------------------------ | ------- | -------------------------------------------------------- |
| 1 — Setup                | —       | Projet Hardhat initialisé, Ganache et Sepolia configurés |
| 2 — Solidity             | —       | Contrat `Vote.sol` écrit et compilé                      |
| 3 — Tests console        | Ganache | Logique vérifiée dans le REPL Hardhat                    |
| 4 — Déploiement local    | Ganache | Contrat déployé en local, adresse récupérée              |
| 5 — ABI                  | —       | `abi.json` extrait depuis les artifacts                  |
| 6 — Intégration locale   | Ganache | Frontend rebranché sur Ganache, flux testé               |
| 7 — Déploiement public   | Sepolia | Contrat déployé via Alchemy, visible sur Etherscan       |
| 8 — Intégration publique | Sepolia | Frontend sur Sepolia, transactions on-chain vérifiables  |


---

## Réponses aux questions de compréhension (TD2)

### 1. Pourquoi les scores s'affichent sans MetaMask ?

Les scores s'affichent sans connexion car les données de la blockchain sont publiques.  
N'importe qui peut lire l'état d'un smart contract gratuitement sans signer de transaction.  
Cette propriété est due à la transparence de la blockchain.

---

### 2. Si quelqu'un connaît votre adresse Ethereum, peut-il voter à votre place ?

Non. L'adresse publique seule ne suffit pas.  
Pour voter, il faut signer une transaction avec la clé privée, qui est stockée dans MetaMask et jamais partagée.  
Donc personne ne peut voter à votre place sans votre clé privée.

---

### 3. Qui vérifie le cooldown (frontend ou smart contract) ?

C'est le smart contract qui vérifie le cooldown.  
Même si quelqu'un modifie le frontend ou appelle directement la fonction `vote()`, le contrat refusera si le délai n'est pas respecté.  
Le frontend sert uniquement à afficher l'information à l'utilisateur.

---

### 4. Pourquoi ne pas utiliser `Date.now()` au lieu de `block.timestamp` ?

`Date.now()` dépend de l'ordinateur de l'utilisateur et peut être modifié.  
`block.timestamp` est défini par la blockchain et validé par le réseau, donc fiable et sécurisé.  
Utiliser `Date.now()` permettrait de tricher.

---

### 5. Pourquoi faut-il se désabonner avec `contract.off()` ?

Si on ne se désabonne pas, les événements s'accumulent en mémoire.  
Après plusieurs connexions, le même événement serait déclenché plusieurs fois.  
Cela peut provoquer des bugs et des fuites mémoire.

---

### 6. Pourquoi la blockchain est immuable avec le parentHash ?

Chaque bloc contient le hash du bloc précédent (parentHash).  
Si on modifie un bloc, son hash change, ce qui casse toute la chaîne suivante.  
Cela rend toute modification détectable et pratiquement impossible.