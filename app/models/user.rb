class User < ActiveRecord::Base
  attr_accessor :remember_token, :activation_token, :reset_token
  #before_save { self.email = email.downcase }
  before_save :downcase_email
  before_create :create_activation_digest
  
  #validates :name, presence: true, length: { maximum: 50 }
  validates_presence_of :name, message: "deve ser preenchido"
  validates_uniqueness_of :name, message: "já está cadastrado"
  validates_length_of :name, :maximum => 50, message: "muito extenso (máximo 50 caracteres)"
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
=begin  
  validates :email, presence: true, length: { maximum: 255 }, 
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
=end                    
                    
  validates_presence_of :email, message: "deve ser preenchido"
  validates_uniqueness_of :email, :case_sensitive => true,  message: "já está cadastrado"
  validates_length_of :email, :maximum => 100, message: "muito extenso (máximo 100 caracteres)"  
  validates_format_of :email, :with => VALID_EMAIL_REGEX, message: "inválido"
                  
  has_secure_password
  validates_length_of :password, :minimum => 6, message: "muito curta (mínimo 6 caracteres)", allow_blank: true
  #validates :password, length: { minimum: 6 }
  
  class << self
    # Retorna o hash digest da string passada como parâmetro
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
    
    # Retorna um token aleatório
    def new_token
      SecureRandom.urlsafe_base64
    end
  end
  
  # Relembrar um usuário da database para o uso na sessão
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # Retorna true se o token coincide com o digest
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  # Esquecer um usuário
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  # Ativando a conta
  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
  end
  
  # Envia email de ativação
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  
  # Atributos para resetar senha.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end
  
  # Envio de email para resetar senha.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
  
  # Retorna true se a senha a ser resetada foi expirada.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end
  
  private
  
    # Converte o email para minúsculo
    def downcase_email
      self.email = email.downcase
    end
    
    # Cria e instancia a ativação do token e digest
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_token = User.digest(activation_token)
    end
end
