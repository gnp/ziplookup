require 'rake'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.name = 'ziplookup'
  s.version = '1.0.0'
  s.summary = 'Classes for standardizing addresses via the USPS web site.'
  s.description = 'Classes for standardizing addresses via the USPS web site.'
  s.author = 'Gregor N. Purdy'
  s.email = 'gregor@focusresearch.com'

  s.has_rdoc = true
  s.files = File.read('Manifest.txt').split($/)
  s.require_path = 'lib' # library files go here
  s.executables = ['tryme.rb'] # must be in bin/
end

#desc 'Generate RDoc'
#Rake::RDocTask.new :rdoc do |rd|
#  rd.rdoc_dir = 'doc'
#  rd.rdoc_files.add 'lib', 'README', 'LICENSE' # add those files to your RDoc output
#  rd.main = 'README' # the main page for the RDoc
#end

desc 'Build Gem'
Rake::GemPackageTask.new spec do |pkg|
  pkg.need_tar = true
end
