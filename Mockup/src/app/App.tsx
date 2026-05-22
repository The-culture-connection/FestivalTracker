import { useState } from 'react';
import { MapView } from './components/MapView';
import { ObservationForm } from './components/ObservationForm';
import { Music2 } from 'lucide-react';

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

// Mock observations with real world coordinates
const MOCK_OBSERVATIONS: Observation[] = [
  {
    id: '1',
    lat: 34.0522, // Los Angeles
    lng: -118.2437,
    size: '2000-3000 people, intense energy',
    activity: 'Main stage headliner performance',
    location: 'Coachella Valley, California, USA',
    direction: 'Converging toward stage front',
    uniform: 'Festival wristbands, glow sticks',
    datetime: '2026-04-16T20:30',
    equipment: 'Professional cameras, LED poi, light shows',
  },
  {
    id: '2',
    lat: 51.5074, // London
    lng: -0.1278,
    size: '500-800 people, chill vibes',
    activity: 'Electronic DJ set',
    location: 'Hyde Park, London, UK',
    direction: 'Dancing in place, some movement to bar',
    uniform: 'Tie-dye shirts, flower crowns',
    datetime: '2026-04-16T18:15',
    equipment: 'Phone cameras, portable speakers',
  },
  {
    id: '3',
    lat: -23.5505, // São Paulo
    lng: -46.6333,
    size: '150-200 people, relaxed',
    activity: 'Acoustic performance',
    location: 'Ibirapuera Park, São Paulo, Brazil',
    direction: 'Seated, minimal movement',
    uniform: 'Casual festival wear, hats',
    datetime: '2026-04-16T16:45',
    equipment: 'Blankets, cameras, recording devices',
  },
  {
    id: '4',
    lat: 35.6762, // Tokyo
    lng: 139.6503,
    size: '1000-1500 people, high energy',
    activity: 'Rock band performance',
    location: 'Fuji Rock Festival, Japan',
    direction: 'Mosh pit forming, crowd surfing',
    uniform: 'Band merchandise, leather jackets',
    datetime: '2026-04-16T21:00',
    equipment: 'Pro cameras, audio recording gear',
  },
  {
    id: '5',
    lat: 52.3676, // Amsterdam
    lng: 4.9041,
    size: '300-400 people, moderate',
    activity: 'Food truck gathering',
    location: 'Vondelpark, Amsterdam, Netherlands',
    direction: 'Line queues, dispersing after purchase',
    uniform: 'Mixed casual wear',
    datetime: '2026-04-16T19:30',
    equipment: 'Phones, portable chargers',
  },
];

export default function App() {
  const [observations, setObservations] = useState<Observation[]>(MOCK_OBSERVATIONS);
  const [selectedPin, setSelectedPin] = useState<{ lat: number; lng: number } | null>(null);
  const [showForm, setShowForm] = useState(false);

  const handleMapClick = (lat: number, lng: number) => {
    setSelectedPin({ lat, lng });
    setShowForm(true);
  };

  const handleFormSubmit = (data: Omit<Observation, 'id' | 'lat' | 'lng'>) => {
    if (!selectedPin) return;

    const newObservation: Observation = {
      id: Date.now().toString(),
      lat: selectedPin.lat,
      lng: selectedPin.lng,
      ...data,
    };

    setObservations([...observations, newObservation]);
    setShowForm(false);
    setSelectedPin(null);
  };

  const handleFormCancel = () => {
    setShowForm(false);
    setSelectedPin(null);
  };

  return (
    <div className="size-full flex flex-col overflow-hidden relative bg-black">
      {/* Header */}
      <header className="relative z-10 px-4 py-4 border-b border-primary/30 bg-black/95 backdrop-blur-sm">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="relative">
              <Music2 className="w-7 h-7 text-primary animate-pulse" style={{ animationDuration: '2s' }} />
              <div className="absolute inset-0 bg-primary/40 blur-lg animate-pulse" style={{ animationDuration: '2s' }} />
            </div>
            <h1 className="text-2xl tracking-tight" style={{ fontFamily: 'var(--font-display)' }}>
              <span className="text-primary">FEST</span><span className="text-white">MAP</span>
            </h1>
          </div>
          <div className="flex items-center gap-2 text-xs text-muted-foreground">
            <div className="w-2 h-2 bg-primary rounded-full animate-pulse" />
            <span>{observations.length} pins active</span>
          </div>
        </div>
      </header>

      {/* Map */}
      <main className="flex-1 relative overflow-hidden">
        <MapView
          observations={observations}
          selectedPin={selectedPin}
          onMapClick={handleMapClick}
        />

        {/* Form slide-up */}
        {showForm && selectedPin && (
          <>
            <div
              className="absolute inset-0 bg-black/60 backdrop-blur-sm z-20 animate-in fade-in duration-300"
              onClick={handleFormCancel}
            />
            <div className="absolute bottom-0 left-0 right-0 z-30 animate-in slide-in-from-bottom duration-500">
              <ObservationForm
                onSubmit={handleFormSubmit}
                onCancel={handleFormCancel}
              />
            </div>
          </>
        )}
      </main>

      {/* Instructions */}
      {!showForm && (
        <div className="absolute bottom-6 left-1/2 -translate-x-1/2 z-10 px-6 py-3 bg-black/80 border border-primary/50 rounded-full backdrop-blur-sm">
          <p className="text-sm text-primary">
            Click anywhere on the map to drop a pin
          </p>
        </div>
      )}
    </div>
  );
}
