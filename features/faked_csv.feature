Feature: faked_csv CLI program

Scenario: Show help message
    When I run `faked_csv -h`
    Then the output should contain "Usage: faked_csv -i <input.csv.json> -o <output.csv>"

Scenario: Show version
    When I run `faked_csv --version`
    Then the output should contain "version:"

Scenario: Generate basic csv
    When I run `faked_csv -i ../../spec/data/basic.csv.json -o output.csv`
    Then the output should contain exactly ""
    And the file "output.csv" should contain "ID,First Name,Last Name,City,State,Age,Height"

Scenario: Generate basic csv into default output file
    When I run `faked_csv -i ../../spec/data/basic.csv.json`
    Then the output should contain exactly ""
    And the file "faked.csv" should contain "ID,First Name,Last Name,City,State,Age,Height"

Scenario: Find no default files
    When I run `faked_csv`
    Then the output should contain "error openning the input source: No such file or directory"
    And the output should contain "./faked.csv.json"

Scenario: Getting from HTTP
    When I run `faked_csv -i http://goo.gl/xDtkJs -o remote.csv`
    Then the output should contain exactly ""
    And the file "remote.csv" should contain "ID,First Name,Last Name,City,State,Age,Height"