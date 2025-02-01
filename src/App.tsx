import { Routes, Route } from "react-router-dom";
import Home from "./pages/Landing";
import "./styles/global.css";
import { Navbar } from "./components/Common";
// import About from "./pages/About";
// import Features from "./pages/Features";
// import Contact from "./pages/Contact";

const App = () => {
  return (
    <div>
      <Navbar />
      <Routes>
        <Route path="/" element={<Home />} />
        {/* <Route path="/about" element={<About />} />
        <Route path="/features" element={<Features />} />
        <Route path="/contact" element={<Contact />} /> */}
      </Routes>
    </div>
  );
};

export default App;
