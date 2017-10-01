pragma solidity ^0.4.0;


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


}

contract Provider is mortal {

    string public providerName;
    string public description;

    function Provider(string _name, string _description) {
        providerName = _name;
        description = _description;
    }
}










