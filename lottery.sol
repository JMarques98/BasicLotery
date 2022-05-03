// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract Lottery  {

    enum Estado { Activo, Finalizado } //States that will exist in the lottery 
    
    address payable[] private participantes; //Lottery participants
    Estado public estado; 
    address payable private ganador;

    uint public currentTime = block.timestamp;

    constructor()  {
        estado = Estado.Activo;
    }
    
    function participar() public payable {
        require(msg.value == 0.01 ether, "Cantidad participacion incorrecta debe ser 0.01 ether"); //the share must send exactly 0.01 ethers
        require(estado == Estado.Activo, "loteria ya finalizada"); //must be active


        uint participaciones = msg.value / 0.01 ether; 
        for ( uint i = 1; i<=participaciones; i++){
          participantes.push(payable(msg.sender));

        }

       
        if(block.timestamp >= currentTime + 5 minutes){
            
            estado = Estado.Finalizado;

        }
    }
    
    receive() external payable {  //call with empty call data (transfer without data)
        participar();
    }
    fallback() external payable {   
        participar();
    }
    
    function finalizarLoteria()  public {
        
        require(estado == Estado.Finalizado); //should be finished already after 5 minutes
                
        uint idGanador = random() % participantes.length;
        ganador = participantes[idGanador];
        
        enviarPremio();
    }
    
    //function random() public view returns (uint) {
    function random() private view returns (uint) {
        //return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty,participantes.length)));
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty,participantes.length, gasleft())));
    }
    function get_balance() public view returns(uint){
        //require(msg.sender == administrador);
        return address(this).balance; //devuelve balance del contrato
    }
    function enviarPremio() private {
        require(ganador != address(0));
        
        ganador.transfer(address(this).balance); //If it fails it gives an error, but if I had put a .send and it failed it would return a false. 
    }
    
    function getGanador() public view returns (address payable) {
         require(estado == Estado.Finalizado, "loteria no finalizada"); //debe estar Finalizado
         return ganador;
    }
}
