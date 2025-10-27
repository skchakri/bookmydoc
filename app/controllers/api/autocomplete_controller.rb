class Api::AutocompleteController < ApplicationController
  skip_before_action :verify_authenticity_token

  def doctors
    query = params[:q]&.strip

    if query.blank? || query.length < 3
      render json: []
      return
    end

    # Search verified doctors by name
    doctors = User.verified_doctors
                  .where("full_name ILIKE ?", "%#{query}%")
                  .limit(10)
                  .pluck(:id, :full_name, :specialization, :location_city)

    results = doctors.map do |id, name, specialization, city|
      {
        id: id,
        name: name,
        specialization: specialization,
        city: city,
        label: "#{name} - #{specialization}" + (city.present? ? " (#{city})" : "")
      }
    end

    render json: results
  end

  def specializations
    query = params[:q]&.strip

    if query.blank? || query.length < 3
      render json: []
      return
    end

    # Get unique specializations from verified doctors
    specializations = User.verified_doctors
                          .where("specialization ILIKE ?", "%#{query}%")
                          .distinct
                          .pluck(:specialization)
                          .compact
                          .sort
                          .take(10)

    results = specializations.map do |spec|
      {
        value: spec,
        label: spec
      }
    end

    render json: results
  end
end
