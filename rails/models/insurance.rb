class Insurance < ActiveRecord::Base
  
  has_and_belongs_to_many :highlights, join_table: :highlights_insurance
  belongs_to :bank, inverse_of: :insurance
  has_many :insurance_applications
  has_and_belongs_to_many :insurance_types
  
  validates :name, :bank, presence: true

  scope :active, -> { where(active: true) }

  extend FriendlyId
  friendly_id :insurance_name, use: :slugged

  def insurance_name
    "#{bank.name}-#{name}"
  end

  def insurance_type_enum
    { cash_back: '0', petrol: '1', reward: '2', travel: '3', islamic: '4',
      premium: '5', balance_transfer: '6', zero_fee: '7', promo: '8' }
  end

  def should_generate_new_friendly_id?
    slug.nil? || name_changed?
  end

  def type?(type)
    insurance_types.where(insurance_type: type).exists?
  end

  searchable do
    text :name
    text :bank_name do
      bank.name
    end
  end
  
end
