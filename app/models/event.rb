class Event < ActiveRecord::Base
   attr_accessible :username, :action, :params, :cltrid, :svtrid

   def self.search(search)
    if search
      where('svtrid LIKE ? OR cltrid LIKE ?', "%#{search}%","%#{search}%")
    else
      scoped
    end
   end

end
