import { motion } from "framer-motion";
import { useInView } from "react-intersection-observer";

const CTA = () => {
  // Create a reference to track if the section is in view
  const { ref, inView } = useInView({
    triggerOnce: false, // Keep triggering animations when coming into view
    threshold: 0.2, // Trigger when 20% of the section is in view
  });

  return (
    <section className="py-20 bg-gradient-to-r from-primary to-accent text-white">
      <div className="container mx-auto text-center">
        {/* Header animation */}
        <motion.h2
          className="text-4xl font-heading font-bold mb-6"
          initial={{ opacity: 0, y: 50 }}
          animate={{ opacity: inView ? 1 : 0, y: inView ? 0 : 50 }}
          transition={{ duration: 0.6 }}
          ref={ref} // Pass ref to the element you want to observe
        >
          Ready to Transform Ticketing and Voting?
        </motion.h2>

        {/* Subheading animation */}
        <motion.p
          className="mt-4 text-lg"
          initial={{ opacity: 0 }}
          animate={{ opacity: inView ? 1 : 0 }}
          transition={{ delay: 0.3, duration: 0.6 }}
        >
          Join e-chain today and experience the power of blockchain technology.
        </motion.p>

        {/* Buttons animation */}
        <motion.div
          className="mt-8 flex justify-center gap-4"
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: inView ? 1 : 0, scale: inView ? 1 : 0.8 }}
          transition={{ delay: 0.5, duration: 0.6 }}
        >
          {/* Sign Up Button */}
          <button className="btn btn-primary bg-primary text-white text-lg px-8 py-3 rounded-full transform transition-all duration-300 hover:scale-105 hover:bg-accent hover:shadow-glow">
            Sign Up
          </button>

          {/* Learn More Button */}
          <button className="btn btn-outline border-2 border-primary text-primary text-lg px-8 py-3 rounded-full transform transition-all duration-300 hover:scale-105 hover:bg-primary hover:text-white hover:border-transparent">
            Learn More
          </button>
        </motion.div>
      </div>
    </section>
  );
};

export default CTA;
