require "USPS/zip_lookup"
require "USPS/address"
#require "zip_lookup"
#require "address"

delivery_address = "6216 Eddington Drive"
city = "Middletown"
state = "OH"

address = USPS::Address.new
address.delivery_address = delivery_address
address.city = city
address.state = state

zlu = USPS::ZipLookup.new()
#zlu.verbose = true

matches = zlu.std_addr(address)

if matches != nil && matches.size > 0
  printf "\n%d matches:\n", matches.size
  matches.each { |match|
#    print "-" x 39, "\n"
    print match.to_dump
    print "\n"
  }
#  print "-" x 39, "\n"
else
  print "No matches!\n"
end