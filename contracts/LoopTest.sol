// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";

contract LoopTest {
    mapping(address => uint256) map1;
    mapping(address => uint256) map2;

    address[] public players;

    uint256 public counter;
    bool public flag;

    uint256 public number;

    constructor() {
        counter = 0;
    }

    function store() public {
        map1[msg.sender] = counter;
        players.push(msg.sender);

        counter += 1;
    }

    function bigLoop(uint256 _start, uint256 _stop) public {
        flag = false;
        for (uint256 i = _start; i <= _stop; i++) {
            uint256 _tmp = map1[players[i]];
            //_tmp = _tmp * 130 / 100;
            map2[players[i]] = _tmp;

            console.log(i);
        }
        flag = true;
    }

    function singleCall(uint256 _index) public {
        uint256 _tmp = map1[players[_index]];
        //_tmp = _tmp * 130 / 100;
        map2[players[_index]] = _tmp;
    }

    function noGasLoop(uint256 _n) public view returns (uint256) {
        for (uint256 i = 0; i < 5000; i++) {
            _n += 1;
        }

        return _n;
    }

    function stateChange(uint256 _n) public {
        uint256 _tmp = noGasLoop(_n);
        number = _tmp;
    }
}
