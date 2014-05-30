require 'spec_helper'

describe FakedCSV::Config do
    it "parsed the basic json config" do
        config = JSON.parse File.read 'spec/data/basic.csv.json'
    end
end