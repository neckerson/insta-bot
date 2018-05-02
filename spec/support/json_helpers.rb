module JsonHelpers

  def get_json
    file = File.open fixture_file("json"), "rb"
    contents = file.read
    JSON.parse(contents)
  end

end
