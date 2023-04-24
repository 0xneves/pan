### What is this?

Install env. modules:

```
yarn
```

And run locally with:

```
npx hardhat test
```

Or run directly on the forked Mainnet:

```
npx hardhat test --network hardhat
```

To verify the contract use:
(constructor arguments must go as overloads)

```
npx hardhat verify --network polygon 0x2a20dbc4373de2023B24C760d08aE14b133E2416 "argument 1" "argument 2"
```
