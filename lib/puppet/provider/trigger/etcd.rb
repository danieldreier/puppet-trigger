#require 'facter'
Puppet::Type.type(:trigger).provide(:etcd) do
  commands :etcdctl => "etcdctl"

  def restart
    @tags = @resource[:tag] if @resource[:tag]
    @hosts = @resource[:hosts] if @resource[:hosts]
    messages = {'hostname' => Facter.value(:hostname),
                'action'   => 'restart',
                'tags'     => @tags,
                'hosts'    => @hosts }
    etcdctl('set', '--ttl', '180', resource[:name], messages.to_s)
    @message = "restart triggered"
  end
end

