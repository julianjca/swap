// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {ERC721TokenReceiver} from "solmate/tokens/ERC721.sol";
import {ERC1155TokenReceiver} from "solmate/tokens/ERC1155.sol";

contract SimpleSwap is ERC721TokenReceiver, ERC1155TokenReceiver {
    enum SwapStatus {
        Opened,
        Closed,
        Cancelled
    }

    struct NFTStruct {
        address tokenContract;
        uint256[] tokenId;
    }

    struct Swap {
        uint256 id;
        address payable addressOne;
        NFTStruct[] nftOne;
        uint256 valueOne;
        address payable addressTwo;
        uint256 valueTwo;
        NFTStruct[] nftTwo;
        uint256 swapCreated;
        SwapStatus status;
    }

    mapping(address => Swap[]) public swaps;

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
