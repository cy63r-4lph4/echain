import tailwindcss from "tailwindcss";
import daisyui from "daisyui";
import colors from "tailwindcss/colors"; 

module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
    "./public/index.html",
  ],
  theme: {
    extend: {
      colors: {
        primary: "#1E1E99",
        accent: "#00FFD1", // Neon cyan
        highlight: "#FF4B4B", // Bright red
        card: "#2A2A40", // Dark gray-blue for cards
        secondary: "#8E8E8E", // Neutral light gray
        background: "#1a1a3f",
        dark: "#0d0d1f",
        glow: "#4a6dfc", // Deep black-blue for the background
        white: colors.white,
      },
      fontFamily: {
        heading: ["Poppins", "sans-serif"], // Modern heading font
        body: ["Inter", "sans-serif"], // Clean body font
      },
      backgroundImage: {
        grid: "radial-gradient(circle, rgba(255,255,255,0.1) 1px, transparent 1px)",
      },
      boxShadow: {
        glow: "0 0 25px 5px rgba(74, 109, 252, 0.5)",
      },

      spacing: {
        72: "18rem",
        84: "21rem",
        96: "24rem",
      },
      transitionTimingFunction: {
        smooth: "cubic-bezier(0.4, 0, 0.2, 1)",
      },
    },
  },
  plugins: [daisyui],
  daisyui: {
    themes: [
      {
        greenWith4lph4: {
          primary: "#1E1E99",
          secondary: "#8E8E8E",
          accent: "#00FFD1",
          neutral: "#2A2A40",
          "base-100": "#0F0F20",
          info: "#00A6FB",
          success: "#4CAF50",
          warning: "#FFA500",
          error: "#FF4B4B",
        },
      },
    ],
    darkTheme: "greenWith4lph4",
  },
};
