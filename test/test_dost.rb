require 'minitest/autorun'
require 'dost'

class DOSTTest < Minitest::Test
  extend MiniTest::Spec::DSL

  let(:lines) do
    [
      '=======================================================',
      'FUU.   BAR#  SOMEVERYLONG   FIRST           ONEFIRST   ',
      '             FIELD          SMALLERTHAN2 TWO    SECOND ',
      '-------------------------------------------------------',
      '11     22    200000000000   400000000000 600000 7000000',
      '111    220   300000000000   500000000000 800    9000000',
      '111          FOO            BAR          FUBAR?        ',
      '======================================================='
    ]
  end

  let(:headers_delimiters) { ['=', '-'] }
  let(:values_delimiters) { ['-', '='] }
  let(:key_modifier) { ->(key) { key.strip.gsub(/(\W)/, '').to_sym } }
  let(:subject) {
    DOST::Data.new(
      lines: lines,
      headers_delimiters: headers_delimiters,
      values_delimiters: values_delimiters,
      key_modifier: key_modifier
    )
  }

  describe '#headers' do
    let(:expected) do
      [
        [:FUU, 0..6],
        [:BAR, 7..12],
        [:SOMEVERYLONG_FIELD, 13..27],
        [:FIRST_SMALLERTHAN2, 28..40],
        [:ONEFIRST_TWO, 41..47],
        [:ONEFIRST_SECOND, 48..54]
      ]
    end

    it 'should return correct headers' do
      assert_equal(expected, subject.headers)
    end
  end

  describe '#values' do
    let(:expected) do
      [
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
        },
        {
          FUU: '111',
          BAR: '',
          SOMEVERYLONG_FIELD: 'FOO',
          FIRST_SMALLERTHAN2: 'BAR',
          ONEFIRST_TWO: 'FUBAR?',
          ONEFIRST_SECOND: ''
        }
      ]
    end

    it 'should return correct values' do
      assert_equal(expected, subject.values)
    end
  end

  describe '#dynamic_offseted_values' do
    let(:lines) do
      [
        '==================================',
        'SOMELONG   TIME  SOMEADDRESS  SOME',
        'NAME              FROM TO      ID ',
        '----------------------------------',
        'USUAL NAME 01:11   P1  P2      #1 ',
        'LONG [NAME]02:22   P2 P33    #222 ',
        '=================================='
      ]
    end

    let(:expected) do
      [
        {
          SOMELONG_NAME: 'USUAL NAME',
          TIME: '01:11',
          SOMEADDRESS_FROM: 'P1',
          SOMEADDRESS_TO: 'P2',
          SOME_ID: '#1'
        },
        {
          SOMELONG_NAME: 'LONG [NAME]',
          TIME: '02:22',
          SOMEADDRESS_FROM: 'P2',
          SOMEADDRESS_TO: 'P33',
          SOME_ID: '#222'
        }
      ]
    end

    it 'should correct parse dynamic some_id and someaddress_to fields' do
      assert_equal(expected, subject.dynamic_offseted_values([:SOME_ID, :SOMEADDRESS_TO]))
    end
  end
end
