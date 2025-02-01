import { useAccount } from "wagmi";
import { useEffect, useState } from "react";
import { ethers } from "ethers";
import { EchainManager } from "../constants";
import EchainManagerABI from "../abis/EchainManager.json";

const useCheckUserRole = () => {
  const { address, isConnected } = useAccount();
  const [isOrganizer, setIsOrganizer] = useState<boolean | null>(null);

  useEffect(() => {
    if (!isConnected || !address) {
      return;
    }
    const checkRole = async () => {
      try {
        const provider = new ethers.BrowserProvider(window.ethereum);
        const contract = new ethers.Contract(
          EchainManager,
          EchainManagerABI.abi,
          provider
        );
        const result = await contract.isOrganizer(address);
        setIsOrganizer(result);
      } catch (e) {
        console.error(e);
        setIsOrganizer(false);
      }
    };
    checkRole();
  }, [address, isConnected]);

  return isOrganizer;
};
export default useCheckUserRole;
