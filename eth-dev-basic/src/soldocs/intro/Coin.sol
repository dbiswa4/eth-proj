pragma solidity ^0.4.0;


contract Coin {

    /**
    The address type is a 160-bit value that does not allow any arithmetic operations.
    It is suitable for storing addresses of contracts or keypairs belonging to external persons.

    The keyword public automatically generates a function that allows you to access the current value of the state
    variable. Without this keyword, other contracts have no way to access the variable.
    You can add a function like this below:

    function minter() returns (address) { return minter; }

    But, adding a function exactly like that will not work because we would have a function and a state variable with
    the same name - compiler will throw an error.
    */
    address public minter;

    /**
    Mappings can be seen as hash tables.
    But, it is neither possible to obtain a list of all keys of a mapping, nor a list of all values.
    So either keep in mind (or better, keep a list or use a more advanced data type) what you added to the
    mapping or use it in a context where this is not needed.

    The getter function created by the public keyword looks like this.
    function balances(address _account) returns (uint) {
        return balances[_account];
    }
    */
    mapping (address => uint) public balances;

    /**
    Events allow light clients to react on changes efficiently.

    User interfaces (as well as server applications of course) can listen for those events being fired on the
    blockchain without much cost.

    As soon as it is fired, the listener will also receive the arguments from, to and amount, which makes it easy to
    track transactions.

    In order to listen for this event, you would use:
    Coin.Sent().watch({}, '', function(error, result) {
        if (!error) {
            console.log("Coin transfer: " + result.args.amount +
                " coins were sent from " + result.args.from +
                " to " + result.args.to + ".");
            console.log("Balances now:\n" +
                "Sender: " + Coin.balances.call(result.args.from) +
                "Receiver: " + Coin.balances.call(result.args.to));
        }
    })

    * Note how the automatically generated function balances is called from the user interface.
    */
    event Sent(address from, address to, uint amount);

    /**
    This is the constructor whose code is run only when the contract is created and cannot be called afterwards
    *Following part is very important
    It permanently stores the address of the person creating the contract:
    msg (together with tx and block) is a magic global variable that contains some properties.
    msg.sender is always the address where the current (external) function call came from.
    */

    function Coin() {
        minter = msg.sender;
    }

    function mint(address receiver, uint amount){
        if (msg.sender != minter) return;
        balances[receiver] += amount;
    }

    function send(address receiver, uint amount){
        //anyone (who already has some of these coins) to send coins to anyone else
        if (balances[msg.sender] < amount) return;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        /**
        Note that if you use this contract to send coins to an address, you will not see anything when you look at
        that address on a blockchain explorer, because the fact that you sent coins and the changed balances are
        only stored in the data storage of this particular coin contract. By the use of events it is relatively
        easy to create a “blockchain explorer” that tracks transactions and balances of your new coin.
        */
        Sent(msg.sender, receiver, amount);
    }

}
