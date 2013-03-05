class AddStatusIssueVote < ActiveRecord::Migration
  def up
    add_column :requested_domains, :status, :string
    add_column :requested_domains, :issue, :datetime
    add_column :requested_domains, :vote, :datetime
  end

  def down
  end
end
