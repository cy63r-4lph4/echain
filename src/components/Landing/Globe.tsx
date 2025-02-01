import React from "react";
import { Canvas } from "@react-three/fiber";
import { OrbitControls, Stars } from "@react-three/drei";

const Globe: React.FC = () => {
  return (
    <Canvas
      className="w-full h-full"
      camera={{ position: [0, 0, 8], fov: 60 }}
      onCreated={({ gl }) => {
        gl.setClearColor("#0A0A0A");
      }}
    >
      {/* Background Stars */}
      <Stars
        radius={200}
        depth={60}
        count={10000}
        factor={6}
        saturation={0.5}
        fade
        speed={1}
      />

      {/* Lighting */}
      <ambientLight intensity={0.5} />
      <pointLight position={[10, 10, 10]} intensity={1} />
      <pointLight position={[-10, -10, -10]} intensity={0.3} />

      {/* Globe */}
      <mesh rotation={[0, 0, 0]}>
        <sphereGeometry args={[2.5, 64, 64]} />
        <meshStandardMaterial
          color="#1F2937"
          emissive="#4F46E5"
          emissiveIntensity={0.8}
          roughness={0.4}
          metalness={0.5}
        />
      </mesh>

      {/* Wireframe Overlay */}
      <mesh>
        <sphereGeometry args={[2.51, 64, 64]} />
        <meshBasicMaterial
          color="#9333EA"
          wireframe
          transparent
          opacity={0.3}
        />
      </mesh>

      {/* Orbiting Particles */}
      <group>
        {[...Array(50)].map((_, i) => (
          <mesh
            key={i}
            position={[
              Math.cos((i * Math.PI) / 25) * 3.5,
              Math.sin((i * Math.PI) / 25) * 3.5,
              Math.sin((i * Math.PI) / 25) * 1.5,
            ]}
          >
            <sphereGeometry args={[0.05, 16, 16]} />
            <meshStandardMaterial emissive="#14B8A6" color="#14B8A6" />
          </mesh>
        ))}
      </group>

      {/* Blockchain Grid */}
      <group rotation={[Math.PI / 4, Math.PI / 4, 0]}>
        {[...Array(20)].map((_, i) => (
          <mesh key={i} position={[0, 0, 0]}>
            <torusGeometry args={[2 + i * 0.1, 0.01, 8, 6]} />
            <meshBasicMaterial
              color="#22D3EE"
              wireframe
              transparent
              opacity={0.2}
            />
          </mesh>
        ))}
      </group>

      {/* Controls */}
      <OrbitControls
        enableZoom={true}
        enablePan={false}
        autoRotate
        autoRotateSpeed={1.2}
      />
    </Canvas>
  );
};

export default Globe;
