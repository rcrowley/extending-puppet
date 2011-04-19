require 'base64'
require 'net/http'
require 'net/https'
require 'openssl'
require 'sshkey'

Puppet::Parser::Functions.newfunction :github, :type => :rvalue do |args|

  # TODO Check GitHub for an existing public key.

  key = SSHKey.generate

  request = Net::HTTP::Post.new("/api/v2/json/user/key/add")
  request["Authorization"] = "Basic #{Base64.encode64(
    "#{args[1]}/token:#{args[2]}"
  ).gsub("\n", "")}"
  request.set_form_data({
    :title => args[0],
    :key => key.ssh_public_key,
  })

  connection = Net::HTTP.new("github.com", 443)
  connection.use_ssl = true
  connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
  connection.request(request)

  key.rsa_private_key
end
