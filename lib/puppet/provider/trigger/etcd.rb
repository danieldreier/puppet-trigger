require 'json'
Puppet::Type.type(:trigger).provide(:etcd) do
  commands :etcdctl => "etcdctl"

  def restart
    @tags      = @resource[:tag] if @resource[:tag]
    @hosts     = @resource[:hosts] if @resource[:hosts]
    @keyprefix = @resource[:keyprefix] if @resource[:keyprefix]
    @keyname   = @resource[:name]
    @keypath   = "#{@keyprefix}/#{@keyname}"
    messages = {'hostname'  => Facter.value(:hostname),
                'action'    => 'restart',
                'tags'      => @tags,
                'hosts'     => @hosts,
                'timestamp' => Time.now.to_i }
    etcdctl('set', '--ttl', '180', @keypath.to_s, messages.to_json)
    @message = "restart triggered"
  end
end

