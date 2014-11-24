json.array!(@feedbacks) do |feedback|
  json.extract! feedback, :id, :title, :details, :status, :address, :latitude, :longitude, :detailed_location, :last_acted_at, :reported_by
  json.url feedback_url(feedback, format: :json)
end
