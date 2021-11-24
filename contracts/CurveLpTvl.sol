pragma solidity ^0.5.16;
import "./Math.sol";
import "./SafeMath.sol";
import "./IERC20.sol";
import "./Halt.sol";


interface IFarm {
    function poolLength() external view returns (uint256);
    function getPoolInfo(uint256 _pid) external view returns (
        address lpToken,         // Address of LP token contract.
        uint256 currentSupply,    //
        uint256 bonusStartBlock,  //
        uint256 newStartBlock,    //
        uint256 bonusEndBlock,    // Block number when bonus defrost period ends.
        uint256 lastRewardBlock,  // Last block number that defrost distribution occurs.
        uint256 accRewardPerShare,// Accumulated defrost per share, times 1e12. See below.
        uint256 rewardPerBlock,   // defrost tokens created per block.
        uint256 totalDebtReward);
}

interface IOracle {
    function getPrice(address asset) external view returns (uint256);
}

contract CurveLpFarmTvl {
    using SafeMath for uint256;
    address public curveLpFarmAddress;

    uint256 constant TLVMUL = 10**2;

    constructor(address _curveLpFarmAddress) public {
        curveLpFarmAddress = _curveLpFarmAddress;
    }

    function getPriceTokenDecimal(address token) internal view returns(uint256){
        return (10**IERC20(token).decimals());
    }

    function getTvl()
        public
        view
        returns (uint256)
    {
        uint256 tvl = 0;
        uint256 poolLen = IFarm(curveLpFarmAddress).poolLength();
        for(uint256 i=0;i<poolLen;i++) {
            uint256 lpAmount = 0;
            address lpToken;
            (lpToken,lpAmount,,,,,,,)= IFarm(curveLpFarmAddress).getPoolInfo(i);
            uint256 decimal = getPriceTokenDecimal(lpToken);
            tvl = tvl.add(lpAmount.mul(TLVMUL).div(decimal));
        }

        return tvl;
    }

}
