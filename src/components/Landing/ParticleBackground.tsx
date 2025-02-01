import React from "react";
import Particles from "react-tsparticles";
import { loadFull } from "tsparticles";

const ParticleBackground: React.FC = () => {
  const particlesInit = async (main: any) => {
    await loadFull(main);
  };

  return (
    <Particles
      id="tsparticles"
      init={particlesInit}
      options={{
        fullScreen: { enable: false }, // Ensure it respects the container size
        background: { color: { value: "#0A0A0A" } },
        fpsLimit: 60,
        particles: {
          number: { value: 100, density: { enable: true, area: 800 } },
          size: { value: 3 },
          move: { speed: 1, enable: true },
          links: {
            enable: true,
            color: "#4F46E5",
            opacity: 0.5,
            distance: 150,
          },
          color: { value: "#ffffff" },
        },
      }}
      className="absolute inset-0 w-full h-full"
    />
  );
};

export default ParticleBackground;
