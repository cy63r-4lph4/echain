import { BrowserRouter as Router} from "react-router-dom";

import { createRoot } from 'react-dom/client'

import App from './App.tsx'
import CustomWagmiProvider from "./providers/WagmiProvider.tsx";

createRoot(document.getElementById('root')!).render(
  <Router>
    <CustomWagmiProvider>
      <App />
    </CustomWagmiProvider>
    </Router>
)
