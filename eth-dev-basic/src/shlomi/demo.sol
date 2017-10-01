pragma solidity ^0.4.0;


/**
Basically, the flow was like this.
1. Deploy each contract everytime you update the code i.e. Deploy User and Provider contract.
2. While deploying you can give it a name. This is for convininece purpose.
3. Now get the address of Provider contract. Address indictaes where the contract is deployed to.
4. From User contract using registerToProvide() method, sign up for the provider
5. Now get the address of the user contract.
6. Using the provider method, set the debt

*/

contract mortal {

    address public owner;

    function mortal() {
        //msg is a predefined variable
        owner = msg.sender;
    }

    modifier onlyOwner{
        if(msg.sender != owner){
            revert();
        } else {
            //This will be replaced by the function we want it to execute
            _;
        }
    }
    //onlyOwner() will be able to execute this function
    function kill() onlyOwner{
        //suicide() function takes one argument
        //If the mortal contract has some eth, it will be send to it's owner
        suicide(owner);
    }

}


contract User is mortal {

    //useName can be set to any arbitrary string.
    //So, will we be deploying one new contract everytime for each new customer?

    string public userName;

    //Each Provider will be a contract, hence each Provider contract will have a address
    //We need a way to name those services
    //It makes sense to map those address into our service
    //It allows me to look for a service by the address, which is a provider address
    mapping(address => Service) public services;

    //A user may have servies from multiple provider
    struct Service{
        bool active;
        uint lastUpdate;
        uint256 debt;
    }

    function User(string _name) {
        userName = _name;
    }

    //A function to allow register to a service
    //To register to a service we only need to give a provider address
    //Since Mortal contract has modifier onlyOwner and I wanted to make sure only the owner of User contract will be
    //able to use the below function, we are going to add onlyOwner modifier
    function registerToProvider(address _providerAddress) onlyOwner {
        services[_providerAddress] = Service( {
            active: true,
            lastUpdate: now,
            debt : 0
            });
    }


    //People need to pay the bill to service provider. For that first service provider needs to communicate/set the
    //debt ammount
    //Need to have two type of arguments
    //Address of the service provider and debt
    //If we allow user to interact with setDebt(), then they can change the debt from let's say 10 to 2 and pay just 2
    //We want only the provider to set a new debt and remove the privilege from user itself. How do we do it?
    //
    //Since Provider contract can now directly interact with User contract (see the explanation in Provider contract),
    //we will remove _providerAddress argument from this method signature. Instead, we can say that look for the sender
    //address.
    //
    function setDebt(uint _debt) {
        //The if condition checks whether the user is signed up for this provider or not
        if(services[msg.sender].active){
        services[msg.sender].lastUpdate = now;
        services[msg.sender].debt = _debt;
        } else {
        revert();
        }

    }

}

contract Provider is mortal {

    string public providerName;
    string public description;

    function Provider(string _name, string _description) {
        providerName = _name;
        description = _description;
    }

    //Provider will specifically set the debt for a specific User address of a specific user contract
    //onlyOwner is added so that only Provider contract can use this method
    function setDebt(uint256 _debt, address _userAddress) onlyOwner{

        //Create a new object of type User Contract
        //This person is a user contract of following address
        //Declaring a new type of object User. This User object refers to User contract above. The var name is person.
        //It will get all the functionality of User contract which is deployed in _userAddress address
        //Now, Provider contract can directly interact with User contract which is on _userAddress address
        //It can do so using the person object
        User person = new User(_userAddress);
        person.setDebt(_debt);


    }
}










