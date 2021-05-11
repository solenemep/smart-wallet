// SPDX-License-Identifier: MIT

// msg.sender (address): sender of the message (current call)

pragma solidity ^0.8.0;

contract SmartWallet {
    // Tous les comptes du SmartWallet : chaque adresse possède une balance
    mapping(address => uint256) private _balances;
    
    // Pour le constructeur
    address private _owner; 
    uint256 private _percent;
    
    // Variable d'état
    uint256 private _gain;
    
    constructor(address owner_, uint256 percent_) {
    // L'owner (adresse) et le pourcentage sont définis au moment du déploiement
    _owner = owner_;
    _percent = percent_;
    }
    
    // Seul l'owner peut modifier le pourcentage défini au déploiement
    function setPercent(uint256 percent_) public {
      require(msg.sender == _owner, "Counter: Only owner can set percent");
      _percent = percent_;
    }
    
    // Afficher les gains de l'owner
    function gain() public view returns (uint256) {
        return _gain;
    }
    
    // Afficher la balance du SmartWallet pour un compte donné
    function balanceOf(address account_) public view returns (uint256) {
        return _balances[account_];
    }

    // Déposer un montant dans le SmartWallet du compte de l'utilisateur (msg.sender) : augmenter sa balance
    function deposit() public payable {
        _balances[msg.sender] += msg.value;
    }
    
    // Transférer un montant vers un autre compte du SmartWallet
    function transfer(address account_, uint256 amount_) public {
        require(_balances[msg.sender] > amount_, "SmartWallet: can not send more than its balance");
        _balances[msg.sender] = _balances[msg.sender] - amount_;
        _balances[account_] = _balances[account_] + amount_;
    }
    
    // Transférer un montant du SmartWallet vers l'adresse de l'utilisateur du SmartWallet : soustraire le montant à la balance
    function withdrawAmount(uint256 amount_) public {
        require(_balances[msg.sender] > amount_, "SmartWallet: can not withdraw > amount");
        if (msg.sender != _owner) {
            uint256 gain_ = amount_ * (_percent / 100);
            _balances[msg.sender] = _balances[msg.sender] - amount_;
            _balances[_owner] = _balances[_owner] + gain_;
            _gain += gain_;
            payable(msg.sender).transfer(amount_ - gain_);
        }
        if (msg.sender == _owner) {
            _balances[msg.sender] = _balances[msg.sender] - amount_;
            _balances[_owner] = _balances[_owner];
            payable(msg.sender).transfer(amount_);
        }
    }
    
    // Transférer l'integralité du montant du SmartWallet vers l'adresse de l'utilisateur du SmartWallet : balance à 0
    function withdrawAll() public {
        require(_balances[msg.sender] > 0, "SmartWallet: can not withdraw = 0 ether");
        uint256 amount_ = _balances[msg.sender];
        if (msg.sender != _owner) {
            uint256 gain_ = amount_ * (_percent / 100);
            _balances[msg.sender] = 0;
            _balances[_owner] = _balances[_owner] + gain_;
            _gain += gain_;
            payable(msg.sender).transfer(amount_ - gain_);
        }
        if (msg.sender == _owner) {
            _balances[msg.sender] = 0;
            payable(msg.sender).transfer(amount_);
        }
    }
    
    // Afficher la balance totale du SmartWallet
    function total() public view returns (uint256) {
        return address(this).balance;
    }
    
}