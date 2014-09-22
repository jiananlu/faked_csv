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
                opts.on("-o", "--output CSV", "output path to csv file. if omit, print to output.csv") do |output|
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

            out_file_name = options.has_key?(:output) ? options[:output] : 'output.csv'
            puts "printing to file: #{out_file_name} ..."
            File.open(out_file_name, 'w') do |file|
                generator.print_to file
            end
        end
    end
end