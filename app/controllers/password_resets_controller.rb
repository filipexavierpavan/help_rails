class PasswordResetsController < ApplicationController
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  
  def new
  end
  
  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Enviado instruções de como resetar a senha por email"
      redirect_to root_url
    else
      flash.now[:danger] = "Endereço de email não encontrado"
      render 'new'
    end
  end

  def edit
  end
  
  def update
    if params[:user][:password].empty?
      flash.now[:danger] = "Senha não pode ser em branco"
      render 'edit'
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:success] = "Senha foi resetada."
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  private
    
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
    
    def get_user
      @user = User.find_by(email: params[:email])
    end
    
    # Confirma se o usuário é válido
    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end
    
    # Verifica a expiração do token resetado
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Resetar senha foi expirada."
        redirect_to new_password_reset_url
      end
    end
end
