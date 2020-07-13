require 'minitest/autorun'
require 'dost'

class DOSTTest < Minitest::Test
  def setup
    lines = [
      '=======================================================',
      'FUU    BAR   SOMEVERYLONG   FIRST           ONEFIRST   ',
      '             FIELD          SMALLERTHAN2 TWO    SECOND ',
      '-------------------------------------------------------',
      '11     22    200000000000   400000000000 600000 7000000',
      '111    220   300000000000   500000000000 800    9000000',
      '======================================================='
    ]
    @dost_data = DOST::Data.new(
      lines: lines,
      headers_delimiters: ['=', '-'],
      values_delimiters: ['-', '=']
    )
  end

  def test_headers
    assert_equal [
      [:FUU, 0..6],
      [:BAR, 7..12],
      [:SOMEVERYLONG_FIELD, 13..27],
      [:FIRST_SMALLERTHAN2, 28..40],
      [:ONEFIRST_TWO, 41..47],
      [:ONEFIRST_SECOND, 48..54]
    ], @dost_data.headers
  end

  def test_values
    assert_equal [
      {
        FUU: '11',
        BAR: '22',
        SOMEVERYLONG_FIELD: '200000000000',
        FIRST_SMALLERTHAN2: '400000000000',
        ONEFIRST_TWO: '600000',
        ONEFIRST_SECOND: '7000000'
      },
      {
        FUU: '111',
        BAR: '220',
        SOMEVERYLONG_FIELD: '300000000000',
        FIRST_SMALLERTHAN2: '500000000000',
        ONEFIRST_TWO: '800',
        ONEFIRST_SECOND: '9000000'
      }
    ], @dost_data.values
  end
end
