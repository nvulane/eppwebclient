class RequestedDomain < ActiveRecord::Base
  attr_accessible :reqdomain,:debtor_code, :is_transferred, :status, :vote, :issue

  def self.search(search)
    if search
      where('reqdomain LIKE ?', "%#{search}%")
    else
      scoped
    end
   end

end
