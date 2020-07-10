### It is prealpha version of package, please do not use it in production if you don't know what are you doing :)

### Description

This is a simple parser of DOST (Dynamic Offset Separated Table).
Now that works only with two line headers, as in example below:

### DOST example

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
Let's assume that `lines` is a array of strings with lines above
```ruby
dost_data = DOST::Data.new(
  lines: lines,
  headers_delimiters: ['=', '-'],
  values_delimiters: ['-', '=']
)

[6] pry(main)> dost_data.headers
=> [[:fuu, 0..6], [:bar, 7..12], [:someverylong, 13..24]]
[7] pry(main)> dost_data.values
=> [{:fuu=>"11", :bar=>"22", :someverylong=>"200000000000"}, {:fuu=>"111", :bar=>"220", :someverylong=>"300000000000"}]
```
