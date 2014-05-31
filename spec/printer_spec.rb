require 'spec_helper'

describe FakedCSV::Printer do
    it "returns csv as string" do
        generator = FakedCSV::Generator.new FakedCSV::Config.new JSON.parse File.read 'spec/data/rotate.csv.json'
        generator.generate
        printer = FakedCSV::Printer.new(generator.headers, generator.rows)
        s = printer.print
        s.include?("faker no rotate,").should == true
        s.include?(",rand int with rotate and inject").should == true
        s.include?("13").should == true
        s.include?("aaa").should == true
        s.include?("bbb").should == true
    end
end