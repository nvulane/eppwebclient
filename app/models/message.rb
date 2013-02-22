class Message < ActiveRecord::Base
   attr_accessible :message, :readby, :read
end
