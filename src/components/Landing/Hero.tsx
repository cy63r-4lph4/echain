import React from "react";
import { Globe, HeroText } from "./index";
import { motion } from "framer-motion"; // Importing framer-motion for animations

const HeroSection: React.FC = () => {
  return (
    <section className="relative bg-gray-800 text-white min-h-screen flex flex-col items-center justify-center overflow-hidden">
      <div className="absolute inset-0 z-5">
        <Globe />
      </div>

      <div className="relative z-10 text-center px-6">
        <HeroText />
      </div>

      <div className="relative z-10 mt-8 flex flex-wrap justify-center space-x-4">
        {/* Get Started Button */}
        <motion.button
          className="bg-primary text-white py-3 px-8 rounded-lg shadow-lg hover:bg-opacity-90 transition"
          initial={{ scale: 0.9 }}
          animate={{ scale: 1 }}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
          transition={{ duration: 0.3 }}
        >
          Get Started
        </motion.button>

        {/* Learn More Button */}
        <motion.button
          className="border border-highlight text-highlight py-3 px-8 rounded-lg hover:bg-highlight hover:text-white transition"
          initial={{ scale: 0.9 }}
          animate={{ scale: 1 }}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
          transition={{ duration: 0.3 }}
        >
          Learn More
        </motion.button>
      </div>
    </section>
  );
};

export default HeroSection;
