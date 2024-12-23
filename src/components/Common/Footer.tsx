import React from "react";

const Footer: React.FC = () => {
  return (
    <footer className="bg-gray-800 text-gray-300 py-6">
      <div className="container mx-auto text-center">
        <p className="mb-2">© {new Date().getFullYear()} E-Chain. All rights reserved.</p>
        <div className="flex justify-center space-x-4">
          <a href="#" className="hover:text-green-400">
            Privacy Policy
          </a>
          <a href="#" className="hover:text-green-400">
            Terms of Service
          </a>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
