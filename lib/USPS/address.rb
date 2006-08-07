=begin
= address.rb
Copyright (C) 2006 Gregor N. Purdy. All rights reserved.

This program is free software. It is subject to the same license as Ruby.

= Classes
* ((<Address>))

= Address

== Synopsis
    require "USPS/ZipLookup"
    require "USPS/Address"
    
    address = USPS::Address.new(delivery_address, city, state)

    zlu = USPS::ZipLookup.new()

    matches = zlu.std_addr(address)

    if matches.size > 0
      printf "\n%d matches:\n", matches.size
      matches.each { |match|
   #     print "-" x 39, "\n"
        print match.to_dump
        print "\n";
      }
   #   print "-" x 39, "\n"
    else
      print "No matches!\n"
    end

== Description

Results from USPS::ZipLookup calls are of this type. 

Class to represent U.S. postal addresses for the purpose of
standardizing via the U.S. Postal Service's web site:

http://www.usps.com/zip4/

BE SURE TO READ AND UNDERSTAND THE TERMS OF USE SECTION IN THE
DOCUMENTATION, WHICH MAY BE FOUND AT THE END OF THIS SOURCE CODE.

== Class Methods

== Instance Methods
--- Address#dump()
--- Address#firm()
--- Address#urbanization()
--- Address#delivery_address()
--- Address#city()
--- Address#state()
--- Address#zip_code()
--- Address#carrier_route()
Detailed information (see the U.S. Postal Service web site for definitions at
L<http://zip4.usps.com/zip4/pu_mailing_industry_def.htm>):
--- Address#county()
Detailed information (see the U.S. Postal Service web site for definitions at
L<http://zip4.usps.com/zip4/pu_mailing_industry_def.htm>):
--- Address#delivery_point()
Detailed information (see the U.S. Postal Service web site for definitions at
L<http://zip4.usps.com/zip4/pu_mailing_industry_def.htm>):
--- Address#check_digit()
Detailed information (see the U.S. Postal Service web site for definitions at
L<http://zip4.usps.com/zip4/pu_mailing_industry_def.htm>):
--- Address#lac_indicator()
Detailed information (see the U.S. Postal Service web site for definitions at
L<http://zip4.usps.com/zip4/pu_mailing_industry_def.htm>):
--- Address#elot_sequence()
Detailed information (see the U.S. Postal Service web site for definitions at
L<http://zip4.usps.com/zip4/pu_mailing_industry_def.htm>):
--- Address#elot_indicator()
Detailed information (see the U.S. Postal Service web site for definitions at
L<http://zip4.usps.com/zip4/pu_mailing_industry_def.htm>):
--- Address#record_type()
Detailed information (see the U.S. Postal Service web site for definitions at
L<http://zip4.usps.com/zip4/pu_mailing_industry_def.htm>):
--- Address#pmb_designator()
Detailed information (see the U.S. Postal Service web site for definitions at
L<http://zip4.usps.com/zip4/pu_mailing_industry_def.htm>):
--- Address#pmb_number()
Detailed information (see the U.S. Postal Service web site for definitions at
L<http://zip4.usps.com/zip4/pu_mailing_industry_def.htm>):
--- Address#default_address()
Detailed information (see the U.S. Postal Service web site for definitions at
L<http://zip4.usps.com/zip4/pu_mailing_industry_def.htm>):
--- Address#early_warning()
Detailed information (see the U.S. Postal Service web site for definitions at
L<http://zip4.usps.com/zip4/pu_mailing_industry_def.htm>):
--- Address#valid()
Detailed information (see the U.S. Postal Service web site for definitions at
L<http://zip4.usps.com/zip4/pu_mailing_industry_def.htm>):

= History
$Id$ 

= TERMS OF USE

BE SURE TO READ AND FOLLOW THE UNITED STATES POSTAL SERVICE TERMS OF USE
PAGE AT C<http://www.usps.gov/disclaimer.html>. IN PARTICULAR, NOTE THAT THEY
DO NOT PERMIT THE USE OF THEIR WEB SITE'S FUNCTIONALITY FOR COMMERCIAL
PURPOSES. DO NOT USE THIS CODE IN A WAY THAT VIOLATES THE TERMS OF USE.

The author believes that the example usage given above does not violate
these terms, but sole responsibility for conforming to the terms of use
belongs to the user of this code, not the author.

= Author

Gregor N. Purdy, C<gregor@focusresearch.com>.

= Copyright

Copyright (C) 2006 Gregor N. Purdy. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Ruby itself.

=end

module USPS

class Address

  @firm = nil
  @urbanization = nil
  @delivery_address = nil
  @city = nil
  @state = nil
  @zip_code = nil
  
  @carrier_route = nil
  @county = nil
  @delivery_point = nil
  @check_digit = nil
  @lac_indicator = nil
  @elot_sequence = nil
  @elot_indicator = nil
  @record_type = nil
  @pmb_designator = nil
  @pmb_number = nil
  @default_address = nil
  @early_warning = nil
  @valid = nil
  
  attr_reader :firm, :urbanization, :delivery_address, :city, :state, :zip_code,
    :carrier_route, :county, :delivery_point, :check_digit, :lac_indicator, :elot_sequence,
    :elot_indicator, :record_type, :pmb_designator, :pmb_number, :default_address, :early_warning,
    :valid
    
  attr_writer :firm, :urbanization, :delivery_address, :city, :state, :zip_code,
    :carrier_route, :county, :delivery_point, :check_digit, :lac_indicator, :elot_sequence,
    :elot_indicator, :record_type, :pmb_designator, :pmb_number, :default_address, :early_warning,
    :valid
    
  @@input_fields = {
    'Firm'             => :firm,
    'Urbanization'     => :urbanization,
    'Delivery Address' => :delivery_address,
    'City'             => :city,
    'State'            => :state,
    'Zip Code'         => :zip_code,
  }

  @@output_fields = {
    'Carrier Route'   => :carrier_route,
    'County'          => :county,
    'Delivery Point'  => :delivery_point,
    'Check Digit'     => :check_digit,
    'LAC Indicator'   => :lac_indicator,
    'eLOT Sequence'   => :elot_sequence,
    'eLOT Indicator'  => :elot_indicator,
    'Record Type'     => :record_type,
    'PMB Designator'  => :pmb_designator,
    'PMB Number'      => :pmb_number,
    'Default Address' => :default_address,
    'Early Warning'   => :early_warning,
    'Valid'           => :valid,
  }
  
  @@field_order = [
    "Firm",
    "Urbanization",
    "Delivery Address",
    "City",
    "State",
    "Zip Code",
    "Carrier Route",
    "County",
    "Delivery Point",
    "Check Digit",
    "LAC Indicator",
    "eLot Sequence",
    "eLot Indicator",
    "Record Type",
    "PMB Designator",
    "PMB Number",
    "Default Address",
    "Early Warning",
    "Valid",
  
  ]

#
# initialize()
#
#
#def initialize(firm, urbanization, delivery_address, city, state, zip_code)
#  @firm = firm
#  @urbanization = urbanization
#  @delivery_address = delivery_address
#  @city = city
#  @state = state
#  @zip_code = zip_code
#end
#
#def initialize(firm, delivery_address, city, state, zip_code)
#  @firm = firm
#  @delivery_address = delivery_address
#  @city = city
#  @state = state
#  @zip_code = zip_code
#end
#
#def initialize(delivery_address, city, state, zip_code)
#  @delivery_address = delivery_address
#  @city = city
#  @state = state
#  @zip_code = zip_code
#end
#
#def initialize(delivery_address, city, state)
#  @delivery_address = delivery_address
#  @city = city
#  @state = state
#end
#
#def initialize(delivery_address, zip_code)
#  @delivery_address = delivery_address
#  @zip_code = zip_code
#end

#
# fields()
#

def fields
  return {
    "Firm" => @firm,
    "Urbanization" => @urbanization,
    "Delivery Address" => @delivery_address,
    "City" => @city,
    "State" => @state,
    "Zip Code" => @zip_code,
    "Carrier Route" => @carrier_route,
    "County" => @county,
    "Delivery Point" => @delivery_point,
    "Check Digit" => @check_digit,
    "LAC Indicator" => @lac_indicator,
    "eLot Sequence" => @elot_sequence,
    "eLot Indicator" => @elot_indicator,
    "Record Type" => @record_type,
    "PMB Designator" => @pmb_designator,
    "PMB Number" => @pmb_number,
    "Default Address" => @default_address,
    "Early Warning" => @early_warning,
    "Valid" => @valid,
  }
end

  #
  # to_s()
  #

  def to_s(message = nil)
    output = ''
    
    if message != nil
      output = sprintf "ADDRESS: %s\n", message
    end
  
    temp = fields
  
    @@field_order.each { |key|
      value = temp[key]
      next if value == nil
      line = sprintf "  %s => '%s'\n", key, value
      output += line
    }

    output += "\n"
  
    return output
  end

  #
  # dump()
  #

  def dump(message = nil)
    print to_s(message)
  end

  #
  # to_dump()
  #

  def to_dump
    return to_s()
  end

  def query_string
    require 'cgi'
  
    args = [
      [ 'visited'      , '1' ], # NOTE: CGI.escape pukes if this doesn't have quotes. It isn't smart enough to convert to String on its own!
      [ 'pagenumber'   , 'all' ],
      [ 'firmname'      , '' ],
      [ 'address1'     , @delivery_address.upcase ],
#     [ 'address1'     , '' ],
#     [ 'address2'     , addr.delivery_address.upcase ],
      [ 'address2'     , '' ],
      [ 'city'         , @city.upcase ],
      [ 'state'        , @state.upcase ],
      [ 'urbanization' , '' ],
      [ 'zip5'         , @zip_code == nil ? '' : @zip_code.upcase ],
    ]

    result = ''
    
    args.each { |arg|
      key = arg[0]
      value = arg[1]
      
      if value == nil
        raise "Value is nil for key '" + key + "'!!!"
      end
      
      value = CGI.escape(arg[1])
      
      temp = sprintf("%s=%s", key, value)
      
      if result != ''
        result += "&"
      end
      
      result += temp
    }
    
    return result
  end
  
end # class Address

end # module USPS
