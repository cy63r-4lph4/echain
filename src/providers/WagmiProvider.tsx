import "@rainbow-me/rainbowkit/styles.css";
import {
  getDefaultConfig,
  RainbowKitProvider,
  darkTheme, // Import theme
} from "@rainbow-me/rainbowkit";
import { WagmiProvider } from "wagmi";
import {
  mainnet,
  sepolia,
  liskSepolia,
  polygon,
  optimism,
  arbitrum,
  base,
} from "wagmi/chains";
import { QueryClientProvider, QueryClient } from "@tanstack/react-query";

const queryClient = new QueryClient();
const projectId = "3bd1de65c38f41fadb72301ec5bdcd37";

const config = getDefaultConfig({
  appName: "E-Chain",
  projectId: projectId,
  chains: [mainnet, liskSepolia, sepolia, polygon, optimism, arbitrum, base],
  ssr: false,
});

const CustomWagmiProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider
          theme={darkTheme({
            accentColor: "#9333ea", // Purple accent
            accentColorForeground: "white",
            borderRadius: "medium",
            overlayBlur: "small",
          })}
        >
          {children}
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
};

export default CustomWagmiProvider;
