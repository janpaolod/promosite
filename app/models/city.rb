class City
  include Mongoid::Document

  field :name, :type => String

  references_many :branches
  references_many :users

  validates :name, :presence => true, :uniqueness => {:case_sensitive => false}
end
