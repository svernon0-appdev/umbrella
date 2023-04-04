# Initiate methods
require "open-uri"
require "json"

# Set tokens

gmaps_token = ENV.fetch("GMAPS_KEY")
pirate_token = ENV.fetch("PIRATE_WEATHER_KEY")

# Header for program

puts "=" * 40
puts "    Will you need an umbrella today?    "
puts "=" * 40

# Request User Location

puts "Where are you located?"

user_location = gets.chomp

puts "Checking the weather at #{user_location}..."

# Convert location to lat/lng using Google Maps API

  # Search for location

  gmaps_api_endpoint = "https://maps.googleapis.com/maps/api/geocode/json?address=#{user_location}&key=#{gmaps_token}"

  # Store response and parse lat/lng

  raw_response = URI.open(gmaps_api_endpoint).read

  parsed_response = JSON.parse(raw_response)

  results_array = parsed_response.fetch("results")

  first_result = results_array.at(0)

  geometry = first_result.fetch("geometry")

  location = geometry.fetch("location")

  latitude = location.fetch("lat")
  longitude = location.fetch("lng")

# Insert latitude and longitude into Pirate Weather

  # Create API Endpoint

  pirate_api_endpoint = "https://api.pirateweather.net/forecast/#{pirate_token}/#{latitude},#{longitude}"

  # Pull response from pirate weather

  pirate_raw_response = URI.open(pirate_api_endpoint).read

  pirate_parsed_response = JSON.parse(pirate_raw_response)

    # Check current temperature

    current_pirate_response = pirate_parsed_response.fetch("currently")

    current_temperature = current_pirate_response.fetch("temperature")

    current_time = current_pirate_response.fetch("time")

    # Print current weather results

    puts "It is currently #{current_temperature}°F."

    # Hourly summary

    minute_pirate_response = pirate_parsed_response.fetch("minutely", nil)

    if minute_pirate_response != nil
      hourly_weather = minute_pirate_response.fetch("summary")

      puts "Next hour: #{hourly_weather}"
    end

    # Check upcoming weather

      # Pull hourly weather

      hourly_pirate_response = pirate_parsed_response.fetch("hourly")

      hourly_pirate_response_data = hourly_pirate_response.fetch("data")

      precip_true = false

      hourly_pirate_response_data.each do |hour|
        hours_in_future = (hour.fetch("time").to_i - current_time.to_i)/3600.0
        prob_precip = hour.fetch("precipProbability")*100
        if hours_in_future <= 12 && hours_in_future >=0
          if prob_precip > 10
            puts "In #{hours_in_future.round} hours, there is a #{prob_precip.round}% chance of precipitation."
            precip_true = prob_precip > 10
          end
        end
      end

      if precip_true
        puts "You might want to take an umbrella!"
      else
        puts "You probably won't need an umbrella today."
      end
