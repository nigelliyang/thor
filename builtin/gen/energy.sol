// Copyright (c) 2018 The VeChainThor developers
 
// Distributed under the GNU Lesser General Public License v3.0 software license, see the accompanying
// file LICENSE or <https://www.gnu.org/licenses/lgpl-3.0.html>

pragma solidity 0.4.24;
import "./token.sol";

/// @title Energy an token that represents fuel for VET.
contract Energy is Token {
    mapping(address => mapping (address => uint256)) allowed;

    ///@return ERC20 token name
    function name() public pure returns (string) {
        return "VeThor";
    }

    ///@return ERC20 token decimals
    function decimals() public pure returns (uint8) {
        return 18;    
    }

    ///@return ERC20 token symbol
    function symbol() public pure returns (string) {
        return "VTHO";
    }

    ///@return ERC20 token total supply
    function totalSupply() public view returns (uint256) {
        return EnergyNative(this).native_totalSupply();
    }

    function totalBurned() public view returns(uint256) {
        return EnergyNative(this).native_totalBurned();
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return EnergyNative(this).native_get(_owner);
    }

    function transfer(address _to, uint256 _amount) public returns (bool success) {
        _transfer(msg.sender, _to, _amount);
        return true;
    }

    function move(address _from, address _to, uint256 _amount) public returns (bool success) {
        require(_from == msg.sender || EnergyNative(this).native_master(_from) == msg.sender, "builtin: self or master required");
        _transfer(_from, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns(bool success) {
        require(allowed[_from][_to] >= _amount, "builtin: insufficient allowance");
        allowed[_from][_to] -= _amount;

        _transfer(_from, _to, _amount);
        return true;
    }

    function allowance(address _owner, address _spender)  public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function approve(address _spender, uint256 _value) public returns (bool success){
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _amount) internal {
        if (_amount > 0) {
            require(EnergyNative(this).native_sub(_from, _amount), "builtin: insufficient balance");
            // believed that will never overflow
            EnergyNative(this).native_add(_to, _amount);
        }
        emit Transfer(_from, _to, _amount);
    }
}

contract EnergyNative {
    function native_totalSupply() public view returns(uint256);
    function native_totalBurned() public view returns(uint256);
    
    function native_get(address addr) public view returns(uint256);
    function native_add(address addr, uint256 amount) public;
    function native_sub(address addr, uint256 amount) public returns(bool);

    function native_master(address addr) public view returns(address);
}