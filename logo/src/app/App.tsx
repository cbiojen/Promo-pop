import { PromoPopLogo } from "./components/PromoPopLogo";
import { PromoPopLogoStatic } from "./components/PromoPopLogoStatic";
import { useState } from "react";

export default function App() {
  const [showStatic, setShowStatic] = useState(false);

  return (
    <div className="min-h-screen w-full flex flex-col items-center justify-center bg-gradient-to-br from-[#1a2332] to-[#0d1520]">
      {showStatic ? <PromoPopLogoStatic /> : <PromoPopLogo />}

      <button
        onClick={() => setShowStatic(!showStatic)}
        className="mt-8 px-6 py-2 bg-[#0DC09D] text-white rounded-lg hover:bg-[#0BA888] transition-colors"
      >
        {showStatic ? "Show Animated" : "Show Static"}
      </button>
    </div>
  );
}