require 'puppet/indirector/facts/facter'

class HierValue < Hash
  attr_accessor :top
  def initialize(top=nil)
    @top = top
  end
  def to_s
    @top
  end
end

class Puppet::Node::Facts::Hier < Puppet::Node::Facts::Facter
  def destroy(facts)
  end
  def save(facts)
  end
end

class Puppet::Node::Facts::Hier < Puppet::Node::Facts::Facter
  def find(request)
    hier = {}
    super.values.reject do |key, value|
      Symbol === key
    end.each do |key, value|
      value = value.split(",") if value.index(",")
      h = hier
      if key.index("_") and keys = key.split("_")
        while 1 < keys.length and key = keys.shift
          h = HierValue === h[key] ?
            h[key] : h[key] = HierValue.new(h[key])
        end
        key = keys.shift
      end
      if HierValue === h[key]
        h[key].top = value
      else
        h[key] = value
      end
    end
    Puppet::Node::Facts.new(request.key, hier)
  end
end
