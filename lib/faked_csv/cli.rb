require 'optparse'
require 'json'
require 'open-uri'
require 'open_uri_redirections'
require 'faked_csv'

module FakedCSV
    class CLI
        def self.start(args)
            options = {}
            OptionParser.new do |opts|
                opts.banner = "Usage: faked_csv -i <input.csv.json> -o <output.csv>"
                opts.on("-i", "--input JSON", "input path to json configuration file. default: ./faked.csv.json") do |input|
                    options[:input] = input
                end
                opts.on("-o", "--output CSV", "output path to csv file. default: ./faked.csv") do |output|
                    options[:output] = output
                end
                opts.on("-v", "--version", "print version message") do
                    puts "version: #{VERSION}"
                    return
                end
            end.parse!(args)

            options[:input] = './faked.csv.json' unless options.has_key? :input

            json = nil
            begin
                if options[:input] =~ /^http/
                    # remote resouce
                    open(options[:input], allow_redirections: :all) do |f|
                        arr = []
                        f.each_line {|line| arr << line}
                        json = arr.join("\n")
                    end
                else
                    # normal file
                    json = File.read options[:input]
                end
            rescue Exception=>e
                puts "error openning the input source: #{e.to_s}"
                exit 1
            end

            generator = FakedCSV::Generator.new FakedCSV::Config.new JSON.parse json
            generator.generate
            printer = FakedCSV::Printer.new(generator.headers, generator.rows)
            s = printer.print

            unless options.has_key? :output
                puts s
                return
            end

            begin
                File.open options[:output], 'w' do |f|
                    f.write s
                end
            rescue Exception=>e
                puts "error writing to csv file: #{e.to_s}"
                exit 2
            end
        end
    end
end