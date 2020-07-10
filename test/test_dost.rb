require 'minitest/autorun'
require 'dost'

class DOSTTest < Minitest::Test
  def setup
    lines = [
      '=========================',
      'FUU    BAR   SOMEVERYLONG',
      '             FIELD       ',
      '-------------------------',
      '11     22    200000000000',
      '111    220   300000000000',
      '========================='
    ]
    @dost_data = DOST::Data.new(
      lines: lines,
      headers_delimiters: ['=', '-'],
      values_delimiters: ['-', '=']
    )
  end

  def test_headers
    assert_equal [[:fuu, 0..6], [:bar, 7..12], [:someverylong, 13..24]],
      @dost_data.headers
  end

  def test_values
    assert_equal [{:fuu=>"11", :bar=>"22", :someverylong=>"200000000000"}, {:fuu=>"111", :bar=>"220", :someverylong=>"300000000000"}],
      @dost_data.values
  end
end
