class RequestedDomain < ActiveRecord::Base
  attr_accessible :reqdomain, :is_transferred

  def self.search(search)
    if search
      where('reqdomain LIKE ?', "%#{search}%")
    else
      scoped
    end
   end

end
