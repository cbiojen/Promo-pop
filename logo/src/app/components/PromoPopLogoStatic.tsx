export function PromoPopLogoStatic() {
  const particles = [];
  const particleCount = 80;

  for (let i = 0; i < particleCount; i++) {
    const t = (i / particleCount) * Math.PI * 2;
    const scale = Math.sin(t * 2) * 0.5 + 0.5;

    const x = Math.cos(t) * (60 + scale * 30);
    const y = Math.sin(t * 2) / 2 * 40;

    const isYellow = i > particleCount * 0.4 && i < particleCount * 0.7;

    particles.push({
      id: i,
      x,
      y,
      color: isYellow ? "#FDB913" : "#0DC09D",
      size: Math.random() * 2 + 1,
    });
  }

  return (
    <div className="flex flex-col items-center justify-center gap-6 p-8">
      <div className="text-6xl font-bold tracking-tight">
        <span className="text-[#0DC09D]">PROMO</span>
        <span className="text-[#FDB913]">Pop</span>
      </div>

      <div className="relative w-64 h-32 flex items-center justify-center">
        <svg
          width="256"
          height="128"
          viewBox="-120 -60 240 120"
          xmlns="http://www.w3.org/2000/svg"
        >
          {particles.map((particle) => (
            <circle
              key={particle.id}
              cx={particle.x}
              cy={particle.y}
              r={particle.size}
              fill={particle.color}
              opacity="0.8"
            />
          ))}

          <circle cx="-35" cy="0" r="3" fill="#0DC09D" opacity="0.6" />
          <circle cx="35" cy="0" r="3" fill="#FDB913" opacity="0.6" />
        </svg>
      </div>

      <p className="text-sm text-gray-400 tracking-widest uppercase">
        promoter<span className="text-[#0DC09D] font-semibold">AI</span> for populations
      </p>
    </div>
  );
}
