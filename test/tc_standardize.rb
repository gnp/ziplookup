$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
#
# Copyright (C) 2006 Gregor N. Purdy. All rights reserved.
# This program is free software. It is subject to the same license as Ruby.
#
# [ $Id: $ ]
#

require 'test/unit'
require 'USPS/address'
require 'USPS/zip_lookup'

class StandardizeTest < Test::Unit::TestCase
  def setup
    @zlu = USPS::ZipLookup.new
    if (ARGV.size >= 1) && (ARGV[0] == '-v') # ARGV is a global var, but doesn't use prefix '$'; GO FIGURE!
      @zlu.verbose = true
    end
  end

  def test_error
    address = USPS::Address.new

    address.delivery_address = 'bar'
    address.city = 'splee'
    address.state = 'OH'

    result = @zlu.std_addr(address)
    assert_equal([], result)
  end

  def test_simple_1
    address = USPS::Address.new

    address.delivery_address = '6216 Eddington Drive'
    address.city = 'Liberty Township'
    address.state = 'oh'

    result = @zlu.std_addr(address)
    assert_equal(1, result.size)

    assert_equal('6216 EDDINGTON ST', result[0].delivery_address)
    assert_equal('LIBERTY TOWNSHIP', result[0].city)
    assert_equal('OH', result[0].state)
    assert_equal('45044-9761', result[0].zip_code)
  end

  def test_apartment
    address = USPS::Address.new

    address.delivery_address = '3303 Pine Meadow DR SE #202'
    address.city = 'Kentwood'
    address.state = 'MI'
    address.zip_code = '49512'

    result = @zlu.std_addr(address)
    assert_equal(1, result.size)

    assert_equal('3303 PINE MEADOW DR SE APT 202', result[0].delivery_address)
    assert_equal('KENTWOOD', result[0].city)
    assert_equal('MI', result[0].state)
    assert_equal('49512-8325', result[0].zip_code)
  end

  def test_simple_2
    address = USPS::Address.new

    address.delivery_address = '2701 DOUGLAS AVE'
    address.city = 'DES MOINES'
    address.state = 'IA'
    address.zip_code = '50310'

    result = @zlu.std_addr(address)
    assert_equal(1, result.size)

    assert_equal('2701 DOUGLAS AVE', result[0].delivery_address)
    assert_equal('DES MOINES', result[0].city)
    assert_equal('IA', result[0].state)
    assert_equal('50310-5840', result[0].zip_code)
  end

  def test_multiple
    address = USPS::Address.new

    address.delivery_address = '1670 Broadway'
    address.city = 'Denver'
    address.state = 'CO'
    address.zip_code = '80202'

    result = @zlu.std_addr(address)
    assert(result.size > 1)
  end

end
