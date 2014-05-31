require 'spec_helper'

describe FakedCSV::Generator do
    it "generates rand char" do
        FakedCSV::Generator.rand_char(1).size.should == 1
        FakedCSV::Generator.rand_char(10).size.should == 10
        FakedCSV::Generator.rand_char(100).size.should == 100
    end

    it "generates rand int" do
        1000.times do
            i = FakedCSV::Generator.rand_int(0, 10)
            i.should <= 10
            i.should >= 0
        end
        FakedCSV::Generator.rand_int(0, 0).should == 0
        raised = false
        begin
            FakedCSV::Generator.rand_int(1, 0).should == 0
        rescue
            raised = true
        end
        raise "not raised the min > max exception" unless raised
        1000.times do
            i = FakedCSV::Generator.rand_int(-10, 0)
            i.should <= 0
            i.should >= -10
        end
    end

    it "generates rand float" do
        1000.times do
            i = FakedCSV::Generator.rand_float(0, 10, 2)
            i.should <= 10
            i.should >= 0
        end
        FakedCSV::Generator.rand_float(0, 0, 0).should == 0
        raised = false
        begin
            FakedCSV::Generator.rand_float(1, 0, 2).should == 0
        rescue
            raised = true
        end
        raise "not raised the min > max exception" unless raised
        1000.times do
            i = FakedCSV::Generator.rand_float(-10, 0, 10)
            i.should <= 0
            i.should >= -10
        end
    end

    it "generates faker data" do
        FakedCSV::Generator.fake("faker:name:last_name").size.should > 1
    end

    it "prepare values for rotate fields" do
        generator = FakedCSV::Generator.new FakedCSV::Config.new JSON.parse File.read 'spec/data/rotate.csv.json'
        generator.prepare_values
        f = generator.config.fields
        f[0].should == {:name=>"faker no rotate", :type=>"faker:name:first_name"}
        f[1][:rotate].should == 10
        f[1][:values].size.should == 10
        f[2][:rotate].should == 10
        f[2][:values].size.should == 10
        f[2][:inject].should == ["aaa", "bbb"]
        f[3].should == {:name=>"rand int no rotate", :type=>:rand_int, :min=>0, :max=>100}
        f[4][:rotate].should == 10
        f[4][:values].size.should == 10
        f[5][:rotate].should == 10
        f[5][:values].size.should == 10
        f[5][:inject].should == [11, 12, 13]
    end

    it "generates random data" do
        generator = FakedCSV::Generator.new FakedCSV::Config.new JSON.parse File.read 'spec/data/rotate.csv.json'
        generator.generate
        f = generator.config.fields
        f[0][:data].size.should == 10
        f[1][:data].size.should == 10
        f[1][:data].each do |d|
            f[1][:values].include?(d).should == true
        end
        f[2][:data].each do |d|
            (f[2][:values].include?(d) || f[2][:values].include?(d)).should == true
        end
        f[3][:data].size.should == 10
        f[4][:data].size.should == 10
        f[4][:data].each do |d|
            f[4][:values].include?(d).should == true
        end
        f[5][:data].each do |d|
            (f[5][:values].include?(d) || f[5][:values].include?(d)).should == true
        end
    end

    it "provides data as rows" do
        generator = FakedCSV::Generator.new FakedCSV::Config.new JSON.parse File.read 'spec/data/rotate.csv.json'
        generator.generate
        rows = generator.rows
        rows.size.should == 10
        rows.each do |row|
            row.size.should == 6
        end
    end
end