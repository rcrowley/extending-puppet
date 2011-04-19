require 'puppet/node'
require 'puppet/indirector/plain'
require 'resolv'

class Puppet::Node::Dns < Puppet::Indirector::Plain

  def find(request)
    node = super
    begin
      resolver = Resolv::DNS.new
      resource = resolver.getresource(
        request.key, Resolv::DNS::Resource::IN::TXT)
      node.classes += resource.data.split
    rescue Resolv::ResolvError
    end
    node.fact_merge
    node
  end

end
