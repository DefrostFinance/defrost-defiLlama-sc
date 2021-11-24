pragma solidity ^0.5.16;
import "./Math.sol";
import "./SafeMath.sol";
import "./Halt.sol";

interface ITvlPool {
    function getTvl() external view returns (uint256);
}

contract DefrostTotalTvl is Halt{
    using SafeMath for uint256;
    address[] public tvlscs;

    function addTvl(address tvlsc) public onlyOwner{
        tvlscs.push(tvlsc);
        ITvlPool(tvlsc).getTvl();
    }

    function removeTvl(address tvlsc) public onlyOwner{
        for(uint256 i=0;i<tvlscs.length;i++) {
            if(tvlscs[i] == tvlsc) {
               tvlscs[i] = address(0);
            }
        }
    }

    function getTvl()
        public
        view
        returns (uint256)
    {
        uint256 tvl = 0;
        for(uint256 i=0;i<tvlscs.length;i++) {
            if(tvlscs[i] != address (0)) {
              tvl = tvl.add(ITvlPool(tvlscs[i]).getTvl());
            }
        }
        return tvl;
    }

}
