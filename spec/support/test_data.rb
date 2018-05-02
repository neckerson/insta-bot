module TestData

  def fixture_file(filename)
    File.join(File.dirname(__FILE__), 'fixtures', filename)
  end

end
