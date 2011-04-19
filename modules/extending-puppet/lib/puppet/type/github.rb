require 'puppet/type'

Puppet::Type.newtype :github do
  @doc = "Send a public key to GitHub."

  newparam :path, :namevar => true do
    desc "Private key pathname."
  end

  newparam :username do
    desc "GitHub username."
  end

  newparam :token do
    desc "GitHub API token."
  end

  ensurable do
    defaultvalues
    defaultto :present
  end

end
