pragma solidity ^0.4.8;


contract Victim {
    function withdraw() {
        uint transferAmt = 1 ether;

        //causing the vulnerability
        //msg.sender is executing the entire attacker contract. Since we did not provide any specific function
        //it will call the fallback function in attacker contract
        if (!msg.sender.call.value(transferAmt) ()) throw;

    }

    function deposit() payable{

    }
}
