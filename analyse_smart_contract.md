# Analyse d'un Smart Contract — dApp Vote Présidentielle

> **Cours 3WEB3 · Jour 2 · Bloc 4 · B3**  
> Réseau : Sepolia Testnet · Contrat : `0x291Ac3C6a92dF373dEa40fee62Ad39831B8A1DDC`

---

## Phase 1 — Observation de l'interface

### 1.1 — Ce que vous voyez sans wallet

**Les résultats s'affichent-ils avant connexion ?** → ✅ Oui

**Pourquoi ?**  
Les données de vote sont stockées dans le smart contract sur la blockchain Ethereum. Lire l'état d'un contrat (appel `view`) ne nécessite pas de wallet — c'est une lecture publique gratuite. La blockchain est **transparente par nature** : toutes les données sont publiques et lisibles sans authentification.

| Élément | Présent ? | Localisation dans l'interface |
|---|:---:|---|
| Adresse du contrat déployé | ✅ | Footer / section info |
| Lien vers Etherscan | ✅ | Lien cliquable vers `sepolia.etherscan.io` |
| Nombre de votes par candidat | ✅ | Section principale, barres/compteurs |
| Historique des transactions | ✅ | Blockchain Explorer intégré |
| Explication du fonctionnement | ✅ | Section descriptive de la page |

---

### 1.2 — Connexion MetaMask

**Quelle information nouvelle s'affiche ?**  
L'adresse du wallet connecté apparaît dans l'interface, et le bouton de vote devient actif.

**MetaMask a-t-il demandé un login/mot de passe ?** → Non

**Modèle Web3 vs Web2 ?**  
En Web2, l'authentification repose sur un identifiant/mot de passe stocké côté serveur. En Web3, l'identité est une **paire de clés cryptographiques** (clé privée/publique) — pas de serveur d'auth, pas de compte à créer. MetaMask signe les requêtes avec la clé privée, prouvant que l'on contrôle l'adresse sans jamais la révéler.

---

## Phase 2 — Voter et observer la transaction

### 2.1 — Envoyer un vote

**Adresse du contrat dans la popup MetaMask ?**
```
0x291Ac3C6a92dF373dEa40fee62Ad39831B8A1DDC
```

**Coût en gas estimé ?** → *(à compléter avec ta valeur)*

**Pourquoi le vote coûte-t-il du gas ?**  
Voter appelle la fonction `vote()` du smart contract, ce qui **modifie l'état de l'EVM** (mise à jour des compteurs). Toute écriture nécessite une exécution par les nœuds du réseau, rémunérés en gas. Une simple lecture (`view`) est gratuite ; une écriture est payante.

---

### 2.2 — Analyser la transaction confirmée

**Hash de la transaction :**
```
0x175ca670f94f2144a613009ca66e17ca4e827892825842712bddd434e9e3fd6e
```

| Donnée | Valeur |
|---|---|
| Numéro du bloc | 10 484 128 |
| Timestamp du bloc | Mar-20-2026 01:35:48 PM UTC |
| Gas utilisé (gasUsed) | 16 813 442 (28.02%) |
| Gas limit fixé | 60 000 000 |
| Statut | ✅ Success |
| Fonction appelée | `vote` |

**gasUsed vs gasLimit ?**  
Le `gasLimit` est le maximum autorisé à dépenser (protection contre les boucles infinies). Le `gasUsed` est ce qui a réellement été consommé. Il est inférieur car l'EVM s'arrête dès que le code est terminé — **le surplus non utilisé est remboursé**.

---

### 2.3 — Le cooldown de 3 minutes

**Que se passe-t-il si on revote immédiatement ?**  
L'interface affiche un message d'erreur indiquant qu'il faut attendre avant de revoter. MetaMask peut aussi rejeter la transaction avant même de l'envoyer.

**Frontend ou smart contract ?**  
C'est dans le **smart contract**. Même en contournant le frontend (appel direct via Etherscan ou `ethers.js`), la transaction échouerait avec un `revert`. Le contrat est la source de vérité, pas l'interface.

**Variable et fonction Solidity ?**


---

## Phase 3 — Investigation on-chain via Etherscan

### 3.1 — Onglet "Transactions"

**Nombre total de transactions reçues ?** → 12 transactions *(au moment de l'analyse)*

**Pourquoi la première transaction est-elle différente ?**  
La colonne "Method" indique `Contract Creation` pour le déploiement, alors que les suivantes indiquent `vote`. Le déploiement ne cible aucun contrat existant — c'est une transaction spéciale qui **publie le bytecode sur l'EVM** et génère l'adresse du contrat.

---

### 3.2 — Onglet "Events"

**Nom de l'event émis à chaque vote ?** → `VoteCast`

**Les deux paramètres :** `voter` (adresse) **et** `candidateId` (uint)

**Event vs variable d'état ?**  
Une variable d'état est stockée dans le storage du contrat (coûteux, persistant, lisible on-chain). Un event est émis dans les **logs de la transaction** (moins cher, non accessible par d'autres contrats, mais facilement indexable par le frontend via `ethers.js`). L'event sert à notifier l'interface en temps réel sans relire tout le storage.

---

### 3.3 — Onglet "Contract"

**Code source visible ?** → ✅ Oui *(contrat vérifié)*

**Ligne vérifiant le cooldown dans `vote()` :**
```solidity
require(block.timestamp >= lastVoteTime[msg.sender] + 3 minutes, "...");
```

**Si la condition `require()` n'est pas respectée ?**  
La transaction est **revertée** — l'état ne change pas, mais le gas consommé jusqu'au `require` est perdu. Un message d'erreur est retourné à l'appelant.

---

### 3.4 — Analyse d'un bloc via le Blockchain Explorer

| Donnée | Valeur |
|---|---|
| parentHash | `0x175ca670f94f2144a613009ca66e17ca4e827892825842712bddd434e9e3fd6e` |
| gasUsed (transaction) | 16 813 442 |
| gasLimit (bloc) | 60 000 000 |
| Validateur (miner) | *(à compléter)* |

**Qu'est-ce que le `parentHash` ?**  
C'est le hash du bloc précédent, inclus dans l'en-tête de chaque nouveau bloc. Il **chaîne les blocs entre eux** : modifier un bloc ancien changerait son hash, invaliderait le `parentHash` du suivant, et ainsi de suite. Réécrire l'historique nécessiterait de recalculer toute la chaîne — ce qui est calculatoirement infaisable. C'est le mécanisme fondamental de l'**immuabilité** de la blockchain.

**Le bloc précédent contient-il aussi un vote ?**  
Probablement non. Les blocs Sepolia sont produits toutes ~12 secondes, et les votes sont rares. Chaque transaction attend dans la mempool puis est incluse dans le prochain bloc disponible — rien ne garantit qu'un vote tombe dans chaque bloc consécutif.

---

## Phase 4 — Analyse critique

### 4.1 — Ce que la blockchain apporte ici

| Propriété | Exploitée ? | Justification |
|---|:---:|---|
| **Immuabilité** | ✅ Oui | Les votes enregistrés on-chain ne peuvent pas être modifiés après confirmation |
| **Transparence** | ✅ Oui | N'importe qui peut lire les résultats et vérifier les transactions sur Etherscan |
| **Désintermédiation** | ✅ Oui | Pas de serveur central — le contrat s'exécute sur l'EVM de façon autonome |
| **Décentralisation** | ⚠️ Partielle | Le contrat est décentralisé, mais le frontend est hébergé sur Vercel (centralisé) |

---

### 4.2 — Ce que la blockchain n'apporte pas (les limites)

**Ce vote est-il vraiment anonyme ?**  
**Non.** Chaque vote est lié à une adresse Ethereum publiquement visible sur Etherscan. Si une adresse est connue (échange, ENS, réseaux sociaux), on peut savoir pour qui elle a voté. C'est de la **pseudonymie**, pas de l'anonymat.

**Peut-on contourner le cooldown de 3 minutes ?**  
Oui, facilement : il suffit de créer un **second wallet**. Le cooldown est stocké par adresse (`mapping address => timestamp`), donc chaque nouvelle adresse repart à zéro. Un utilisateur peut voter toutes les 3 minutes indéfiniment en générant de nouveaux wallets (**attaque Sybil**).

**N'importe qui peut-il déployer une interface différente ?**  
Oui. Le smart contract est public, son ABI est lisible sur Etherscan. N'importe qui peut créer un frontend alternatif connecté au même contrat. Cela montre que le "contrôle" d'une dApp est **dissocié** : le contrat est immuable et incontrôlable, mais le frontend reste sous contrôle de son hébergeur — un frontend malveillant pourrait tromper les utilisateurs.

---

### 4.3 — Verdict final

Cette dApp exploite correctement les propriétés fondamentales de la blockchain : les votes sont immuables, vérifiables publiquement, et ne transitent par aucun serveur central. Le choix d'Ethereum/Solidity est techniquement justifié pour garantir la transparence. Cependant, deux failles importantes nuancent son intérêt : le cooldown est facilement contournable avec plusieurs wallets (absence de résistance aux attaques Sybil), et le vote n'est pas anonyme, exposant publiquement les choix de chaque adresse. L'usage de la blockchain est **partiellement justifié** pour la transparence et l'immuabilité, mais insuffisant seul pour garantir l'intégrité d'un vrai scrutin.

---

## Fiche de synthèse

| | |
|---|---|
| **Adresse wallet** | `0x...` *(à compléter)* |
| **Hash de la transaction** | `0x175ca670f94f2144a613009ca66e17ca4e827892825842712bddd434e9e3fd6e` |
| **Numéro du bloc** | 10 484 128 |

**En une phrase — qu'est-ce qu'un smart contract ?**  
Un smart contract est un programme autonome déployé sur la blockchain qui s'exécute automatiquement selon des règles codées, sans intermédiaire et sans possibilité de modification une fois déployé.

**Frontend (Vercel) vs Smart Contract (Sepolia) ?**  
Le frontend est l'interface visuelle hébergée sur un serveur centralisé qui permet à l'utilisateur d'interagir ; le smart contract est la logique métier exécutée de façon décentralisée sur l'EVM, qui stocke et garantit l'intégrité des données.
