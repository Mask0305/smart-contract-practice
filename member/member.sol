// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.14;

// Target
// 新增會員
// 會員資料含(name,age,email)
// 更新會員
// 刪除會員
// 只有自己可以更新自己的資料
// 取得所有會員
// 取得特定會員
// 若會員不存在報錯
// owner為第一個會員
 
 contract MEMBER {
     // member
     struct member {
        // 姓名
        string name;
        // 年齡
        uint8 age;
        // e-mail
        string email;
     }

    uint userId;

    // address to id
    mapping(address => uint) memberAddress;
     // id to address
    mapping(uint => member) memberList;
 

     
     // 第一位會員是合約擁有者
     // constructor會在合約一部署完成就執行
     constructor(string memory name,uint8 age, string memory email)  {
         userId ++;
         memberAddress[msg.sender] = userId;
         memberList[userId] = member({
             name:name,
             age:age,
             email:email
         });

         
     }


    // 地址必須存在
     modifier addressMustExist(address addr){
        // 當此地址沒有userId
        require(memberAddress[addr] != 0, "this address is not exist"); 
        _;
     }

     // 地址必須不存在
     modifier addressMustNotExist(address addr){
        // 當此地址有userId
        require(memberAddress[addr] == 0, "this address is exist"); 
        _;
     }

    // 建立會員
     function create(string memory name, uint8 age, string memory email) public addressMustNotExist(msg.sender) returns(bool success) {

        // 賦予此地址userId
        userId ++ ; 
        memberAddress[msg.sender] = userId ;
        // 放入會員資料
        memberList[userId] = member({
                    name:name,
                    age:age,
                    email:email
                });
        return true;
     }
     
     // 刪除會員
     function deleteMember() public addressMustExist(msg.sender) returns(bool) {
         // delete賦予變量初始值，同時釋放空間，返回gas
         // 不可對storage的變數進行delete
         uint memberId;
         // 取得userId
         memberId = memberAddress[msg.sender];

        // 清除memberLsit
        delete memberList[memberId];
        // 清除memberAddress
        delete memberAddress[msg.sender];

         return true;
     }

     // 更新會員
     function update(string memory newName, uint8 newAge, string memory newEmail)public addressMustExist(msg.sender) returns(bool) {
            
            uint memberId;
            // 取得會員編號
            memberId = memberAddress[msg.sender];
            

            // 更新會員資訊
            memberList[memberId].name = newName;
            memberList[memberId].age = newAge;
            memberList[memberId].email =newEmail;

            return true;
     }



    // 取得所有會員的name
    function GetAllMember() public view  returns(string[] memory){
        // 與golang相同，須先宣告長度
        string[] memory result = new string[](userId);
        
        for (uint i = 0;i < userId; i++){
            result[i] =  memberList[i+1].name;
        }

        return result;
    }

    // 取得特定地址會員資料
    function GetMemberByAddress(address addr) public addressMustExist(addr)  view  returns(member memory) {
        // 取得memberId
        uint memberId = memberAddress[addr];

        return memberList[memberId];
    }

 }
