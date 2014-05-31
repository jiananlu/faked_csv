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
                    # not rotating? or fixed values? generate random value each time
                    @config.row_count.times do
                        field[:data] << _random_value(field)
                    end

                    # inject user values if given and not fixed type
                    unless field[:type] == :fixed || field[:inject].nil?
                        _random_inject(field[:data], field[:inject])
                    end
                else
                    # rotating? pick from prepared values
                    _random_distribution(@config.row_count, field[:values].size) do |i, j|
                        field[:data][i] = field[:values][j]
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
                        # truncate more inject values if we go over the rows count
                        break if values.size == @config.row_count
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

        def _random_distribution(total, parts)
            raise "parts has to be greater than 0" unless parts > 0
            raise "parts should not be greater than total" if total < parts
            cuts = {}
            _loop do
                break if cuts.size == parts - 1
                cuts[rand(total - 1)] = true
            end
            arr = []
            part_index = 0
            (0...total).each do |i|
                arr << part_index
                part_index += 1 if cuts.has_key? i
            end
            arr.shuffle.each_with_index do |v, i|
                yield(i, v)
            end
        end

        # inject <injects> into <values>
        def _random_inject(values, injects)
            used_indexes = {}
            count = injects.size > values.size ? values.size : injects.size
            (0...count).each do |i|
                inj = injects[i]
                times_inject = rand(values.size / injects.size / 10)
                times_inject = 1 if times_inject < 1
                times_inject.times do
                    rand_index = rand(values.size)
                    _loop do
                        break unless used_indexes.has_key? rand_index
                        rand_index = rand(values.size)
                    end
                    used_indexes[rand_index] = true
                    values[rand_index] = inj
                end
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