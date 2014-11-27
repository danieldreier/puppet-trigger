require 'json'
require 'securerandom'

Puppet::Type.type(:trigger).provide(:etcd) do
  commands :etcdctl => "etcdctl"

  def restart
    @tags      = @resource[:tag] if @resource[:tag]
    @hosts     = @resource[:hosts] if @resource[:hosts]
    @keyprefix = @resource[:keyprefix] if @resource[:keyprefix]
    @keyname   = @resource[:name]

    # UUID provided to allow the client-side to avoid double-processing in case
    # etcd delivers a message twice
    @uuid      = SecureRandom.uuid

    @keypath   = "#{@keyprefix}/#{@keyname}"
    messages = {'hostname'  => Facter.value(:hostname),
                'tags'      => @tags,
                'hosts'     => @hosts,
                'timestamp' => Time.now.to_i,
                'uuid'      => @uuid }
    etcdctl('set', '--ttl', '180', @keypath.to_s, messages.to_json)
    @message = "restart triggered"
  end
end

