describe "fetch commands" do
  after(:each) do
    FileUtils.rm_rf Dir.glob("assets/test")
    FileUtils.rm_rf Dir.glob("metadata/test")
  end
  describe "fetch -h" do
    it "returns help message" do
      expected_message = <<~HELP
        Usage: ./fetch [flag] url...
            -m, --metadata                   Display saved metadata
            -h, --help                       Display usage information
      HELP
      expect(`ENV=test ./fetch -h`).to eq(expected_message)
    end
  end

  describe "fetch %{url}" do
    context "url is not valid" do
      expected_message = "www.yahoo.com is not a valid url, try something else, e.g. https://www.google.com\n"

      it { expect(%x|ENV=test ./fetch www.yahoo.com|).to eq(expected_message) }
    end

    context "url is valid" do

      it {
        system('ENV=test ./fetch https://www.yahoo.com')

        expect(Dir.exist?('assets/test')).to eq(true)
        expect(Dir.exist?('metadata/test')).to eq(true)
      }
    end
  end

  describe "fetch -m %{url}" do
    context "url is not valid" do
      expected_message = "www.yahoo.com is not a valid url, try something else, e.g. https://www.google.com\n"

      it { expect(%x|ENV=test ./fetch -m www.yahoo.com|).to eq(expected_message) }
    end

    context "url is valid but not fetched before" do
      expected_message = "No meta data is found for https://www.yahoo.com\n"

      it { expect(`ENV=test ./fetch -m https://www.yahoo.com`).to eq(expected_message) }
    end

    context "url is valid and fetched before" do
      it {
        system('ENV=test ./fetch https://www.yahoo.com')

        expect(%x|ENV=test ./fetch -m https://www.yahoo.com|).to match(/site.*\nnum_links.*\nimages.*\nlast_fetch/)
      }
    end
  end
end
