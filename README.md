This is the repository for the smart-contract code of [cryptosanta.gifts](https://cryptosanta.gifts), which operates on Ethereum blockchain.

Smart-contract is used to maintain non-fungible [ERC-721](https://github.com/ethereum/eips/issues/721) token GIFT which is crypto-collectible gift from lazy Santa on Christmas and New Year of 2017.

[NFT.sol](contracts/NFT.sol) and [BasicNFT.sol](contracts/BasicNFT.sol) contain basic implementation of the ERC-721 token, based on implementation from [Decentraland](https://github.com/decentraland/land/blob/master/contracts/BasicNFT.sol).

[CryptoSanta.sol](contracts/CryptoSanta.sol) contains the implementation of the gift-sending mechanic to friends or yourself together with the mechanic for obtaining rewards from completed collections.

Code in this repository doesn't contain tests (although there were a lot of them) or useful comments because Santa is lazy lad.

*Merry Christmas and Happy New Year, friends! Ho-ho-ho!*
