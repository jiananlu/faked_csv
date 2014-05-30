# Faking CSV data made easy

faked_csv, using the awesome [Faker](https://github.com/stympy/faker) gem, helps you to generate fake random data in your specified way. You may find it particularly useful when using the generated CSV in testing.

## Installation

```
gem install faked_csv
```

Test your installation by running the following command in your terminal/console:

```
faked_csv --version
```

You can also install the gem using bundler.

The gem is developed and tested under Ruby 2.1.

## Usage

For each faked CSV file, you first create a `<name>.csv.json` file that contains the configuration of how you want to generate the faked data, as hinted by the name, in `json` format.

## Example

A simple example `.csv.json` file looks like the following. Noted, JSON file doesn't support inline comment, so the below example is only for illustration. You can use the `example.csv.json` file in the root folder of the source code as a boilerplate.

```
{
  "rows": 200, <-- the rows of the generated csv
  "fields": {  <-- all the fields/columns of the generated csv
    "First Name": {  <-- the field/column name
      "type": "fixed",  <-- this means only the given values will be used
      "values": ["Peter", "Tom", "Jane", "Tony", "Steve", "John"]
    },
    "Last Name": {
      "type": "faker:name:last_name" <-- the random data format
      "values": ["Smith", "Lu"]  <-- "must-have" will appear at least once
    },
    "City": {
      "type": "faker:address:city",
      "count": "rows/2" <-- how many choices/unique data for random process.
                            in this case there will be 100 random fake cities as values 
                            for the City field in the csv file.
    },
    "State": {
      "type": "faker:address:state_abbr",
      "count": 10 <-- you can also use an absolute value as the count
    },
    "Age": {
      "type": "rand:int", <-- random integers in the following range
      "range": [10, 80] <-- the min will be 10, the max will be 80.
                            meaning end potins are included
    },
    "Height": {
      "type": "rand:float", <-- random floats in the following range
      "range": [150, 190],
      "precision": 3 <-- the precision of the float number
    }
  }
}
```

With the `.csv.json` file, now you can generate a random CSV by invoking the following command:

```
faked_csv -i example.csv.json -o example.csv
```

The output CSV looks something like:

```
First Name,Last Name,City,State,Age,Height
Tony,Leffler,O'Keefeshire,MN,47,155.494
Steve,Pagac,North Rafaela,OR,29,160.008
Peter,Lu,Paytonfort,NM,10,160.459
Steve,Bergstrom,Port Janie,MN,42,169.456
John,Balistreri,Paytonfort,FL,34,152.857
Tom,Boyle,Port Janie,NV,12,189.016
Tony,Smith,Schummburgh,NV,26,175.747
Tony,Bergnaum,O'Keefeshire,NV,44,153.617
Steve,Luettgen,O'Keefeshire,VA,63,159.235
John,Gerhold,Port Janie,IN,35,185.655
......
```

## Options

`-i` to specify the input json configuration file. If omitted, the program will try to find `./faked.csv.json` by default.

`-o` to specify the output CSV file path. If omitted, the program will print the data to stdout.

## Contributing

1. Fork it ( https://github.com/jiananlu/faked_csv/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
