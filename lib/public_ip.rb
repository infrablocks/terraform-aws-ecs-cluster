require 'open-uri'

module PublicIP
  def self.as_cidr
    "#{open('http://whatismyip.akamai.com').read}/32"
  end
end
