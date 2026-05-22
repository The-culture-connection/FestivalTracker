import { useState, useRef } from 'react';
import { MapPin, Music, ZoomIn, ZoomOut, Navigation } from 'lucide-react';

interface Observation {
  id: string;
  lat: number;
  lng: number;
  size: string;
  activity: string;
  location: string;
  direction: string;
  uniform: string;
  datetime: string;
  equipment: string;
}

interface MapViewProps {
  observations: Observation[];
  selectedPin: { lat: number; lng: number } | null;
  onMapClick: (lat: number, lng: number) => void;
}

// Convert lat/lng to pixel coordinates on the map
const latLngToPixel = (lat: number, lng: number, width: number, height: number) => {
  // Mercator projection
  const x = (lng + 180) * (width / 360);
  const latRad = (lat * Math.PI) / 180;
  const mercN = Math.log(Math.tan(Math.PI / 4 + latRad / 2));
  const y = height / 2 - (width * mercN) / (2 * Math.PI);
  return { x, y };
};

// Convert pixel coordinates back to lat/lng
const pixelToLatLng = (x: number, y: number, width: number, height: number) => {
  const lng = (x / width) * 360 - 180;
  const mercN = ((height / 2 - y) * 2 * Math.PI) / width;
  const latRad = 2 * Math.atan(Math.exp(mercN)) - Math.PI / 2;
  const lat = (latRad * 180) / Math.PI;
  return { lat, lng };
};

export function MapView({ observations, selectedPin, onMapClick }: MapViewProps) {
  const mapRef = useRef<HTMLDivElement>(null);
  const [hoveredPin, setHoveredPin] = useState<string | null>(null);
  const [zoom, setZoom] = useState(1.5);
  const [pan, setPan] = useState({ x: 0, y: 0 });
  const [isDragging, setIsDragging] = useState(false);
  const [dragStart, setDragStart] = useState({ x: 0, y: 0 });

  const handleMouseDown = (e: React.MouseEvent) => {
    if (e.button === 0) {
      setIsDragging(true);
      setDragStart({ x: e.clientX - pan.x, y: e.clientY - pan.y });
    }
  };

  const handleMouseMove = (e: React.MouseEvent) => {
    if (isDragging) {
      setPan({
        x: e.clientX - dragStart.x,
        y: e.clientY - dragStart.y,
      });
    }
  };

  const handleMouseUp = () => {
    setIsDragging(false);
  };

  const handleClick = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!mapRef.current || isDragging) return;

    const rect = mapRef.current.getBoundingClientRect();
    const x = (e.clientX - rect.left - pan.x) / zoom;
    const y = (e.clientY - rect.top - pan.y) / zoom;

    const { lat, lng } = pixelToLatLng(x, y, rect.width, rect.height);

    // Clamp latitude and longitude to valid ranges
    const clampedLat = Math.max(-85, Math.min(85, lat));
    const clampedLng = Math.max(-180, Math.min(180, lng));

    onMapClick(clampedLat, clampedLng);
  };

  const handleWheel = (e: React.WheelEvent) => {
    e.preventDefault();
    const delta = e.deltaY > 0 ? -0.15 : 0.15;
    setZoom(prev => Math.max(1, Math.min(4, prev + delta)));
  };

  const handleZoomIn = () => setZoom(prev => Math.min(4, prev + 0.3));
  const handleZoomOut = () => setZoom(prev => Math.max(1, prev - 0.3));

  return (
    <div
      className="relative w-full h-full overflow-hidden bg-black"
      onWheel={handleWheel}
    >
      <div
        ref={mapRef}
        onClick={handleClick}
        onMouseDown={handleMouseDown}
        onMouseMove={handleMouseMove}
        onMouseUp={handleMouseUp}
        onMouseLeave={handleMouseUp}
        className="relative w-full h-full"
        style={{
          cursor: isDragging ? 'grabbing' : 'grab',
          transform: `translate(${pan.x}px, ${pan.y}px) scale(${zoom})`,
          transformOrigin: '0 0',
          transition: isDragging ? 'none' : 'transform 0.1s ease-out',
        }}
      >
        {/* World map background */}
        <div
          className="absolute inset-0 w-full h-full"
          style={{
            backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 2000 1000'%3E%3Crect fill='%230a0a0a' width='2000' height='1000'/%3E%3Cpath fill='%23ff6b00' opacity='0.15' d='M250,200 Q300,150 350,200 L400,250 L450,200 L500,250 L550,200 Q600,250 650,200 L700,300 L650,350 L600,300 L550,350 L500,300 L450,350 L400,300 L350,350 L300,300 Z M800,300 L850,250 L900,300 L950,250 L1000,300 L1050,250 Q1100,300 1150,250 L1200,350 L1150,400 L1100,350 L1050,400 L1000,350 L950,400 L900,350 L850,400 Z M200,500 Q250,450 300,500 L350,550 L400,500 L450,550 L500,500 Q550,550 600,500 L650,600 L600,650 L550,600 L500,650 L450,600 L400,650 L350,600 Z M1300,400 L1350,350 L1400,400 L1450,350 L1500,400 L1550,350 Q1600,400 1650,350 L1700,450 L1650,500 L1600,450 L1550,500 L1500,450 L1450,500 Z M100,700 Q150,650 200,700 L250,750 L300,700 L350,750 L400,700 Q450,750 500,700 L550,800 L500,850 L450,800 L400,850 L350,800 Z'/%3E%3C/svg%3E")`,
            backgroundSize: 'cover',
            backgroundPosition: 'center',
          }}
        />

        {/* Grid overlay */}
        <div
          className="absolute inset-0 opacity-20"
          style={{
            backgroundImage: `
              linear-gradient(rgba(255, 107, 0, 0.1) 1px, transparent 1px),
              linear-gradient(90deg, rgba(255, 107, 0, 0.1) 1px, transparent 1px)
            `,
            backgroundSize: '50px 50px',
          }}
        />

        {/* Major grid lines (lat/lng) */}
        <div
          className="absolute inset-0 opacity-25"
          style={{
            backgroundImage: `
              linear-gradient(rgba(255, 107, 0, 0.3) 2px, transparent 2px),
              linear-gradient(90deg, rgba(255, 107, 0, 0.3) 2px, transparent 2px)
            `,
            backgroundSize: '200px 100px',
          }}
        />

        {/* Existing observations */}
        {observations.map((obs, index) => {
          if (!mapRef.current) return null;
          const rect = mapRef.current.getBoundingClientRect();
          const { x, y } = latLngToPixel(obs.lat, obs.lng, rect.width, rect.height);

          return (
            <div
              key={obs.id}
              className="absolute transform -translate-x-1/2 -translate-y-full cursor-pointer group z-10"
              style={{
                left: `${x}px`,
                top: `${y}px`,
                animation: `dropIn 0.5s ease-out ${index * 0.1}s both`,
              }}
              onMouseEnter={() => setHoveredPin(obs.id)}
              onMouseLeave={() => setHoveredPin(null)}
            >
              <div className="relative">
                <MapPin
                  className="w-8 h-8 text-primary drop-shadow-[0_0_12px_rgba(255,107,0,0.9)] group-hover:scale-125 transition-transform duration-200"
                  fill="currentColor"
                />
                <Music className="w-3 h-3 text-black absolute top-1.5 left-1/2 -translate-x-1/2 animate-pulse"
                       style={{ animationDuration: '2s' }} />
              </div>

              {/* Tooltip */}
              {hoveredPin === obs.id && (
                <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 px-3 py-2 bg-card border border-primary/50 rounded-lg shadow-xl whitespace-nowrap animate-in fade-in zoom-in-95 duration-200 max-w-xs">
                  <p className="text-xs font-medium text-white">{obs.location}</p>
                  <p className="text-xs text-primary">{obs.activity}</p>
                  <p className="text-xs text-muted-foreground mt-1">{obs.size}</p>
                </div>
              )}

              {/* Pulse effect */}
              <div className="absolute top-0 left-1/2 -translate-x-1/2 w-8 h-8 bg-primary/20 rounded-full animate-ping"
                   style={{ animationDuration: '2s' }} />
            </div>
          );
        })}

        {/* Selected pin preview */}
        {selectedPin && mapRef.current && (
          <div
            className="absolute transform -translate-x-1/2 -translate-y-full animate-bounce z-20"
            style={{
              left: `${latLngToPixel(selectedPin.lat, selectedPin.lng, mapRef.current.getBoundingClientRect().width, mapRef.current.getBoundingClientRect().height).x}px`,
              top: `${latLngToPixel(selectedPin.lat, selectedPin.lng, mapRef.current.getBoundingClientRect().width, mapRef.current.getBoundingClientRect().height).y}px`,
            }}
          >
            <MapPin
              className="w-10 h-10 text-accent drop-shadow-[0_0_16px_rgba(255,165,89,0.9)]"
              fill="currentColor"
            />
            <div className="absolute top-0 left-1/2 -translate-x-1/2 w-10 h-10 bg-accent/30 rounded-full animate-ping" />
          </div>
        )}
      </div>

      {/* Zoom controls */}
      <div className="absolute top-4 right-4 flex flex-col gap-2 z-30">
        <button
          onClick={handleZoomIn}
          className="p-3 bg-black/80 hover:bg-black border border-primary/50 rounded-lg transition-colors duration-200 backdrop-blur-sm"
        >
          <ZoomIn className="w-5 h-5 text-primary" />
        </button>
        <button
          onClick={handleZoomOut}
          className="p-3 bg-black/80 hover:bg-black border border-primary/50 rounded-lg transition-colors duration-200 backdrop-blur-sm"
        >
          <ZoomOut className="w-5 h-5 text-primary" />
        </button>
        <div className="px-3 py-2 bg-black/80 border border-primary/50 rounded-lg text-xs text-primary text-center backdrop-blur-sm">
          {Math.round(zoom * 100)}%
        </div>
      </div>

      {/* Coordinates legend */}
      <div className="absolute bottom-4 left-4 px-4 py-2 bg-black/80 border border-primary/50 rounded-lg text-xs text-primary backdrop-blur-sm z-30 flex items-center gap-2">
        <Navigation className="w-3 h-3" />
        <span>World Map View • Click to drop pin</span>
      </div>

      <style>{`
        @keyframes dropIn {
          from {
            opacity: 0;
            transform: translate(-50%, -100%) scale(0) rotate(-180deg);
          }
          to {
            opacity: 1;
            transform: translate(-50%, -100%) scale(1) rotate(0deg);
          }
        }
      `}</style>
    </div>
  );
}
