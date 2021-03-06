# Get filename from an URL
#
# Code derived from example42/puppet-modules/common
#
require 'uri'

module Puppet::Parser::Functions
        newfunction(:urlfilename, :type => :rvalue, :doc => "Extracts the filename from an url" ) do |args|
                url=URI.parse args[0]
		File.basename url.path
        end
end

