import { useEffect, useState } from "react";
import { motion } from "framer-motion";

import { ReactNode } from "react";

const AnimatedSection = ({ children }: { children: ReactNode }) => {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            setIsVisible(true);
          }
        });
      },
      {
        threshold: 0.5, // Trigger animation when 50% of the section is in view
      }
    );

    const section = document.querySelector("#animated-section");
    if (section) observer.observe(section);

    return () => {
      if (section) observer.unobserve(section);
    };
  }, []);

  return (
    <motion.section
      id="animated-section"
      className="py-20"
      initial={{ opacity: 0, y: 50 }}
      animate={{ opacity: isVisible ? 1 : 0, y: isVisible ? 0 : 50 }}
      transition={{ duration: 0.8 }}
    >
      {children}
    </motion.section>
  );
};

export default AnimatedSection;
