import React from "react";
import { FaEye, FaGlobe, FaLeaf, FaAward } from "react-icons/fa"; // Icons

const ValueProposition: React.FC = () => {
  const values = [
    {
      title: "Transparency",
      description:
        "Blockchain ensures no fraud or tampering, providing a transparent, trustless platform.",
      icon: <FaEye className="text-primary text-4xl" />,
    },
    {
      title: "Accessibility",
      description:
        "Global accessibility to events and participation, enabling anyone, anywhere to join.",
      icon: <FaGlobe className="text-accent text-4xl" />,
    },
    {
      title: "Sustainability",
      description:
        "GreenNet reduces carbon footprints compared to other systems, powering eco-friendly transactions.",
      icon: <FaLeaf className="text-green-700 text-4xl" />,
    },
    {
      title: "Exclusivity",
      description:
        "NFT-based access unlocks special privileges for ticket holders, making your participation unique.",
      icon: <FaAward className="text-highlight text-4xl" />,
    },
  ];

  return (
    <section className="bg-background text-white py-16 px-6">
      <div className="max-w-6xl mx-auto text-center">
        <h2 className="text-4xl md:text-5xl font-heading font-bold mb-12">
          Why Choose This Platform?
        </h2>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 gap-8">
          {values.map((value, index) => (
            <div
              key={index}
              className="flex flex-col items-center text-center bg-card p-6 rounded-lg shadow-lg transition-transform transform hover:scale-105"
            >
              {/* Icon */}
              <div className="mb-4">{value.icon}</div>

              {/* Title */}
              <h3 className="text-2xl font-heading font-bold mb-2">
                {value.title}
              </h3>

              {/* Description */}
              <p className="text-secondary">{value.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default ValueProposition;
