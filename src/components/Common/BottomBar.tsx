import { Home, Calendar, Settings, PlusCircle } from "lucide-react";

const BottomBar = () => {
  return (
    <div className="md:hidden fixed bottom-0 left-0 w-full bg-gradient-to-r from-gray-900 to-gray-800 text-white shadow-lg">
      <nav className="flex justify-between items-center px-6 py-4">
        {[
          { name: "Dashboard", icon: <Home />, path: "/dashboard" },
          { name: "Create Event", icon: <PlusCircle />, path: "/create-event" },
          { name: "Events", icon: <Calendar />, path: "/events" },
          { name: "Settings", icon: <Settings />, path: "/settings" },
        ].map((item, index) => (
          <a
            key={index}
            href={item.path}
            className="flex flex-col items-center text-sm hover:text-purple-500 transition-all duration-300"
          >
            <span className="text-xl">{item.icon}</span>
            <span>{item.name}</span>
          </a>
        ))}
      </nav>
    </div>
  );
};

export default BottomBar;
