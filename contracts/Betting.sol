//SPDX-License-Identifier: GPL:-3.0 
pragma solidity ^0.5.0;

contract Betting {
    address payable owner;
    uint minWager = 1;
    uint totalWager = 0;
    uint numberOfWagers = 0;
    uint constant MAX_NUMBER_OF_WAGERS = 2;
    uint winningNumber = 999;
    uint constant MAX_WINNING_NUMBER = 3;
    address payable [] playerAddresses;
    mapping (address => bool) playerAddressesMapping;
    struct Player {
        uint amountWagered;
        uint numberWagered;
    }
    mapping (address => Player) playerDetails;
    
    //Event to announce the winning number
    event WinningNumber ( uint number);

    //Event to display the status of the game
    event status (uint players, uint maxPlayers);    





    //Constructor for the contract
    constructor(uint _minWager) public {
        owner = msg.sender;
        if(_minWager > 0) minWager = _minWager;
    }
    
    
    function bet(uint number) public payable {
        //Check if the player has already bet
        require (playerAddressesMapping[msg.sender]==false);
        //Check the betting number to see that it falls within the required range
        require(number >= 1 && number <= MAX_WINNING_NUMBER);
        //Need to check that the amount betted is the least required
        require ((msg.value/(1 ether)) >=  minWager);
        
        //Record the number and amount wagered by the player
        playerDetails[msg.sender].amountWagered = msg.value;
        playerDetails[msg.sender].numberWagered = number;
        
        //Add the player to the array of those who've already bet
        playerAddresses.push(msg.sender);
        playerAddressesMapping[msg.sender] = true;
        
        //Increment the number of wagers and the amount wagered 
        numberOfWagers++;
        totalWager += msg.value;
        
        //Check if the required number of players has been met 
        if(numberOfWagers >= MAX_NUMBER_OF_WAGERS) {
            announceWinners();
            
            //start a new game
            //Delete all the player addresses mappings
            removeAllPlayersFromMapping();
            
            //Delete the player addresses
            delete playerAddresses;
            
            //reset the variables
            totalWager = 0;
            numberOfWagers = 0;
            winningNumber = 999;
            
        }
        
        //Emit the event to inform the client about the status of the game
        emit status(numberOfWagers, MAX_NUMBER_OF_WAGERS);


    }  
    
    
    //Remove players from mappings
    function removeAllPlayersFromMapping() private {
        for (uint i = 0; i  < playerAddresses.length; i++){
            delete playerAddressesMapping[playerAddresses[i]];
        }
    }
        
        //Draws a random number and calculate the winnings
        function announceWinners() private {
         // winningNumber = uint (keccak256(abi.encodePacked(block.timestamp))) % MAX_WINNING_NUMBER + 1; 
          winningNumber = 1;

          //Emit the event to announce the winning number
          emit WinningNumber(winningNumber);


          //Create an array to store all the winners
          address payable [MAX_NUMBER_OF_WAGERS] memory winners;
          
          uint winnersCount = 0;
          uint totalWinningWager = 0;
          
          //Iterate all the players to check if they've won
          for (uint i = 0; i < playerAddresses.length; i++) {
              address payable playerAddress = playerAddresses[i];
              
              if(playerDetails[playerAddress].numberWagered == winningNumber){
                  //Save the player into the winners array
                  winners[winnersCount] = playerAddress;
                  
                  //Sum up the total wagered amount for the winning numbers 
                  totalWinningWager += playerDetails[playerAddress].amountWagered;
                  winnersCount++;
              }
          }
          
          //Make payments to each wiing player
          for (uint j = 0; j < winnersCount; j++){
              winners[j].transfer((playerDetails[winners[j]].amountWagered/totalWinningWager) * totalWager);
              
          }
          
          //If there's no winner transfer all the ether to the owner if the contract
          if(winnersCount == 0) {
              owner.transfer(address(this).balance);
          }
          
          
          
        }
        
        
    
        
    //Getting the winning number 
    function getWinningNumber() public view returns (uint){
        return winningNumber;
    }
    
    
    //Destruct function
    function kill() public {
        if(msg.sender == owner){
            selfdestruct(owner);
        }
    }
    
    function getStatus() public view returns (uint, uint) {
        return (numberOfWagers, MAX_NUMBER_OF_WAGERS);
    }
     
}