require 'spec_helper'

describe FakedCSV::Config do
    it "parses the basic json config" do
        json = JSON.parse File.read 'spec/data/basic.csv.json'
        config = FakedCSV::Config.new json
        config.config["rows"].should == 200
        config.parse
        config.row_count.should == 200
        config.fields.should == [
            {:name=>"ID", :type=>:rand_char, :length=>5},
            {:name=>"First Name", :type=>:fixed, :values=>["Peter", "Tom", "Jane", "Tony", "Steve", "John"]},
            {:name=>"Last Name", :type=>"faker:name:last_name", :inject=>["Lu", "Smith"]},
            {:name=>"City", :type=>"faker:address:city", :rotate=>40},
            {:name=>"State", :type=>"faker:address:state_abbr", :inject=>["CA"], :rotate=>10},
            {:name=>"Age", :type=>:rand_int, :min=>10, :max=>80},
            {:name=>"Height", :type=>:rand_float, :inject=>[200, 210], :rotate=>20, :min=>150, :max=>190, :precision=>2}
        ]
    end

    it "provides fields headers" do
        json = JSON.parse File.read 'spec/data/basic.csv.json'
        config = FakedCSV::Config.new json
        config.headers.should == ["ID", "First Name", "Last Name", "City", "State", "Age", "Height"]
    end
end