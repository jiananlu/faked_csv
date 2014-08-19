require 'spec_helper'

describe FakedCSV::Generator do
    it "generates rand char" do
        FakedCSV::Generator.rand_char(1).size.should == 1
        FakedCSV::Generator.rand_char(10).size.should == 10
        FakedCSV::Generator.rand_char(100).size.should == 100
    end

    it "generates single rand char with format" do
        ('A'..'Z').to_a.include?(FakedCSV::Generator.single_rand_char('W')).should == true
        ('a'..'z').to_a.include?(FakedCSV::Generator.single_rand_char('w')).should == true
        (0..9).to_a.include?(FakedCSV::Generator.single_rand_char('d')).should == true
        [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten.include?(FakedCSV::Generator.single_rand_char('D')).should == true
        [('a'..'z'), ('A'..'Z'), (0..9)].map { |i| i.to_a }.flatten.include?(FakedCSV::Generator.single_rand_char('@')).should == true
    end

    it "generates rand chars with format" do
        a = FakedCSV::Generator.rand_formatted_char("123/w123")
        a.size.should == 7
        ('a'..'z').to_a.include?(a[3]).should == true

        a = FakedCSV::Generator.rand_formatted_char("/W/w/d/D/@")
        a.size.should == 5

        a = FakedCSV::Generator.rand_formatted_char("0014000000/@/@/@/@/@/W/W/W")
        a.size.should == 18
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

    it "generates random data from basic csv" do
        generator = FakedCSV::Generator.new FakedCSV::Config.new JSON.parse File.read 'spec/data/basic.csv.json'
        generator.generate
        f = generator.config.fields
        f.each{|ff| ff[:data].size.should == 200}
        f[0][:data].each{|d|d.size.should == 5}
        f[1][:data].each do |d|
            f[1][:values].include?(d).should == true
        end
        f[1][:data].uniq.size.should == f[1][:values].size
        f[2][:inject].each do |inj|
            f[2][:data].include?(inj).should == true
        end
        f[3][:data].uniq.size.should == 40
        f[4][:data].uniq.size.should == 10
        f[4][:data].include?("CA").should == true
        f[5][:data].each do |d|
            d.kind_of?(Integer).should == true
            (d >= 10 && d <= 80).should == true
        end
        f[6][:data].uniq.size.should == 20
        f[6][:data].include?(200).should == true
        f[6][:data].include?(210).should == true
        f[6][:data].each do |d|
            ((d >= 150 && d <= 190) || d == 200 || d == 210).should == true
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

    it "handles inject without rotate" do
        generator = FakedCSV::Generator.new FakedCSV::Config.new JSON.parse File.read 'spec/data/inject.csv.json'
        generator.generate
        generator.config.fields[0][:data].include?("aa").should == true
        generator.config.fields[0][:data].include?("bb").should == true
    end

    it "increments integers" do
        generator = FakedCSV::Generator.new FakedCSV::Config.new JSON.parse File.read 'spec/data/increment.csv.json'
        generator.generate
        generator.config.fields[0][:data].should == [3, 5, 7, 9, 11]
        generator.config.fields[1][:data].should == [1, 2, 3, 4, 5]
    end
end