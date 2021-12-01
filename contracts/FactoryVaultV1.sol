pragma solidity ^0.5.16;
import "./Math.sol";
import "./SafeMath.sol";
import "./IERC20.sol";
import "./Halt.sol";

interface IFactory {
    function getAllVaults()external view returns (address[] memory);
}

interface IVault {
    function collateralToken() external view returns (address);
    function getOracleAddress() external view returns(address);
    function totalAssetAmount() external view returns(uint256);
}

interface IOracle {
    function getPrice(address asset) external view returns (uint256);
}

contract FactoryVaultV1Tvl {
    using SafeMath for uint256;
    address public factoryAddress;

    uint256 constant TLVMUL = 10**2;

    constructor(address _factoryAddress) public {
        factoryAddress = _factoryAddress;
    }

    //oracle 的 位数是 36-token decimals
    //token amount * price = 36 decimals
    function getTvl()
    public
    view
    returns (uint256)
    {
        uint256 tvl = 0;
        address[] memory allVaults = IFactory(factoryAddress).getAllVaults();
        for(uint256 i=0;i<allVaults.length;i++) {
            address colToken = IVault(allVaults[i]).collateralToken();
            address oracleAddress = IVault(allVaults[i]).getOracleAddress();
            uint256 colPrice = IOracle(oracleAddress).getPrice(colToken);
            uint256 decimal = 1e18;
            uint256 totalcol = 0;
            if(colToken==address(0)) {
                totalcol = allVaults[i].balance;
            } else {
                decimal = getPriceTokenDecimal(colToken);
                totalcol = IERC20(colToken).balanceOf(allVaults[i]);                
            }
            uint256 priceDecimal = uint256(10**36).div(decimal);
            tvl = tvl.add(totalcol.mul(colPrice).mul(TLVMUL).div(decimal).div(priceDecimal));
        }
		
		return tvl;
    }

}
