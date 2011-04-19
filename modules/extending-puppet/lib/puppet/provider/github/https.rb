require 'base64'
require 'json'
require 'net/http'
require 'net/https'
require 'openssl'

Puppet::Type.type(:github).provide :https do
  @doc = "Send a public key to GitHub."

  defaultfor :operatingsystem => :ubuntu

  def exists?
    return false unless File.exists?("#{@resource[:path]}")
    return false unless File.exists?("#{@resource[:path]}.pub")
    !github_id.nil?
  end

  def create
    system "ssh-keygen -q -f '#{@resource[:path]
      }' -b 2048 -N '' -C ''"
    POST("/api/v2/json/user/key/add",
      :title => File.basename("#{@resource[:path]}"),
      :key => File.read("#{@resource[:path]}.pub"))
  end

  def destroy
    if id = github_id
      POST("/api/v2/json/user/key/remove", :id => id)
    end
    File.unlink "#{@resource[:path]}"
    File.unlink "#{@resource[:path]}.pub"
  end

private

  def github_id
    public_key = File.read("#{@resource[:path]}.pub").strip
    JSON.parse(GET("/api/v2/json/user/keys").body,
      :symbolize_names => true
    )[:public_keys].find { |gh| gh[:key] == public_key }[:id]
  rescue NoMethodError
    nil
  end

  def connection
    return @connection if defined?(@connection)
    @connection = Net::HTTP.new("github.com", 443)
    @connection.use_ssl = true
    @connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @connection
  end

  def authorize(request)
    request["Authorization"] = "Basic #{Base64.encode64(
      "#{@resource[:username]}/token:#{@resource[:token]}"
    ).gsub("\n", "")}"
  end

  def GET(path)
    request = Net::HTTP::Get.new(path)
    authorize(request)
    connection.request(request)
  end

  def POST(path, options={})
    request = Net::HTTP::Post.new(path)
    authorize(request)
    request.set_form_data(options)
    connection.request(request)
  end

end
