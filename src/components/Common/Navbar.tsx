import React, { useState,useEffect } from "react";
import { Link, useLocation } from "react-router-dom";
import clsx from "clsx";
import useCheckUserRole from "../../hooks/useCheckUserRole";
import CustomConnectButton from "./ConnectWallet";
import { useNavigate } from "react-router-dom";

const Navbar: React.FC = () => {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const location = useLocation();
  const navigate=useNavigate(); 

  const isOrganizer = useCheckUserRole();

  useEffect(() => {
    if (isOrganizer === true) {
      navigate("/admin-dashboard");
    } else if (isOrganizer === false) {
    return;
    }
  }, [isOrganizer]);

 

  const links = [
    { name: "Events", path: "/events" },
    { name: "Collectibles", path: "/collectibles" },
    { name: "Blog", path: "/blog" },
    { name: "About", path: "/about" },
  ];

  return (
    <nav className="bg-background/80 backdrop-blur-md text-white shadow-md sticky top-0 z-50">
      <div className="container mx-auto flex justify-between items-center px-4 py-3">
        {/* Logo */}
        <div className="text-2xl font-bold tracking-wide text-primary">
          <Link to="/">E-Chain</Link>
        </div>

        {/* Links for larger screens */}
        <div className="hidden md:flex gap-6">
          {links.map((link) => (
            <Link
              key={link.name}
              to={link.path}
              className={clsx(
                "relative text-lg font-medium hover:text-accent transition duration-300 transform hover:scale-105",
                {
                  "text-accent": location.pathname === link.path,
                }
              )}
            >
              {link.name}
              {location.pathname === link.path && (
                <span className="absolute -bottom-1 left-0 h-0.5 w-full bg-accent animate-pulse"></span>
              )}
            </Link>
          ))}
        </div>

        <div className="flex items-center">
          
            < CustomConnectButton />
    
        </div>

        {/* Mobile Menu Toggle */}
        <div className="md:hidden flex items-center">
          <button
            className="text-primary focus:outline-none"
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              className="w-6 h-6"
            >
              {isMobileMenuOpen ? (
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M6 18L18 6M6 6l12 12"
                />
              ) : (
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M4 6h16M4 12h16m-7 6h7"
                />
              )}
            </svg>
          </button>
        </div>
      </div>

      {/* Mobile Dropdown Menu */}
      {isMobileMenuOpen && (
        <div className="md:hidden bg-card/90 backdrop-blur-md text-white">
          {links.map((link) => (
            <Link
              key={link.name}
              to={link.path}
              className={clsx(
                "block px-4 py-2 hover:text-accent transition duration-300 transform hover:translate-x-2",
                {
                  "text-accent": location.pathname === link.path,
                }
              )}
              onClick={() => setIsMobileMenuOpen(false)}
            >
              {link.name}
            </Link>
          ))}
        </div>
      )}
    </nav>
  );
};

export default Navbar;
