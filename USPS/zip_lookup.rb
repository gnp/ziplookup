=begin
= zip_lookup.rb
Copyright (C) 2006 Gregor N. Purdy. All rights reserved.

This program is free software. It is subject to the same license as Ruby.

= Classes
* ((<Address>))

= ZipLookup

== Synopsis

Ruby class to standardize U.S. postal addresses by referencing
the U.S. Postal Service's web site:

http://www.usps.com/zip4/

  #!/usr/bin/perl
  
  use Scrape::USPS::ZipLookup::Address;
  use Scrape::USPS::ZipLookup;
  
  my $addr = Scrape::USPS::ZipLookup::Address->new(
    'Focus Research, Inc.',                # Firm
    '',                                    # Urbanization
    '8080 Beckett Center Drive Suite 203', # Delivery Address
    'West Chester',                        # City
    'OH',                                  # State
    '45069-5001'                           # ZIP Code
  );
  
  my $zlu = Scrape::USPS::ZipLookup->new();
  
  my @matches = $zlu->std_addr($addr);
  
  if (@matches) {
    printf "\n%d matches:\n", scalar(@matches);
    foreach my $match (@matches) {
      print "-" x 39, "\n";
      print $match->to_string;
      print "\n";
    }
    print "-" x 39, "\n";
  }
  else {
    print "No matches!\n";
  }
  
  exit 0;
  
== Description

The United States Postal Service (USPS) has on its web site an HTML form at
C<http://www.usps.com/zip4/>
for standardizing an address. Given a firm, urbanization, street address,
city, state, and zip, it will put the address into standard form (provided
the address is in their database) and display a page with the resulting
address.

This Perl module provides a programmatic interface to this service, so you
can write a program to process your entire personal address book without
having to manually type them all in to the form.

Because the USPS could change or remove this functionality at any time,
be prepared for the possibility that this code may fail to function. In
fact, as of this version, there is no error checking in place, so if they
do change things, this code will most likely fail in a noisy way. If you
discover that the service has changed, please email the author your findings.

If an error occurs in trying to standardize the address, then no array
will be returned. Otherwise, a four-element array will be returned.

To see debugging output, call C<< $zlu->verbose(1) >>.


== Fields

This page at the U.S. Postal Service web site contains definitions of some
of the fields: C<http://zip4.usps.com/zip4/pu_mailing_industry_def.htm>


= TERMS OF USE

BE SURE TO READ AND FOLLOW THE UNITED STATES POSTAL SERVICE TERMS OF USE PAGE
(AT C<http://www.usps.com/homearea/docs/termsofuse.htm> AT THE TIME THIS TEXT
WAS WRITTEN). IN PARTICULAR, NOTE THAT THEY DO NOT PERMIT THE USE OF THEIR WEB
SITE'S FUNCTIONALITY FOR COMMERCIAL PURPOSES. DO NOT USE THIS CODE IN A WAY
THAT VIOLATES THE TERMS OF USE.

As the user of this code, you are responsible for complying with the most
recent version of the Terms of Use, whether at the URL provided above or
elsewhere if the U.S. Postal Service moves it or updates it. As a convenience,
here is a copy of the most relevant paragraph of the Terms of Use as of
2006-07-04:

  Material on this site is the copyrighted property of the United States
  Postal Service¨ (Postal Serviceª). All rights reserved. The information
  and images presented here may not under any circumstances be reproduced
  or used without prior written permission. Users may view and download
  material from this site only for the following purposes: (a) for personal,
  non-commercial home use; (b) where the materials clearly state that these
  materials may be copied and reproduced according to the terms stated in
  those particular pages; or (c) with the express written permission of the
  Postal Service. In all other cases, you will need written permission from
  the Postal Service to reproduce, republish, upload, post, transmit,
  distribute or publicly display material from this Web site. Users agree not
  to use the site for sale, trade or other commercial purposes. Users may not
  use language that is threatening, abusive, vulgar, discourteous or criminal.
  Users also may not post or transmit information or materials that would
  violate rights of any third party or which contains a virus or other harmful
  component. The Postal Service reserves the right to remove or edit any
  messages or material submitted by users. 

The author believes that the example usage given above does not violate
these terms, but sole responsibility for conforming to the terms of use
belongs to the user of this code, not the author.


= BUG REPORTS

When contacting the author with bug reports, please provide a test address that
exhibits the problem, and make sure it is OK to add that address to the test
suite.

Be sure to let me know if you don't want me to mention your name or email
address when I document the changes and contributions to the release. Typically
I put this information in the CHANGES file.

= History
$Id: $ 

= Author

Gregor N. Purdy, C<gregor@focusresearch.com>.

= Copyright

Copyright (C) 2006 Gregor N. Purdy. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Ruby itself.

=end

require 'mechanize'

#  agent = WWW::Mechanize.new
#  page = agent.get('http://rubyforge.org/')
#  link = page.links.text(/Log In/).first
#  page = agent.click(link)
#  form = page.forms[1]
#  form.form_loginname = ARGV[0]
#  form.form_pw = ARGV[1]
#  page = agent.submit(form, form.buttons.first)
#
#  puts page.body

class String
  def super_trim
    temp = self.dup
#    dup.gsub(/\x{a0}/m, ' ')   # Remove this odd character.
    dup.gsub(/^\s+/m, '')      # Trim leading whitespace.
    dup.gsub(/\s+$/m, '')      # Trim trailing whitespace.
    dup.gsub(/\s+/m, ' ')      # Coalesce interior whitespace.
    return dup;
  end
end

module USPS

class ZipLookup
#  @@VERSION = '2.5'
  @@usps_host = 'zip4.usps.com'
  
  @@start_path = '/zip4/welcome.jsp'
  @@start_url = sprintf('http://%s%s', @@usps_host, @@start_path)

  @@post_path = '/zip4/zcl_0_results.jsp'
  @@post_url = sprintf('http://%s%s', @@usps_host, @@post_path)

#  @@form_name = 'form1'
  @@form_number = 0
  
  attr_reader :user_agent, :verbose
  attr_writer :verbose
  
  def initialize
    @user_agent = WWW::Mechanize.new
    @verbose = false
  end
  
  def std_addr(address)
    return std_inner(address)
  end

  def std_addrs(addresses)
    result = [ ]

    addresses.each { |address|
      temp = std_inner(address)
      
      result.push(temp)
    }
    
    return result
  end

  def form_submit(addr)
    response = @user_agent.get(@@start_url)

    raise "Error communicating with server" if response == nil

    content = response.body

    if @verbose
      print "-" * 79, "\n"
      print "Initial Page HTTP Response:\n"
      print content
    end

    form = response.forms[@@form_number] # Really want to use @@form_name!!!
  
    form.field('address1').value   = addr.delivery_address.upcase
    form.field('city').value       = addr.city.upcase
    form.field('state').value      = addr.state.upcase
    form.field('zip5').value	    = addr.zip_code == nil ? nil : addr.zip_code.upcase
    form.field('visited').value    = '1' # NOTE: WWW::Mechanize pukes if this doesn't have quotes. It isn't smart enough to convert to String on its own!
    form.field('pagenumber').value = 'all'
    form.field('firmname').value    = ''
  
    response = @user_agent.submit(form)
  
    raise "Error communicating with server" if response == nil

    content = response.body
  
    if @verbose
      print "-" * 79, "\n"
      print "Form Submit HTTP Response:\n"
      print content
    end
    
    return response.body
  end
  
  def direct_post(addr)
    request_body = addr.query_string
    
    require 'net/http'
    
    content = nil
    
#   post_headers = { 'Referer' => @@start_url, 'Content-Type' => 'application/x-www-form-urlencoded' }
    post_headers = { }
       
    session = Net::HTTP.new(@@usps_host)
    (response, content) = session.post(@@post_path, request_body, post_headers)
        
    if @verbose
      print "-" * 79, "\n"
      printf "Direct HTTP POST (to http://%s%s) Body:\n", @@usps_host, @@post_path
      print request_body, "\n"
      print "HTTP Response:\n"
      print content
    end

    return content
  rescue WWW::Mechanize::ResponseCodeError => error
    printf "Unhandled response: %s\n", error.response_code
    raise
  end
    
  def direct_get(addr)
    query_string = addr.query_string
    
    require 'net/http'
    
    content = nil
    
#   headers = { 'Referer' => @@start_url, 'Content-Type' => 'application/x-www-form-urlencoded' }
    headers = { }
       
    path = @@post_path + "?" + query_string
    
    session = Net::HTTP.new(@@usps_host)
    (response, content) = session.get(path, headers)
        
    if @verbose
      print "-" * 79, "\n"
      printf "Direct HTTP GET (of http://%s%s) Body:\n", @@usps_host, path
      print "HTTP Response:\n"
      print content
    end

    return content
  rescue WWW::Mechanize::ResponseCodeError => error
    printf "Unhandled response: %s\n", error.response_code
    raise
  end
  
  #
  # std_inner()
  #
  # The inner portion of the process, so it can be shared by
  # std_addr() and std_addrs().
  #
  #
  def std_inner(addr)
    if @verbose
      print ' ', '_' * 77, ' ',  "\n"
      print '/', ' ' * 77, '\\', "\n"
      addr.dump("Input")
      print "\n"
    end

    #
    # Submit the form to the USPS web server:
    #
    # Unless we are in verbose mode, we make the WWW::Mechanize user agent be
    # quiet. At the time this was written [2003-01-28], it generates a warning
    # about the "address" form field being read-only if its not in quiet mode.
    #
    # We set the form's Selection field to "1" to indicate that we are doing
    # regular zip code lookup.
    #

    content = direct_get(addr)
#    content = direct_post(addr)
#    content = form_submit(addr)

    #
    # Time to Parse:
    #
    # The results look like this:
    #
    #   <td width="312" background="images/light_blue_bg2.gif" class="mainText">6216 EDDINGTON ST <br>LIBERTY TOWNSHIP&nbsp;OH&nbsp;45044-9761 <br>
    #
    # 1. We find <td header ...> ... </td> to find the data fields.
    # 2. We strip out <font> and <a>
    # 3. We replace &nbsp; with space
    # 4. We strip out leading "...: "
    # 5. We find <!--< ... />--> to get the field id
    # 6. We standardize the field id (upper case, alpha only)
    # 7. We standardize the value (trimming and whitespace coalescing)
    #
    # We end up with something like this:
    #
    #   ADDRESSLINE:  6216 EDDINGTON ST
    #   CITYSTATEZIP: LIBERTY TOWNSHIP OH  45044-9761
    #   CARRIERROUTE: R007
    #   COUNTY: BUTLER
    #   DELIVERYPOINT: 16
    #   CHECKDIGIT: 3
    #

    matches =[ ]

    content.gsub!(Regexp.new('[\cI\cJ\cM]'), '')
    content.squeeze!(" ")
    content.strip!

#    print content
    
    raw_matches = content.scan(%r{<td headers="\w+" height="34" valign="top" class="main" style="background:url\(images/table_gray\.gif\); padding:5px 10px;">(.*?)>Mailing Industry Information</a>}mi)
#   raw_matches = content.scan(Regexp.new('mailing'))

#    print "Raw matches: ", raw_matches.size, "\n"
  
    raw_matches.each { |raw_match|
      if @verbose
        print "-" * 79, "\n"
        print "Raw match:\n"
        printf("%s\n", raw_match[0])
      end
      
      match = parse_match(raw_match[0])
  
#      print "Got match: ", match.to_s(), "\n"
      
      matches.push(match)
    }

    print('\\', '_' * 77, '/', "\n") if @verbose

    return matches;
  end # method std_inner

  def parse_match(raw_match)
    carrier_route   = nil
    county          = nil
    delivery_point  = nil
    check_digit     = nil
    lac_indicator   = nil
    elot_sequence   = nil
    elot_indicator  = nil
    record_type     = nil
    pmb_designator  = nil
    pmb_number      = nil
    default_address = nil
    early_warning   = nil
    valid           = nil

    #
    # Looking for some text like this:
    # 
    # onClick="mailingIndustryPopup2('R007','BUTLER','16','3','','0179','A','S','','','','','Y');"
    #
    
    regex = %r{mailingIndustryPopup2\((.*?)\);}i
    result = regex.match(raw_match)
    
    if result != nil
      args = result[1]
      
      # Reformat to pipe-delimited
      args.sub!(/^'/, '')
      args.gsub!(/\s*'?\s*,\s*'?\s*/, '|')
      args.sub!(/'$/, '')

      args_array = args.split(/\|/)

      carrier_route   = (args_array[0]  != nil && args_array[0]  != '') ? args_array[0]  : nil
      county          = (args_array[1]  != nil && args_array[1]  != '') ? args_array[1]  : nil
      delivery_point  = (args_array[2]  != nil && args_array[2]  != '') ? args_array[2]  : nil
      check_digit     = (args_array[3]  != nil && args_array[3]  != '') ? args_array[3]  : nil
      lac_indicator   = (args_array[4]  != nil && args_array[4]  != '') ? args_array[4]  : nil
      elot_sequence   = (args_array[5]  != nil && args_array[5]  != '') ? args_array[5]  : nil
      elot_indicator  = (args_array[6]  != nil && args_array[6]  != '') ? args_array[6]  : nil
      record_type     = (args_array[7]  != nil && args_array[7]  != '') ? args_array[7]  : nil
      pmb_designator  = (args_array[8]  != nil && args_array[8]  != '') ? args_array[8]  : nil
      pmb_number      = (args_array[9]  != nil && args_array[9]  != '') ? args_array[9]  : nil
      default_address = (args_array[10] != nil && args_array[10] != '') ? args_array[10] : nil
      early_warning   = (args_array[11] != nil && args_array[11] != '') ? args_array[11] : nil
      valid           = (args_array[12] != nil && args_array[12] != '') ? args_array[12] : nil
    else
      if @verbose
        printf "WARNING: Could not find Mailing Industry info in '%s'!\n", raw_match
      end
    end

    raw_match.gsub!(%r{</td>\s*<td.*?>}, ' ')
    raw_match.gsub!(%r{</?font.*?>}, '')
    raw_match.gsub!(%r{</?span.*?>}, '')
    raw_match.gsub!(%r{</?a.*?>}, '')
    raw_match.gsub!(%r{&nbsp;}, ' ')
    raw_match.gsub!(%r{^.*?:\s*}, '')
    raw_match.gsub!(%r{\s+}, ' ')
    raw_match.gsub!(%r{<!--<(.*?)/>-->}, '')
    raw_match.sub!(%r{<a.*$}, '')
    raw_match.sub!(%r{<br\s*/?>\s*$}, '')

    if @verbose
      print "-" * 79, "\n"
      print "Distilled match:\n"
      printf "%s\n", raw_match
    end

    parts = raw_match.split( /\s*<br\s*\/?>\s*/)

    firm            = nil
    address        = nil
    city_state_zip = nil

    if parts.size == 2
      (address, city_state_zip) = parts
    elsif parts.size == 3
      (firm, address, city_state_zip) = parts
    else
#      die "Parts = " . scalar(@parts) . "!";
    end

    next if city_state_zip == nil
    next if !(city_state_zip =~ /^(.*)\s+(\w\w)\s+(\d{5}(-\d{4})?)/)

    city = $1
    state = $2
    zip = $3

    if @verbose
      print("-" * 70, "\n");

      printf "Firm:            %s\n", firm            if firm != nil

      printf "Address:         %s\n", address
      printf "City:            %s\n", city
      printf "State:           %s\n", state
      printf "Zip:             %s\n", zip

      printf "Carrier Route:   %s\n", carrier_route   if carrier_route   != nil
      printf "County:          %s\n", county          if county          != nil
      printf "Delivery Point:  %s\n", delivery_point  if delivery_point  != nil
      printf "Check Digit:     %s\n", check_digit     if check_digit     != nil
      printf "LAC Indicator:   %s\n", lac_indicator   if lac_indicator   != nil
      printf "eLOT Sequence:   %s\n", elot_sequence   if elot_sequence   != nil
      printf "eLOT Indicator:  %s\n", elot_indicator  if elot_indicator  != nil
      printf "Record Type:     %s\n", record_type     if record_type     != nil
      printf "PMB Designator:  %s\n", pmb_designator  if pmb_designator  != nil
      printf "PMB Number:      %s\n", pmb_number      if pmb_number      != nil
      printf "Default Address: %s\n", default_address if default_address != nil
      printf "Early Warning:   %s\n", early_warning   if early_warning   != nil
      printf "Valid:           %s\n", valid           if valid           != nil

      print "\n";
    end

#    print "Creating instance...\n"

    match = USPS::Address.new

    match.delivery_address = address
    match.city             = city
    match.state            = state
    match.zip_code         = zip
    
    match.firm              = firm

    match.carrier_route    = carrier_route
    match.county           = county
    match.delivery_point   = delivery_point
    match.check_digit      = check_digit

    match.lac_indicator    = lac_indicator
    match.elot_sequence    = elot_sequence
    match.elot_indicator   =  elot_indicator
    match.record_type      = record_type
    match.pmb_designator   = pmb_designator
    match.pmb_number       = pmb_number
    match.default_address  = default_address
    match.early_warning    = early_warning
    match.valid            = valid
    
#    print "Returning...\n"
    
    return match
  end # method parse_match

end # class ZipLookup

end # module USPS
