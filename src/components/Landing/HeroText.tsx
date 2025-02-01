import React from "react";
import { Typewriter } from "react-simple-typewriter";

const HeroText: React.FC = () => {
  return (
    <div className="text-center font-heading">
      <h1 className="text-5xl md:text-7xl font-extrabold bg-gradient-to-r from-primary via-accent to-highlight bg-clip-text text-transparent animate-pulse">
        Revolutionizing Events
      </h1>
      <h2 className="text-4xl md:text-5xl mt-4 bg-gradient-to-r from-highlight to-accent bg-clip-text text-transparent">
        Through Blockchain Technology
      </h2>
      <div className="mt-6 text-accent text-2xl md:text-3xl font-medium">
        <span className="inline-block px-6 py-3 bg-gradient-to-r from-card via-secondary to-primary rounded-lg shadow-lg text-white tracking-wider">
          <Typewriter
            words={["Secure Voting", "NFT Ticketing", "Seamless Experiences"]}
            loop={0} // Infinite loop
            cursor
            cursorStyle="_"
            typeSpeed={70}
            deleteSpeed={50}
            delaySpeed={2000}
          />
        </span>
      </div>
    </div>
  );
};

export default HeroText;
