//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

interface tokenRecipient {
    function receiveApproval(
        address _from,
        uint256 _value,
        address _token,
        bytes calldata _extraData
    ) external;
}

contract manualToken {
    // public variables of the token
    string public name;
    string public symbol;
    uint256 public _totalSupply;
    uint8 public decimals = 18; // 18 decimals is the actual default standard

    //these creates array of all balances
    mapping(address => uint256) public _balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    //this generates a public event on the blockchain that will notify clients of a transfer of money from _from to _to
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    //this generates a public event on the blockchain that will notify clients of a approval of spending  money from _owner to _spender
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
    //this generates a public event on the blockchain that will notify clients of the burnt of _value from the total supply
    event Burn(uint256 _value);

    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint256 token_totalSupply
    ) {
        name = tokenName; //name of the token for display purposes
        symbol = tokenSymbol; //symbol of the token for display purposes
        _totalSupply = token_totalSupply * 10 ** uint(decimals); //update token_totalSupply with the decimal amount
        _balanceOf[msg.sender] = _totalSupply; //all the token supply given to the first developer(creator) of the contract
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint256 _value) internal {
        //prevent transfer from a null address
        require(_to != address(0x0));
        //check that the sender has enough
        require(_balanceOf[_from] >= _value);
        //check for overflow
        require(_balanceOf[_to] + _value >= _balanceOf[_to]);
        //variable created for a future assert
        uint256 previous_balanceOf = _balanceOf[_to] + _balanceOf[_from];
        //update the balance of the sender
        _balanceOf[_from] -= _value;
        //update the balance of the receiver
        _balanceOf[_to] += _value;
        //the amount in the _balanceOf before and after the transaction must be equal. It is used to find bugs in the code
        assert(_balanceOf[_from] + _balanceOf[_to] == previous_balanceOf);
        //if nothing fails emit the event that notify about the transaction in the blockchain
        emit Transfer(_from, _to, _value);
    }

    /**
     *
     * TRANSFER TOKENS
     *
     * function that "send" the value amount of token to a recipient("to") from your account
     *
     * @param to  address of the recipient
     * @param value amount to transfer
     */
    function transfer(address to, uint256 value) public returns (bool success) {
        _transfer(msg.sender, to, value);
        return (true);
    }

    /**
     *
     *  TRANSFER TOKENS FROM OTHER ADDRESS
     *
     * function that "send" the value amount of token to a recipient("to") from "_from" account
     *
     * @param _from address of the sender
     * @param _to address of the recipient
     * @param _value amount to transfer
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        //check the allowance of the sender
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * SET ALLOWANCE FOR OTHER ADDRESS
     *
     * Allow the "_spender" to spend no more than "_value" amount of tokens on your behalf
     * @param _spender the address authorized to spend
     * @param _value the amount the _spender is authorized to spend
     */
    function approve(
        address _spender,
        uint256 _value
    ) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * SET ALLOWANCE FOR OTHER ADDRESS AND NOTIFY
     *
     * Allow the "_spender" to spend no more than "_value" amount of tokens on your behalf, then notify the contract about the transaction
     * @param _spender the address authorized to spend
     * @param _value the amount the _spender is authorized to spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(
        address _spender,
        uint256 _value,
        bytes memory _extraData
    ) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(
                msg.sender,
                _value,
                address(this),
                _extraData
            );
            return true;
        }
    }

    /**
     * DESTROY TOKENS
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(_balanceOf[msg.sender] >= _value);
        _balanceOf[msg.sender] -= _value;
        _totalSupply -= _value;
        emit Burn(_value);
        return true;
    }

    /**
     * DESTROY TOKENS FROM OTHER ACCOUNT
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(
        address _from,
        uint256 _value
    ) public returns (bool success) {
        require(_balanceOf[_from] >= _value);
        require(allowance[_from][msg.sender] >= _value);
        _balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        _totalSupply -= _value;
        emit Burn(_value);
        return true;
    }

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public view returns (uint256) {
        return _balanceOf[owner];
    }
}
