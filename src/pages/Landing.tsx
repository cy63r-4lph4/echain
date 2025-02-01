import {
  Hero,
  Features,
  ValueProposition,
  DiscoverMovieTickets,
  HowItWorks,
  CTA,
  Footer,
} from "../components/Landing";

const Landing = () => {
  return (
    <div>
      <Hero />
      <Features />
      <ValueProposition />
      <DiscoverMovieTickets />
      <HowItWorks />
      <CTA />
      <Footer />
    </div>
  );
};

export default Landing;
