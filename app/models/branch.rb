class Branch
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields
  field :name, :type => String
  field :permalink, :type => String
  field :address, :type => String
  field :contact_number, :type => Integer
  
  # Associations
  referenced_in :city
  referenced_in :merchant
  references_many :promos, stored_as: :array, inverse_of: :branches

  # Indexes
  index :permalink, :unique => true

  # Validations
  validates :name, :presence => true, :uniqueness => true
  validates :address, :presence => true

  # Callbacks
  before_save do |branch|
    branch.permalink = branch.name.parameterize
  end

  # Instance Methods
  def to_param
    self.permalink
  end
  
end
