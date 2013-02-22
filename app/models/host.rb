class Host < ActiveRecord::Base
  attr_accessible :hostname, :ipv4_addr, :ipv6_addr
  def self.search(search)
    if search
      where('hostname LIKE ?', "%#{search}%")
    else
      scoped
    end
  end
end
