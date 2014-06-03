[![Build Status](https://travis-ci.org/jiananlu/faked_csv.svg?branch=master)](https://travis-ci.org/jiananlu/faked_csv)

# Faking CSV data made easy

faked_csv, using the awesome [Faker](https://github.com/stympy/faker) gem, helps you to generate CSV file with fake random data in your specified way. You may find it particularly useful in testing something out.

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

A simple example `.csv.json` file looks like the following. Noted, JSON file doesn't support inline comment, so the below example is only for illustration. You can use the `example.csv.json` file in the root folder of the source code as a boilerplate. More details on the configuration file are in later section.

```
{
  "rows": 200, <- how many rows in the generated CSV
  "fields": [  <- a list of fields/columns in the generated CSV
    {
      "name": "ID",        <- field/column name
      "type": "rand:char", <- type/format of the field
      "length": 5          <- 5 characters random word
    },
    {
      "name": "First Name",
      "type": "fixed",     <- values will only come from the below list
      "values": ["Peter", "Tom", "Jane", "Tony", "Steve", "John"]
    },
    {
      "name": "Last Name",
      "type": "faker:name:last_name", <- via Faker::Name.last_name method
      "inject": ["Lu", "Smith"]       <- "must-have" values
    },
    {
      "name": "City",
      "type": "faker:address:city", <- via Faker::Address.city method
      "rotate": "rows/5"            <- rows/5 (=>200/5 =>40) unique values
                                       (and only these values) will appear
    },
    {
      "name": "State",
      "type": "faker:address:state_abbr",
      "rotate": 10,    <- both rotate and inject? will make sure 10 unique 
                          values (including "CA") appear
      "inject": ["CA"]
    },
    {
      "name": "Age",
      "type": "rand:int",
      "range": [10, 80] <- range (including boundaries) for random integers
    },
    {
      "name": "Height",
      "type": "rand:float",
      "range": [150, 190],  <- range for random floats
      "inject": [200, 210], <- "must-have" values. can be any format
      "rotate": 20,         <- 20 unique values (including injects)
      "precision": 2        <- precision of the float numbers
    }
  ]
}
```

With the `<name>.csv.json` file, now you can generate a random CSV by invoking the following command:

```
faked_csv -i example.csv.json -o example.csv
```

The output CSV looks something like:

```
ID,First Name,Last Name,City,State,Age,Height
iW00K,Jane,Bosco,Lake Dandreland,ME,61,170.57
BzxTl,Steve,Smith,Uniqueside,PA,35,152.93
vobj8,Tony,Auer,Tressiestad,MS,63,160.86
X78RS,Steve,Cole,Port Zellachester,OH,72,159.84
0YpWG,John,Lu,East Vernaview,OH,18,200
4JaoZ,Peter,Simonis,Wernerchester,HI,25,161.64
hP48C,Tom,Lu,Uniqueside,ME,45,161.64
WDQpb,John,Casper,East Felicityshire,OH,41,170.57
wyPwB,Jane,Johns,Maggiehaven,CA,16,180.42
VCtYR,Peter,Jast,Schadenberg,ME,41,161.64
1VYOs,John,Daniel,Port Zellachester,HI,34,200
V7pg9,Tom,Mayert,Schadenberg,OH,71,152.93
SmE9w,Jane,Lu,Stephanchester,HI,25,176.95
ALyok,Tom,Smith,Ryanchester,PA,70,176.95
fgE5v,Peter,Bailey,Bednarstad,PA,67,170.24
eBIIM,Peter,Haley,East Vernaview,MS,65,161.64
5sv4L,Peter,Prosacco,Uniqueside,PA,50,178.25
a48IS,Peter,Marvin,Kossview,OH,63,200
9mLcZ,John,VonRueden,East Vernaview,PA,20,174.24
N8ysZ,Tony,Barrows,Wernerchester,HI,62,159.84
PxsfA,John,Lind,East Vernaview,OH,21,182.45
lKM33,Steve,Bosco,South Reese,OH,75,176.95
HR9H5,Jane,Torp,Tressiestad,PA,23,170.57
JTRCw,Steve,Hermann,Kunzefort,MS,43,152.93
Wndzb,Tony,McGlynn,Lake Dandreland,CA,52,160.86
ksmvF,Peter,Rutherford,Josiannetown,PA,12,184.08
cfsBG,Peter,Lebsack,Port Zellachester,OH,43,182.45
7ISEJ,Steve,Altenwerth,Stephanchester,HI,13,159.84
Letb8,John,Frami,South Reese,HI,65,170.57
......
```

## CLI Options

`-i` to specify the input json configuration file. If omitted, the program will try to find `./faked.csv.json` by default. You can also specify a remote URL of the configuration file.

```
faked_csv -i http://goo.gl/xDtkJs -o remote.csv
```

`-o` to specify the output CSV file path. If omitted, the program will print the data to stdout.

## More details on configuration file

`rows` to specify how many rows you want to generate in the output CSV file.

`fields` to specify the list of all fields of the generated CSV file.

```
{
    "rows": 1000,
    "fields": [
        ...
    ]
}
```

For each field, two attributes are required:

`name` to specify the column display name.

`type` to sepcify the format of the data in this column.

Optional attributes help finer control the generated output.

`inject` to specify a list of values that must appear in this column. this is useful when you want to specifically inject some special values into your final CSV. The inject values can be in the same or different format as the type of this column.

`rotate` to specify the number of unique values that will be used in this column. This number will include the number of items you put into `inject` list.

```
"type": "faker:address:state_abbr",
"inject": ["CA", "HI"],
"rotate": 10
```

In the above example, totally 10 states will be considered in the generation process. 2 of them are given by you, i.e. CA and HI; 8 of them will be faked by calling Faker::Address.state_abbr() method. If you specify `rows` to be greater than 10, some values will be repeated, meaning only 10 unique values will appear and these 10 values are ensured to appear at least once. If you specify `rows` less than 10, only `rows` number of unique values will appear; and your `inject` values will have higher priority, meaning if `rows` is 2, then only CA and HI will appear in the final output.

### Supported types

#### rand:int and rand:float

Random integers/floats. The following attributes are available:

`range` to specify the minimum and maximum value that will be generated.

```
"range": [10, 100] <- the min=10 and max=100. 10 and 100 are included.
```

If it's `rand:float`, you can specify `precision` attribute to indicate the digit(s) you want to keep for each of the data.

#### rand:char

Random characters. Only A-Z, a-z and 0-9 will be considered as characters.

`length` to specify how many characters in each of the generated data, e.g. 15 will give you something like `9mLcZHR9H5V7pg9`. This is particularly useful if you want to mimic something like item ID, access token etc.

#### faker:[class]:[method]

This indicates you want to use one of the methods from Faker gem. You can find the list of all methods from [Faker gem's documentation](http://rubydoc.info/github/stympy/faker). Each method is a class name and a method name. Example, `Faker::Internet.url` can be mapped to `faker:internet:url` as a field type in the configuration. As current version, we don't support parameters into the faker method. Future version will add such support.

#### fixed

This indicates you only want to use the provided values in the output. Use `values` as a list to provide the values you want to use. They will be randomly picked independently each time; so no guarantee that every value in the list will be used. If you use `fixed` type, `inject` and `rotate` will be ignored.

## Contributing

1. Fork it ( https://github.com/jiananlu/faked_csv/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
