module FakedCSV
    class Printer
        def initialize(headers, rows)
            @headers = headers
            @rows = rows
        end

        def print
            s = @headers.join(',') + "\n"
            @rows.each do |row|
                s += row.join(',') + "\n"
            end
            s
        end
    end
end