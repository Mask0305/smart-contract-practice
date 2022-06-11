// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.14;

contract GuessNumber{
    /* Feature
    猜數字遊戲，玩法其實就跟終極密碼一樣，
    猜的數字只要沒有答對都會縮小數字範圍，
    比較不同的是猜數字的方式，
    每次猜數字都須支付1 finney,
    所以猜中的人可以拿到contract裡面所有參與者投入的錢
    */

    // 答案
    uint256 answer;
    // 上限
    uint256 public MaxRange;
    // 下限
    uint256 public MinRange;
    // 擁有者
    address owner;
    // 猜中事件
    event Winner(address indexed _winner, uint256 _answer);

    constructor () {
        // 產生數字
        genrate();
        // 設定合約擁有者
        owner = msg.sender;
        // 設定上下限
        MaxRange = 100;
        MinRange = 1;
    }

    // 檢查數字須在區間內
    modifier checkNum(uint num){
        require(num > MinRange,"you have to guess higher");
        require(num < MaxRange,"you have to guess lower");
        _;
    }
    // 檢查是否有投入適當的eth
    modifier checkValue() {
        require(msg.value == 1 * 10**15,"need more eth");
        _;

    }

    // 產生數字
    function genrate() private {
        answer = uint(sha256(abi.encodePacked(block.difficulty, block.timestamp))) % 100;
    }


    // 合約擁有者可以查看答案
    function giveMeAnswer() public view returns(uint){  
        require(msg.sender == owner,"you are not owner!");
        return answer; 
    }

    // 查看目前獎金總數
    function award() public view returns(uint){
        return address(this).balance;
    }


    // 猜數字
    function guess(uint num) public checkNum(num) checkValue() payable{

        // 猜的數字 > answer
        if (num > answer) {
           MaxRange = num;
           return;
        }
        
        // 猜的數字 < answer
        if (num < answer) {
            MinRange = num;
            return;
        }

        // 猜中
        if (num == answer) {
            winner(num);
        }

    }

    // 贏家可獲得所有獎金
    function winner(uint num) private {
        // 轉帳的語法
        payable(msg.sender).transfer(address(this).balance);
        // 重新開始
        restart();
   
        emit Winner(msg.sender,num);
    }

    // 重新開始
    function restart() private {
        // 產生數字
        genrate();
        
        // 設定上下限
        MaxRange = 100;
        MinRange = 1;
    }

}