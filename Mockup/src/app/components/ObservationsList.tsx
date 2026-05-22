import { Music2, Users, MapPin, Compass, Shirt, Clock, Mic2 } from 'lucide-react';
import { format } from 'date-fns';

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

interface ObservationsListProps {
  observations: Observation[];
}

export function ObservationsList({ observations }: ObservationsListProps) {
  if (observations.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center h-full gap-4 text-center p-8">
        <div className="relative">
          <Music2 className="w-24 h-24 text-muted-foreground/20" />
          <div className="absolute inset-0 bg-primary/10 blur-2xl animate-pulse" />
        </div>
        <div>
          <h3 className="text-xl mb-2" style={{ fontFamily: 'var(--font-display)' }}>
            No Observations Yet
          </h3>
          <p className="text-muted-foreground">
            Drop pins on the map to track festival activity
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="h-full overflow-y-auto px-4 py-6">
      <div className="max-w-2xl mx-auto space-y-4">
        {observations.map((obs, index) => (
          <div
            key={obs.id}
            className="bg-card border border-border rounded-2xl overflow-hidden hover:shadow-xl hover:shadow-primary/10 transition-all duration-300 animate-in slide-in-from-bottom-4"
            style={{ animationDelay: `${index * 0.05}s`, animationFillMode: 'both' }}
          >
            {/* Header */}
            <div className="px-5 py-4 bg-gradient-to-r from-primary/10 via-secondary/10 to-accent/10 border-b border-border">
              <div className="flex items-start justify-between gap-4">
                <div className="flex items-center gap-3">
                  <div className="p-2 bg-primary/20 rounded-full">
                    <Music2 className="w-5 h-5 text-primary" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-lg">{obs.location}</h3>
                    <p className="text-sm text-muted-foreground flex items-center gap-1">
                      <Clock className="w-3 h-3" />
                      {format(new Date(obs.datetime), 'MMM dd, yyyy • h:mm a')}
                    </p>
                  </div>
                </div>
                <div className="px-3 py-1 bg-primary/20 rounded-full text-xs text-primary border border-primary/30">
                  Pin #{observations.length - index}
                </div>
              </div>
            </div>

            {/* Content */}
            <div className="p-5 space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {/* Size */}
                <div className="flex gap-3">
                  <div className="p-2 bg-primary/10 rounded-lg h-fit">
                    <Users className="w-4 h-4 text-primary" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs text-muted-foreground mb-1">Crowd Size</p>
                    <p className="text-sm break-words">{obs.size}</p>
                  </div>
                </div>

                {/* Activity */}
                <div className="flex gap-3">
                  <div className="p-2 bg-secondary/10 rounded-lg h-fit">
                    <Music2 className="w-4 h-4 text-secondary" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs text-muted-foreground mb-1">Activity</p>
                    <p className="text-sm break-words">{obs.activity}</p>
                  </div>
                </div>

                {/* Direction */}
                <div className="flex gap-3">
                  <div className="p-2 bg-accent/10 rounded-lg h-fit">
                    <Compass className="w-4 h-4 text-accent" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs text-muted-foreground mb-1">Movement</p>
                    <p className="text-sm break-words">{obs.direction}</p>
                  </div>
                </div>

                {/* Attire */}
                <div className="flex gap-3">
                  <div className="p-2 bg-primary/10 rounded-lg h-fit">
                    <Shirt className="w-4 h-4 text-primary" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs text-muted-foreground mb-1">Attire</p>
                    <p className="text-sm break-words">{obs.uniform}</p>
                  </div>
                </div>
              </div>

              {/* Equipment */}
              <div className="flex gap-3 pt-2 border-t border-border">
                <div className="p-2 bg-secondary/10 rounded-lg h-fit">
                  <Mic2 className="w-4 h-4 text-secondary" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-xs text-muted-foreground mb-1">Equipment</p>
                  <p className="text-sm break-words">{obs.equipment}</p>
                </div>
              </div>

              {/* Coordinates */}
              <div className="flex items-center gap-2 text-xs text-muted-foreground pt-2">
                <MapPin className="w-3 h-3" />
                <span>Coordinates: {obs.lat.toFixed(2)}, {obs.lng.toFixed(2)}</span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
