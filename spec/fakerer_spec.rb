require 'spec_helper'

describe FakedCSV::Fakerer do
    it "validates input type" do
        FakedCSV::Fakerer.new("faker:name:last_name").fake.size.should > 1
    end

    it "invalidates input type: class" do
        raised = false
        begin
            f = FakedCSV::Fakerer.new("faker:name1:last_name")
        rescue
            raised = true
        end
        raise "not raised invalid faker class" unless raised
    end

    it "invalidates input type: method" do
        raised = false
        f = FakedCSV::Fakerer.new("faker:name:last_name1")
        begin
            f.fake_single
        rescue
            raised = true
        end
        raise "not raised invalid faker method" unless raised
    end
end