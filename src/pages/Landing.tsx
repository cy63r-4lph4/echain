

import React from "react";
import Navbar from "../components/Common/Navbar";
import Footer from "../components/Common/Footer";
import CTAButton from "../components/Common/CTAButton";

const LandingPage: React.FC = () => {
  return (
    <div className="bg-gray-900 text-white font-sans">
      {/* Navbar Section */}
      <Navbar />

      {/* Hero Section */}
      <section
        className="h-screen bg-[url('/public/images/hero-bg.jpg')] bg-cover bg-center flex items-center justify-center px-8 text-center"
      >
        <div className="max-w-4xl">
          <h1 className="text-5xl md:text-7xl font-bold text-white leading-tight mb-6">
            Welcome to <span className="text-green-400">E-Chain</span>
          </h1>
          <p className="text-lg md:text-2xl mb-8 text-gray-300">
            A decentralized platform for seamless voting and NFT ticketing solutions.
            Powered by blockchain technology.
          </p>
          <CTAButton text="Get Started" />
        </div>
      </section>

      {/* Key Features Section */}
      <section className="py-20 px-6 md:px-20 bg-gray-800">
        <div className="text-center mb-12">
          <h2 className="text-4xl font-bold mb-4">Why Choose E-Chain?</h2>
          <p className="text-gray-400">Core features that set us apart.</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {/* Feature 1 */}
          <div className="text-center p-6 bg-gray-900 rounded-lg shadow-lg">
            <div className="text-green-400 text-5xl mb-4">\u2713</div>
            <h3 className="text-2xl font-bold mb-2">Secure Voting</h3>
            <p className="text-gray-400">
              A robust blockchain-powered voting system with transparency and trust.
            </p>
          </div>

          {/* Feature 2 */}
          <div className="text-center p-6 bg-gray-900 rounded-lg shadow-lg">
            <div className="text-green-400 text-5xl mb-4">\u2605</div>
            <h3 className="text-2xl font-bold mb-2">NFT Ticketing</h3>
            <p className="text-gray-400">
              Transferable tickets and ownership records stored securely on-chain.
            </p>
          </div>

          {/* Feature 3 */}
          <div className="text-center p-6 bg-gray-900 rounded-lg shadow-lg">
            <div className="text-green-400 text-5xl mb-4">\u26A1</div>
            <h3 className="text-2xl font-bold mb-2">Fast Transactions</h3>
            <p className="text-gray-400">
              Leveraging Solana's L2 for ultra-fast and cost-effective transactions.
            </p>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-16 bg-green-400 text-gray-900 text-center">
        <h2 className="text-4xl font-bold mb-6">Ready to Get Started?</h2>
        <p className="text-lg mb-8">
          Join us today and revolutionize your event experience.
        </p>
        <CTAButton text="Sign Up" />
      </section>

      {/* Footer Section */}
      <Footer />
    </div>
  );
};

export default LandingPage;

/* 
Additional Notes:
- Navbar, Footer, and CTAButton components are reused.
- Tailwind CSS is utilized for fast styling.
- Responsive design is built using Tailwind utilities like grid, flex, and media classes.
- Imagery placeholders are noted in paths (e.g., 'hero-bg.jpg').
*/
