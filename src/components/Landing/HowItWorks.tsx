import {
  FaSearch,
  FaTicketAlt,
  FaCheckCircle,
  FaExchangeAlt,
} from "react-icons/fa"; // Import icons

const steps = [
  {
    title: "Discover Events",
    description:
      "Browse upcoming events and NFT collections to find what interests you.",
    icon: <FaSearch className="text-primary text-4xl" />,
  },
  {
    title: "Purchase Tickets",
    description:
      "Buy tickets using CORE tokens, ensuring fast and secure transactions.",
    icon: <FaTicketAlt className="text-accent text-4xl" />,
  },
  {
    title: "Participate",
    description: "Attend the event, vote securely, and enjoy the experience.",
    icon: <FaCheckCircle className="text-highlight text-4xl" />,
  },
  {
    title: "Resale & Rewards",
    description:
      "Trade tickets or earn rewards for participation in the event ecosystem.",
    icon: <FaExchangeAlt className="text-secondary text-4xl" />,
  },
];

const HowItWorks: React.FC = () => {
  return (
    <section className="how-it-works py-16 bg-background text-white">
      <div className="max-w-7xl mx-auto text-center">
        <h2 className="text-4xl font-bold mb-12">How It Works</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
          {steps.map((step, index) => (
            <div
              key={index}
              className="step-card bg-card p-6 rounded-lg shadow-lg transition-all hover:scale-105"
            >
              <div className="icon mb-4">{step.icon}</div>
              <h3 className="text-2xl font-medium mb-2">{step.title}</h3>
              <p>{step.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default HowItWorks;
