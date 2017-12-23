pragma solidity ^0.4.17;


import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './BasicNFT.sol';


contract CryptoSanta is Ownable, BasicNFT {
	using SafeMath for uint;

	string public standard = 'ERC721';

	string public name = 'CRYPTO SANTA GIFT';

	string public symbol = 'GIFT';

	uint8 public decimals = 0;

	uint public nextGiftIndexToAssign = 1;

	uint private _founderTokensAmount = 0;
	uint private _founderTokensMax = 1000;
	mapping(uint => bool) public isFounderToken;

	// address where funds are collected
	address public wallet;

	// how many token units a buyer gets per wei
	uint256 public giftPriceWei;

	uint256 public endTime;

	mapping(uint => uint8) public tokenType;
	mapping(uint => bool) public tokenUsed;
	mapping(address => address) public refAddresses;
	mapping(uint8 => string) public tokenTypeImage;

	uint8[] _giftsTypesRarity;

	struct Collection {
		uint8 rewardType;
		uint8[] requiredTypes;
	}

	Collection[] _giftsCollection;

	event GiftCreated(address indexed from, address indexed to, uint tokenId);

	function CryptoSanta(uint256 _giftPriceWei, address _wallet, uint _endTime) {
		require(_wallet != address(0));
		require(_giftPriceWei > 0);

		giftPriceWei = _giftPriceWei;
		wallet = _wallet;
		endTime = _endTime;
	}

	function sendGift(address to, uint8 giftsCount, address ref) public payable {
		require(endTime > now);
		require(giftsCount > 0);
		require(giftsCount <= 15);

		uint giftsPrice = giftPriceWei.mul(giftsCount);
		require(msg.value >= giftsPrice);

		uint giftWei = msg.value.sub(giftsPrice);
		uint8 lastGiftType = 0;

		for (uint8 i = 0; i < giftsCount; i++) {
			lastGiftType = _getGiftType();
			_createGift(msg.sender, to, lastGiftType);
		}

		if (ref != address(0)) {
			if (refAddresses[msg.sender] == address(0)) {
				refAddresses[msg.sender] = ref;
				_createGift(msg.sender, ref, lastGiftType);
			}
		}

		// forward funds
		wallet.transfer(giftsPrice);

		if (giftWei > 0) {
			to.transfer(giftWei);
		}
	}

	function craftGift(uint8 collectionIndex, uint[] tokenIds) public {
		Collection storage c = _giftsCollection[collectionIndex];
		require(tokenIds.length == c.requiredTypes.length);

		for (uint8 i = 0; i < tokenIds.length; i++) {
			uint tokenId = tokenIds[i];
			assert(tokenOwner[tokenId] == msg.sender);
			assert(!tokenUsed[tokenId]);
			assert(tokenType[tokenId] == c.requiredTypes[i]);

			tokenUsed[tokenIds[i]] = true;
		}

		_createGift(address(0), msg.sender, c.rewardType);
	}

	function getTokenImage(uint tokenId) public constant returns (string image) {
		uint8 giftType = tokenType[tokenId];
		return tokenTypeImage[giftType];
	}

	function setGiftPrice(uint256 price) public onlyOwner {
		giftPriceWei = price;
	}

	function setGiftTypesRarity(uint8[] giftsTypesRarity) public onlyOwner {
		require(_giftsTypesRarity.length == 0);
		_giftsTypesRarity = giftsTypesRarity;
	}

	function addGiftCollection(uint8 rewardType, uint8[] requiredTypes) public onlyOwner {
		_giftsCollection.push(Collection(rewardType, requiredTypes));
	}

	function setTokenTypeImage(uint8 giftType, string image) public onlyOwner {
		tokenTypeImage[giftType] = image;
	}

	function createFounderGift(address to, uint8 giftsCount) public onlyOwner {
		for (uint8 i = 0; i < giftsCount; i++) {
			assert(_founderTokensAmount <= _founderTokensMax);

			isFounderToken[nextGiftIndexToAssign] = true;
			_createGift(address(0), to, _getGiftType());
			_founderTokensAmount++;
		}
	}

	function setEndTime(uint _endTime) public onlyOwner {
		endTime = _endTime;
	}

	function _createGift(address from, address to, uint8 giftType) internal {
		uint tokenId = nextGiftIndexToAssign;
		nextGiftIndexToAssign = nextGiftIndexToAssign.add(1);
		totalTokens = totalTokens.add(1);

		_addTokenTo(to, tokenId);
		tokenType[tokenId] = giftType;

		GiftCreated(from, to, tokenId);
	}

	function _randomGen(uint min, uint max) internal constant returns (uint randomNumber) {
		return min + uint(keccak256(block.blockhash(block.number - 1), nextGiftIndexToAssign)) % (max - min);
	}

	function _getGiftType() internal returns (uint8 randomNumber){
		uint n = _giftsTypesRarity.length;
		uint rnd = _randomGen(0, n);

		return _giftsTypesRarity[rnd];
	}
}
