// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {ERC721TokenReceiver} from "solmate/tokens/ERC721.sol";
import {ERC1155TokenReceiver} from "solmate/tokens/ERC1155.sol";

struct NFTStruct {
    address tokenContract;
    uint256[] tokenId;
}

contract SimpleSwap is ERC721TokenReceiver, ERC1155TokenReceiver {
    uint256 public swapCount;

    event SwapCreated(
        address indexed _creator,
        uint256 indexed _time,
        SwapStatus indexed _status,
        uint256 _swapId,
        address _counterPart
    );

    enum SwapStatus {
        Open,
        Closed,
        Cancelled
    }

    struct Swap {
        uint256 id;
        address payable addressOne;
        uint256 valueOne;
        address payable addressTwo;
        uint256 valueTwo;
        uint256 swapCreated;
        SwapStatus status;
    }

    mapping(address => Swap[]) public swaps;
    mapping(uint256 => NFTStruct[]) public offeredNFT;
    mapping(uint256 => NFTStruct[]) public counterPartyNFT;

    function getSwaps(address userAddress)
        external
        view
        returns (Swap[] memory)
    {
        return swaps[userAddress];
    }

    function getOfferedNFT(uint256 id)
        external
        view
        returns (NFTStruct[] memory)
    {
        return offeredNFT[id];
    }

    function getCounterPartyNFT(uint256 id)
        external
        view
        returns (NFTStruct[] memory)
    {
        return counterPartyNFT[id];
    }

    function createSwap(
        address counterParty,
        uint256 counterPartyEtherValue,
        NFTStruct[] memory _offeredNFT,
        NFTStruct[] memory _counterPartyNFT
    ) external payable {
        address addressOne = msg.sender;
        address addressTwo = counterParty;

        uint256 swapId = swapCount;
        uint256 offeredNFTLength = _offeredNFT.length;
        uint256 counterPartyNFTLength = _counterPartyNFT.length;

        Swap memory swap = Swap(
            swapId,
            payable(addressOne),
            msg.value,
            payable(addressTwo),
            counterPartyEtherValue,
            block.timestamp,
            SwapStatus.Open
        );

        swaps[msg.sender].push(swap);
        swaps[counterParty].push(swap);

        for (uint256 index = 0; index < offeredNFTLength; index++) {
            offeredNFT[swapId].push(_offeredNFT[index]);
        }

        for (uint256 index = 0; index < counterPartyNFTLength; index++) {
            counterPartyNFT[swapId].push(_counterPartyNFT[index]);
        }

        unchecked {
            swapCount++;
        }

        emit SwapCreated(
            addressOne,
            block.timestamp,
            SwapStatus.Open,
            swapId,
            addressTwo
        );
    }

    //Interface IERC721/IERC1155
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external override returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata id,
        uint256[] calldata value,
        bytes calldata data
    ) external override returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            );
    }

    function supportsInterface(bytes4 interfaceID)
        public
        view
        virtual
        returns (bool)
    {
        return interfaceID == 0x01ffc9a7 || interfaceID == 0x4e2312e0;
    }
}
