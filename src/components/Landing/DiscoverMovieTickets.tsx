import React from "react";
import { FaTicketAlt } from "react-icons/fa"; // Icon for ticket

const DiscoverMovieTicket: React.FC = () => {
  return (
    <section className="relative bg-gradient-to-r from-primary via-accent to-highlight text-white py-20 px-6 overflow-hidden">
      <div className="max-w-7xl mx-auto text-center">
        {/* Heading */}
        <h2 className="text-4xl md:text-5xl font-heading font-bold mb-8">
          Unlock Your Next Movie Experience with NFTs
        </h2>

        {/* Subheading */}
        <p className="text-lg md:text-xl mb-12">
          Discover exclusive movie tickets, secure your seat with blockchain,
          and experience the future of cinema.
        </p>

        {/* Visual Section (Movie Poster or Animation) */}
        <div className="relative mb-12">
          <img
            src="images/movie_poster.jpeg"
            alt="Exclusive Movie Poster"
            className="w-full h-auto rounded-lg shadow-xl transform transition-all hover:scale-105"
          />
          {/* Hover Effect for CTA */}
          <div className="absolute inset-0 flex justify-center items-center opacity-0 hover:opacity-100 transition-opacity">
            <button className="bg-accent text-black text-2xl font-bold py-3 px-8 rounded-full shadow-lg transform hover:scale-110 transition-all">
              Get Your Ticket Now
            </button>
          </div>
        </div>

        {/* Additional Details */}
        <div className="flex justify-center gap-16 text-xl">
          <div className="flex items-center gap-2">
            <FaTicketAlt className="text-accent text-3xl" />
            <span>Own Your Ticket as an NFT</span>
          </div>
          <div className="flex items-center gap-2">
            <FaTicketAlt className="text-highlight text-3xl" />
            <span>Transparent & Secure Blockchain Technology</span>
          </div>
        </div>
      </div>
    </section>
  );
};

export default DiscoverMovieTicket;
