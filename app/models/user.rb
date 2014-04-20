class User < ActiveRecord::Base

  has_many :routes, dependent: :destroy

  # attr_accessible :email, :password, :password_confirmation

  before_validation { self.email = email.downcase unless guest? }
  before_create :create_remember_token
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates_presence_of :email, :password_digest, unless: :guest?
  validates_uniqueness_of :email, allow_blank: true
  validates :password, length: { minimum: 6 }, unless: :guest?
  validates :email, format: { with: VALID_EMAIL_REGEX }, unless: :guest?
  validates_confirmation_of :password
  has_secure_password validations: false

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.hash(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def User.new_guest
    new { |u| u.guest = true }
  end
  
  def name
    guest ? "Guest" : email
  end
  
  def move_to(user)
    routes.update_all(user_id: user.id)
  end

  private
    def create_remember_token
      self.remember_token = User.hash(User.new_remember_token)
    end
end
