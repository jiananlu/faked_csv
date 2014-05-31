module FakedCSV
    class Generator
        attr_reader :config, :rows

        def initialize(config)
            @config = config
        end

        def headers
            @config.headers
        end

        def rows
            return @rows unless @rows.nil?
            @rows = []
            (0...@config.row_count).each do |r|
                row = []
                @config.fields.each do |field|
                    row << field[:data][r]
                end
                @rows << row
            end
            @rows
        end

        def generate
            prepare_values

            @config.fields.each do |field|
                field[:data] = []

                # let's get some data!
                if field[:rotate].nil? || field[:type] == :fixed
                    # not rotating? generate random value each time
                    @config.row_count.times do
                        field[:data] << _random_value(field)
                    end
                else
                    # rotating? pick from prepared values
                    used_indexes = {}
                    _randomize_lengths(@config.row_count, field[:rotate]) do |index, length|
                        length.times do
                            rand_index = rand(@config.row_count)
                            _loop do
                                break unless used_indexes.has_key? rand_index
                                rand_index = rand(@config.row_count)
                            end
                            field[:data][rand_index] = field[:values][index]
                            used_indexes[rand_index] = true
                        end
                    end
                end
            end
        end

        def prepare_values
            @config.fields.each do |field|
                # if it's fixed values or no rotate
                # we don't want to prepare values for this field
                if field[:type] == :fixed || field[:rotate].nil?
                    next
                end

                # we don't have enough integers for the rotate
                if field[:type] == :rand_int && field[:rotate] > field[:max] - field[:min] + 1
                    raise "rotate should not be greater than the size of the range"
                end

                values = {}
                # let's first inject all user values if given
                unless field[:inject].nil?
                    field[:inject].each do |inj|
                        values[inj] = true
                    end
                end
                # then generate as many data as we need
                _loop do
                    # we want to get <rotate> unique values. stop when we got enough
                    break if values.size >= field[:rotate]
                    v = _random_value(field)
                    values[v] = true
                end
                field[:values] = values.keys
            end
        end

        # divide total into <parts> parts and feed to yield each time
        def _randomize_lengths(total, parts)
            indexes = {}
            parts.times do
                index = rand(total)
                _loop do
                    break unless indexes.has_key? index
                    index = rand(total)
                end
                indexes[index] = true
            end
            indexes[total] = true # add the last boundary
            cuts = indexes.keys.sort
            (0...cuts.size - 1).each_with_index do |idx, c|
                length = cuts[c + 1] - cuts[c]
                yield(idx, length)
            end
        end

        def _random_value(field)
            case field[:type]
            when :rand_int
                return Generator.rand_int field[:min], field[:max]
            when :rand_float
                return Generator.rand_float field[:min], field[:max], field[:precision]
            when :rand_char
                return Generator.rand_char field[:length]
            when :fixed
                return field[:values].sample
            else # faker
                return Generator.fake field[:type]
            end
        end

        def _loop
            max_attempts = 1000_000_000_000
            i = 0
            (0...max_attempts).each do |j|
                yield
                i += 1
            end
            raise "max attempts reached" if i == max_attempts
        end

        ## individual random generators

        def self.rand_char(length)
            o = [('a'..'z'), ('A'..'Z'), (0..9)].map { |i| i.to_a }.flatten
            string = (0...length).map { o[rand(o.length)] }.join
        end

        def self.rand_int(min, max)
            raise "min > max" if min > max
            min + rand(max - min + 1)
        end

        def self.rand_float(min, max, precision)
            raise "min > max" if min > max
            (rand * (max - min) + min).round(precision)
        end

        def self.fake(type)
            Fakerer.new(type).fake
        end
    end
end