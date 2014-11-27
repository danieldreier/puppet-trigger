Puppet::Type.type(:trigger).provide(:dummy) do
  def restart
    @message = "restart triggered"
  end
end

