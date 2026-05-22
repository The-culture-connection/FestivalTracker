import { useState } from 'react';
import { X, Music2, Users, MapPin, Compass, Shirt, Clock, Mic2 } from 'lucide-react';

interface ObservationFormProps {
  onSubmit: (data: {
    size: string;
    activity: string;
    location: string;
    direction: string;
    uniform: string;
    datetime: string;
    equipment: string;
  }) => void;
  onCancel: () => void;
}

export function ObservationForm({ onSubmit, onCancel }: ObservationFormProps) {
  const [formData, setFormData] = useState({
    size: '',
    activity: '',
    location: '',
    direction: '',
    uniform: '',
    datetime: new Date().toISOString().slice(0, 16),
    equipment: '',
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(formData);
  };

  const handleChange = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  return (
    <div className="w-full max-w-md bg-card border border-primary/30 rounded-t-3xl shadow-2xl overflow-hidden">
      {/* Header */}
      <div className="relative px-6 py-5 bg-primary/10 border-b border-primary/30">
        <div className="relative flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-primary/20 rounded-full">
              <Music2 className="w-5 h-5 text-primary" />
            </div>
            <h2 className="text-xl text-white" style={{ fontFamily: 'var(--font-display)' }}>
              New Observation
            </h2>
          </div>
          <button
            onClick={onCancel}
            className="p-2 hover:bg-primary/20 rounded-full transition-colors duration-200"
          >
            <X className="w-5 h-5 text-white" />
          </button>
        </div>
      </div>

      {/* Form */}
      <form onSubmit={handleSubmit} className="p-6 space-y-4 max-h-[70vh] overflow-y-auto">
        {/* Location - First and prominent */}
        <div className="space-y-2 p-4 bg-primary/10 rounded-xl border border-primary/30">
          <label className="flex items-center gap-2 text-sm text-white font-medium">
            <MapPin className="w-5 h-5 text-primary" />
            Location / Venue Name
          </label>
          <input
            type="text"
            value={formData.location}
            onChange={(e) => handleChange('location', e.target.value)}
            placeholder="e.g., Coachella Valley, Hyde Park, Central Park"
            className="w-full px-4 py-3 bg-black/50 rounded-xl border border-primary/50 focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/30 transition-all duration-200 text-white placeholder:text-muted-foreground"
            required
          />
          <p className="text-xs text-muted-foreground">Name of the festival, venue, or geographic location</p>
        </div>

        {/* Activity */}
        <div className="space-y-2">
          <label className="flex items-center gap-2 text-sm text-white">
            <Music2 className="w-4 h-4 text-primary" />
            Activity / Performance
          </label>
          <input
            type="text"
            value={formData.activity}
            onChange={(e) => handleChange('activity', e.target.value)}
            placeholder="e.g., Main stage performance, DJ set"
            className="w-full px-4 py-3 bg-input rounded-xl border border-primary/30 focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/20 transition-all duration-200 text-white placeholder:text-muted-foreground"
            required
          />
        </div>

        {/* Size/Strength */}
        <div className="space-y-2">
          <label className="flex items-center gap-2 text-sm text-white">
            <Users className="w-4 h-4 text-primary" />
            Crowd Size / Energy
          </label>
          <input
            type="text"
            value={formData.size}
            onChange={(e) => handleChange('size', e.target.value)}
            placeholder="e.g., 500-1000 people, high energy"
            className="w-full px-4 py-3 bg-input rounded-xl border border-primary/30 focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/20 transition-all duration-200 text-white placeholder:text-muted-foreground"
            required
          />
        </div>

        {/* Direction */}
        <div className="space-y-2">
          <label className="flex items-center gap-2 text-sm text-white">
            <Compass className="w-4 h-4 text-primary" />
            Movement / Direction
          </label>
          <input
            type="text"
            value={formData.direction}
            onChange={(e) => handleChange('direction', e.target.value)}
            placeholder="e.g., Moving towards food area"
            className="w-full px-4 py-3 bg-input rounded-xl border border-primary/30 focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/20 transition-all duration-200 text-white placeholder:text-muted-foreground"
            required
          />
        </div>

        {/* Uniform/Clothes */}
        <div className="space-y-2">
          <label className="flex items-center gap-2 text-sm text-white">
            <Shirt className="w-4 h-4 text-primary" />
            Attire / Style
          </label>
          <input
            type="text"
            value={formData.uniform}
            onChange={(e) => handleChange('uniform', e.target.value)}
            placeholder="e.g., Festival wristbands, vintage band tees"
            className="w-full px-4 py-3 bg-input rounded-xl border border-primary/30 focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/20 transition-all duration-200 text-white placeholder:text-muted-foreground"
            required
          />
        </div>

        {/* Date/Time */}
        <div className="space-y-2">
          <label className="flex items-center gap-2 text-sm text-white">
            <Clock className="w-4 h-4 text-primary" />
            Date & Time
          </label>
          <input
            type="datetime-local"
            value={formData.datetime}
            onChange={(e) => handleChange('datetime', e.target.value)}
            className="w-full px-4 py-3 bg-input rounded-xl border border-primary/30 focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/20 transition-all duration-200 text-white"
            required
          />
        </div>

        {/* Equipment/Weapons */}
        <div className="space-y-2">
          <label className="flex items-center gap-2 text-sm text-white">
            <Mic2 className="w-4 h-4 text-primary" />
            Equipment / Gear
          </label>
          <textarea
            value={formData.equipment}
            onChange={(e) => handleChange('equipment', e.target.value)}
            placeholder="e.g., Pro cameras, recording equipment, light sticks"
            rows={3}
            className="w-full px-4 py-3 bg-input rounded-xl border border-primary/30 focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/20 transition-all duration-200 resize-none text-white placeholder:text-muted-foreground"
            required
          />
        </div>

        {/* Buttons */}
        <div className="flex gap-3 pt-4">
          <button
            type="button"
            onClick={onCancel}
            className="flex-1 px-6 py-3 bg-muted hover:bg-muted/80 rounded-xl transition-all duration-200 text-white"
          >
            Cancel
          </button>
          <button
            type="submit"
            className="flex-1 px-6 py-3 bg-primary hover:bg-primary/90 hover:shadow-lg hover:shadow-primary/50 text-black rounded-xl transition-all duration-200 hover:scale-105 font-medium"
          >
            Save Pin
          </button>
        </div>
      </form>
    </div>
  );
}
