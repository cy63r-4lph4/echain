import React from "react";
import { FaLock, FaTicketAlt, FaLeaf, FaCoins } from "react-icons/fa";
import { motion } from "framer-motion";

const FeaturesSection: React.FC = () => {
  const features = [
    {
      title: "Secure Voting",
      description:
        "Ensure transparent and tamper-proof decision-making with blockchain technology.",
      icon: <FaLock className="text-primary text-5xl" />,
    },
    {
      title: "NFT Ticketing",
      description:
        "Own your event tickets as NFTs, enabling authenticity, resale control, and exclusivity.",
      icon: <FaTicketAlt className="text-accent text-5xl" />,
    },
    {
      title: "GreenNet Support",
      description:
        "Power your events sustainably through GreenNet, promoting eco-friendly blockchain transactions. 99% less energy than traditional blockchain networks.",
      icon: <FaLeaf className="text-highlight text-5xl" />,
    },
    {
      title: "Unified Token (CØRE)",
      description:
        "Leverage Alph4 Core (CØRE,) for seamless ticket purchases, secure votes, and rewards within the 4lph4 ecosystem. Coming soon to major exchanges!",
      icon: <FaCoins className="text-secondary text-5xl" />,
    },
  ];

  return (
    <section className="relative bg-gradient-to-r from-background via-dark to-black py-20 px-6">
      <div className="absolute inset-0 bg-grid opacity-10"></div>

      <div className="max-w-7xl mx-auto text-center">
        <h2 className="text-4xl md:text-5xl font-heading font-bold text-transparent bg-clip-text bg-gradient-to-r from-accent to-primary mb-16">
          Explore Our Cutting-Edge Features
        </h2>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-2 gap-12">
          {features.map((feature, index) => (
            <motion.div
              key={index}
              className="group relative flex flex-col items-center text-center bg-opacity-10 bg-card rounded-lg p-8 shadow-lg transition-all hover:scale-105 hover:shadow-glow"
              initial={{ opacity: 0 }}
              whileInView={{ opacity: 1 }}
              transition={{ duration: 0.5, delay: index * 0.2 }}
            >
              {/* Glowing Border */}
              <div className="absolute inset-0 rounded-lg border-2 border-transparent group-hover:border-glow transition-colors"></div>

              {/* Icon with hover effect */}
              <motion.div
                className="mb-6"
                whileHover={{ scale: 1.1 }}
                transition={{ duration: 0.3 }}
              >
                {feature.icon}
              </motion.div>

              {/* Title */}
              <h3 className="text-2xl font-heading font-bold mb-4 text-white group-hover:text-accent">
                {feature.title}
              </h3>

              {/* Description */}
              <p className="text-secondary">{feature.description}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default FeaturesSection;
