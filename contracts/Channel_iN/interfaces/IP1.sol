// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

interface IP1 {
    struct PendingInfo {
        address user;
        // 1: 출금요청,
        // 2: 출금취소,
        // 3: 완료,
        // 4: 취소완료: 완료시 재예치 버튼 활성화
        uint8 pendingType;
        uint startTime;
        uint endTime;
        uint amount;
        // pending Id
        uint pendingId;
    }

    function update() external returns (uint);

    function diamond_P1_deposit(
        address _sender,
        uint _amount
    ) external returns (uint);

    function diamond_P1_reDposit(address _sender) external returns (uint);

    function diamond_P1_harvest(address _sender) external returns (uint);

    function diamond_P1_pendingReward(
        address _sender,
        uint _withdrawBlock
    ) external view returns (uint);

    function diamond_P1_addPower(
        address _sender,
        uint _aienId,
        uint _usePower
    ) external returns (uint);

    function diamond_P1_widthdraw(
        address _sender,
        uint _amount
    ) external returns (uint);

    function diamond_P1_widthdrawConfirm(
        address _sender,
        uint _pendingId
    ) external returns (uint);

    function diamond_P1_widthdrawCancel(
        address _sender,
        uint _pendingId
    ) external returns (uint);

    function diamond_P1_widthdrawCancelConfirm(
        address _sender,
        uint _pendingId
    ) external returns (uint);

    function diamond_P1_getPoolData() external view returns (uint, uint, uint);

    function diamond_P1_getUserData(
        address _sender
    ) external view returns (uint, uint, uint, uint, uint);

    function diamond_P1_getUnstakeData(
        address _sender
    ) external view returns (PendingInfo[] memory);


    function testDiamondCall() external view returns(address);
}
