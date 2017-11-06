pragma solidity ^0.4.0;


/**
* Ref:
* https://github.com/acloudfan/Blockchain-Course-Patterns/blob/master/contracts/ContractFactory.sol
*
* A solidity contract file can have multiple contracts. Unlike Java, it does not need to be subcontracts
*
* A Contract can create other contracts
* ChildContract represents an asset such as car, diamond, land-deed etc
*/

//This contract represents the identifier for some kind of asset
contract ChildContract {

    //These attributes gets initialized as part of the constructor
    //Identiry of the asset
    uint8 public identity;
    //Owner address of the asset
    address public owner;
    //Name of the asset owner
    bytes32 public name;

    //Modifiers
    //modifier OwnerOnly {if(msg.sender != owner ) throw; else _;}
    modifier OwnerOnly {if(msg.sender != owner ) revert(); else _;}
    event ChildOwnerTransfered(uint8 identity, bytes32 from, bytes32 to);

    //Constructor
    function ChildContract(uint8 id, address own, bytes32 nm){
        identity = id;
        owner = own;
        name = nm;
    }

    //Transfer Ownership function
    function transferOwnership(address newOwner, bytes32 nm) OwnerOnly {
        bytes32 former = name;
        owner = newOwner;
        name = nm;
        ChildOwnerTransfered(identity, former, name);
    }

    //Checks if caller is the owner
    function isOwner(address addr) returns(bool) {
        return (addr == owner);
    }

}

/**
* This contract creates multiple contracts
*/
contract ContractFactory {

    //Maintain all child contracts
    ChildContract[] children;

    //Price of the asset
    //Note:
    //This is a a very bad example. Why this variable is at ContractFactory level?
    //Each asset can have different price. The price should have been in ChildContract.
    uint public initialPrice;

    //Constructor
    //Creates the child contracts
    function ContractFactory(uint8 numParts, uint8 price) {
        for(uint8 i=0; i < numParts; i++){
            //this passes the address of this contract, which is stored in child contract as owner address
            children.push(new ChildContract(i, this, "***"));
        }
        initialPrice = price;
    }

    /**
    * The confusing part here is msg. We do not see any method with the new owner address and how much he is willing
    * to pay for it. The new owner address is the sender of the message. And we get the sender's address from msg
    * variable.
    * purchase() method takes the asset owner name as argument. However, looks like the value sender is willing to pay is
    * taken from msg. Why it could not be passed to the method directly just like asset owner 'name'?
    *
    * payable methods can receive ether.
    **/
    // Anyone can pay the price and purchase the asset
    function purchase(bytes32 name) payable {
        //asset value the sender is willing to pay.
        if(msg.value < initialPrice){
            revert();
        }
        //Look for available asset i.e., one that is not sold yet
        for(uint8 i=0; i< children.length; i++){
            if(children[i].isOwner(this)){
                //transferOwnership() args : new owner address and asset name
                children[i].transferOwnership(msg.sender, name);
                return;
            }
        }

        // No more assets available - so throw an exception
        /**
        * may be we should just return a nicer message saying asset is not available
        **/
        /**throw**/
        revert();
    }

    //Returns the information about the child contract at specified index
    /**
    * Q.
    * Why do I need () after the varaible names?
    * Ans:
    * If I don't give (), it returns below error. So () invokes some invisible getter?
    *
    * Return argument type tuple(function () constant external returns (uint8),address,bytes32) is not implicitly
    * convertible to expected type tuple(uint8,address,bytes32).
    **/
    function getInfo(uint8 childIndex) constant returns(uint8, address, bytes32){
        return (children[childIndex].identity(), children[childIndex].owner(), children[childIndex].name());
    }

    // Returns the child contract address
    function getChildContractAddress(uint8 childIndex) returns(address){
        //Q
        //Really? Can you get the address of the child contract like that? How?
        return address(children[childIndex]);
    }

    // Returns name of the owner based on the child index
    function  getOwnerName(uint8 childIndex) constant returns(bytes32){
        /**
        * Q.
        * If the var name was name, would it have created any problem?
        * Q.
        * Why do I need () after the varaible name?
        **/
        bytes32  namer = children[childIndex].name();
        return namer;
    }

      // Returns the count of the children
    function  getChildrenCount() constant returns (uint){
        return children.length;
  }
}




