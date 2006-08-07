$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'test/unit'
#require 'rubygems'
require 'USPS/address'
#require 'test_includes'

class AddressTest < Test::Unit::TestCase
#  include TestMethods

  def setup
  end

  def test_address
    address = USPS::Address.new

    address.delivery_address = '6216 Eddington'
    address.city = 'Middletown'
    address.zip_code = '45044'

    assert_equal('6216 Eddington', address.delivery_address)
    assert_equal('Middletown', address.city)
    assert_equal('45044', address.zip_code)
  end
end

