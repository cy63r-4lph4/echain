import React from "react";

interface CTAButtonProps {
  text: string;
  onClick?: () => void;
}

const CTAButton: React.FC<CTAButtonProps> = ({ text, onClick }) => {
  return (
    <button
      onClick={onClick}
      className="bg-green-400 text-gray-900 px-6 py-3 rounded-lg text-lg font-semibold hover:bg-green-500 transition duration-300"
    >
      {text}
    </button>
  );
};

export default CTAButton;
