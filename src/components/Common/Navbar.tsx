import React from "react";

const Navbar: React.FC = () => {
  return (
    <nav className="bg-gray-800 text-white px-6 py-4">
      <div className="container mx-auto flex justify-between items-center">
        {/* Logo */}
        <a href="/" className="text-2xl font-bold text-green-400">
          E-Chain
        </a>

        {/* Navigation Links */}
        <ul className="hidden md:flex space-x-6">
          <li>
            <a href="#features" className="hover:text-green-400">
              Features
            </a>
          </li>
          <li>
            <a href="#about" className="hover:text-green-400">
              About
            </a>
          </li>
          <li>
            <a href="#contact" className="hover:text-green-400">
              Contact
            </a>
          </li>
        </ul>

        {/* CTA Button */}
        <a
          href="/signup"
          className="hidden md:inline-block bg-green-400 text-gray-900 px-4 py-2 rounded-lg font-semibold hover:bg-green-500"
        >
          Sign Up
        </a>

        {/* Mobile Menu Button */}
        <button className="block md:hidden text-white">
          <svg
            className="w-6 h-6"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              d="M4 6h16M4 12h16M4 18h16"
            ></path>
          </svg>
        </button>
      </div>
    </nav>
  );
};

export default Navbar;
