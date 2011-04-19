require 'puppet/indirector/catalog/compiler'

class Puppet::Resource::Catalog::CachingCompiler <
  Puppet::Resource::Catalog::Compiler

  @commit, @cache = `git rev-parse HEAD`.chomp, {}

  def self.cache
    commit = `git rev-parse HEAD`.chomp
    @commit, @cache = commit, {} if @commit != commit
    @cache
  end

  def find(request)
    self.class.cache[request.key] ||= super
  end

end
