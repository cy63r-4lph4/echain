import { ConnectButton } from "@rainbow-me/rainbowkit";

const CustomConnectButton = () => {
  return (
    <ConnectButton.Custom>
      {({ account, chain, openConnectModal, openChainModal, mounted }) => {
        const ready = mounted;
        const connected = ready && account && chain;

        return (
          <div className="flex items-center space-x-2">
            {!connected ? (
              <button
                onClick={openConnectModal}
                className="px-4 py-2 text-white bg-purple-600 rounded-lg hover:bg-purple-700 transition"
              >
                Connect Wallet
              </button>
            ) : (
              <div className="flex items-center space-x-2 bg-gray-800 text-white px-4 py-2 rounded-lg">
                <button onClick={openChainModal} className="text-sm mr-3">
                  {chain?.name}
                </button>
                <span className="text-sm">{account.displayBalance}</span>
              </div>
            )}
          </div>
        );
      }}
    </ConnectButton.Custom>
  );
};

export default CustomConnectButton;
