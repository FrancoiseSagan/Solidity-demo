// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract LuckyNumberGame {
    enum GameState { OPEN, CLOSED }
    GameState public currentState;
    
    address public owner;
    
    uint8 private luckyNumber;
    
    uint256 public constant GAME_FEE = 0.001 ether;
    
    uint256 public prizePool;
    
    event GuessMade(address indexed player, uint8 guessedNumber, bool won);
    
    event GameEnded(address winner, uint256 prize);
    
    constructor() {
        owner = msg.sender;
        currentState = GameState.OPEN;
        _generateLuckyNumber();
    }
    
    function _generateLuckyNumber() private {
        luckyNumber = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % 10) + 1;
    }
    
    function guessNumber(uint8 _number) external payable {
        require(currentState == GameState.OPEN, "Game is not open");
        require(_number >= 1 && _number <= 10, "Number must be between 1-10");
        require(msg.value == GAME_FEE, "Incorrect game fee");
        
        prizePool += msg.value;
        
        if (_number == luckyNumber) {
            // Yes!
            uint256 prize = prizePool;
            prizePool = 0;
            
            (bool sent, ) = msg.sender.call{value: prize}("");
            require(sent, "Failed to send prize");
            
            emit GuessMade(msg.sender, _number, true);
            emit GameEnded(msg.sender, prize);
            
            _generateLuckyNumber();
        } else {
            // Wrong!
            emit GuessMade(msg.sender, _number, false);
        }
    }
    
    // Close the game
    function closeGame() external {
        require(msg.sender == owner, "Only owner can close the game");
        currentState = GameState.CLOSED;
    }
    
    // Reopen the game
    function reopenGame() external {
        require(msg.sender == owner, "Only owner can reopen the game");
        currentState = GameState.OPEN;
        _generateLuckyNumber();
    }
    
    // Get Lucky Nuber
    function getLuckyNumber() external view returns (uint8) {
        require(msg.sender == owner, "Only owner can see the lucky number");
        return luckyNumber;
    }
    
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}