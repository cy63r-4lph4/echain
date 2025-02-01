import { Home, Calendar, Settings, LogOut } from "lucide-react";

const SideMenu = () => {
  return (
    <aside className="hidden md:flex flex-col items-center bg-gradient-to-b from-gray-900 to-gray-800 text-white w-60 h-screen shadow-2xl">
      <div className="flex flex-col items-center my-6">
        <h1 className="text-2xl font-bold tracking-wider">E-Chain</h1>
      </div>
      <nav className="flex flex-col mt-10 space-y-8 w-full px-6">
        {[
          { name: "Dashboard", icon: <Home />, path: "/dashboard" },
          { name: "Events", icon: <Calendar />, path: "/events" },
          { name: "Settings", icon: <Settings />, path: "/settings" },
        ].map((item, index) => (
          <a
            key={index}
            href={item.path}
            className="flex items-center gap-4 text-lg hover:text-purple-500 hover:translate-x-2 transform transition-all duration-300 ease-in-out"
          >
            <span className="text-xl">{item.icon}</span>
            {item.name}
          </a>
        ))}
      </nav>
      <div className="mt-auto mb-8">
        <a
          href="/logout"
          className="flex items-center gap-4 text-red-500 hover:text-red-400 transition duration-300"
        >
          <LogOut />
          Logout
        </a>
      </div>
    </aside>
  );
};

export default SideMenu;
