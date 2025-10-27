class DistanceService
  # Calculate distance between two points using Haversine formula
  EARTH_RADIUS_KM = 6371.0

  class << self
    def calculate(lat1, lon1, lat2, lon2)
      return nil if [lat1, lon1, lat2, lon2].any?(&:nil?)

      # Convert to radians
      lat1_rad = to_radians(lat1)
      lat2_rad = to_radians(lat2)
      delta_lat = to_radians(lat2 - lat1)
      delta_lon = to_radians(lon2 - lon1)

      # Haversine formula
      a = Math.sin(delta_lat / 2)**2 +
          Math.cos(lat1_rad) * Math.cos(lat2_rad) *
          Math.sin(delta_lon / 2)**2

      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

      # Distance in kilometers
      distance = EARTH_RADIUS_KM * c

      distance.round(2)
    end

    def nearby_users(users, center_lat, center_lon, radius_km = 20)
      users.select do |user|
        next unless user.latitude && user.longitude

        distance = calculate(center_lat, center_lon, user.latitude, user.longitude)
        distance && distance <= radius_km
      end
    end

    private

    def to_radians(degrees)
      degrees * Math::PI / 180
    end
  end
end
