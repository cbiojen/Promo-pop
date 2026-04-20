import { motion } from "motion/react";
import { useEffect, useState } from "react";

interface Particle {
  id: number;
  x: number;
  y: number;
  color: string;
  size: number;
  delay: number;
}

export function PromoPopLogo() {
  const [particles, setParticles] = useState<Particle[]>([]);

  useEffect(() => {
    const particleCount = 80;
    const newParticles: Particle[] = [];

    for (let i = 0; i < particleCount; i++) {
      const t = (i / particleCount) * Math.PI * 2;
      const scale = Math.sin(t * 2) * 0.5 + 0.5;

      const x = Math.cos(t) * (60 + scale * 30);
      const y = Math.sin(t * 2) / 2 * 40;

      const isYellow = i > particleCount * 0.4 && i < particleCount * 0.7;

      newParticles.push({
        id: i,
        x,
        y,
        color: isYellow ? "#FDB913" : "#0DC09D",
        size: Math.random() * 2 + 1,
        delay: Math.random() * 0.5,
      });
    }

    setParticles(newParticles);
  }, []);

  return (
    <div className="flex flex-col items-center justify-center gap-6 p-8">
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8 }}
        className="text-6xl font-bold tracking-tight"
      >
        <span className="text-[#0DC09D]">PROMO</span>
        <span className="text-[#FDB913]">Pop</span>
      </motion.div>

      <div className="relative w-64 h-32 flex items-center justify-center">
        <motion.svg
          width="256"
          height="128"
          viewBox="-120 -60 240 120"
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 1, delay: 0.3 }}
        >
          {particles.map((particle) => (
            <motion.circle
              key={particle.id}
              cx={particle.x}
              cy={particle.y}
              r={particle.size}
              fill={particle.color}
              initial={{ opacity: 0, scale: 0 }}
              animate={{
                opacity: [0, 1, 1, 0.6],
                scale: [0, 1.2, 1, 1],
              }}
              transition={{
                duration: 2,
                delay: particle.delay,
                repeat: Infinity,
                repeatDelay: 1,
              }}
            />
          ))}

          <motion.circle
            cx="-35"
            cy="0"
            r="3"
            fill="#0DC09D"
            initial={{ opacity: 0 }}
            animate={{ opacity: [0.3, 0.8, 0.3] }}
            transition={{ duration: 2, repeat: Infinity }}
          />
          <motion.circle
            cx="35"
            cy="0"
            r="3"
            fill="#FDB913"
            initial={{ opacity: 0 }}
            animate={{ opacity: [0.3, 0.8, 0.3] }}
            transition={{ duration: 2, repeat: Infinity, delay: 1 }}
          />
        </motion.svg>
      </div>

      <motion.p
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.8, delay: 0.6 }}
        className="text-sm text-gray-400 tracking-widest uppercase"
      >
        promoter<span className="text-[#0DC09D] font-semibold">AI</span> for populations
      </motion.p>
    </div>
  );
}
