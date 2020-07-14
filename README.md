# DOST

This is a gem for parsing DOST (Dynamic Offset Table) files.

### It is prealpha version of package, please do not use it in production if you don't know what are you doing :)

## Description

This is a parser of DOST (Dynamic Offset Separated Table).

DOST - this is a simple format from [.NET framework](https://docs.microsoft.com/en-us/dotnet/standard/base-types/composite-formatting#alignment-component)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dost'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dost

## Usage

### DOST file example

```txt
=========================
FUU    BAR   SOMEVERYLONG
             FIELD
-------------------------
11     22    200000000000
111    220   300000000000
=========================
```

### How to use

Let's assume that `example.txt` is a file with content from example above
```ruby
lines = File.open('example.txt').read.lines.map(&:chomp)

dost_data = DOST::Data.new(
  lines: lines,
  headers_delimiters: ['=', '-'],
  values_delimiters: ['-', '='],
  key_modifier: ->(key) { key.strip.downcase.to_sym }
)

pry(main)> dost_data.headers
=> [[:fuu, 0..6], [:bar, 7..12], [:someverylong, 13..24]]
pry(main)> dost_data.values
=> [{:fuu=>"11", :bar=>"22", :someverylong=>"200000000000"}, {:fuu=>"111", :bar=>"220", :someverylong=>"300000000000"}]
```

#### Arguments

* lines - Lines from file, usually you can get it by `File.open('example.txt').read.lines.map(&:chomp)`
* headers_delimiters - Array of 2 chars, first define start of headers section, second one - end of header section (delimiter is a line that contain all same symbols except all whitespaces)
* values_delimiters - same as for header but for values
* key_modifier - proc that would be applied for your keys of headers. In our example it work like a `'FUU'.strip.downcase.to_sym`

#### Methods

* `.headers` - returns array of headers with applied key modifier and with range that define position column in the line.


* `.values` - returns array of hashes with applied range to corresponding line

* `.dynamic_offseted_values` - documentation in progress

## Contributing

1. Fork it ( https://github.com/X1ting/dost/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request
