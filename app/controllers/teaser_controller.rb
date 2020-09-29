class TeaserController < ApplicationController
  before_action :set_teaser_by_password, only: [:index]
  before_action :set_teaser, only: [:edit, :edit_logo, :destroy]
  layout 'landing'

  def create
    @teaser = Teaser.new()
    if @teaser.save
      render json: {teaser: @teaser.id}
    else
      render json: {error: 'Konnte Teaser nicht erstrellen!'}
    end
  end

  def edit
    if params[:teaser][:teaser_color] == "1"
      @teaser.update(teaser_params)
    else
      @teaser.update(teaser_params)
      @teaser.update(color1: [69, 177, 255], color2: [29, 218, 175])
    end
    render json: {teaser: params[:teaser_id]}
  end

  def edit_logo
    @teaser.update(logo: params[:file]) if params[:file].present? && @teaser.present?
    render json: {id: @teaser.id, logo: @teaser.logo.url}
  end
  def destroy
    if @teaser.destroy
      render json: {teaser: params[:teaser_id]}
    else
      render json: {error: 'Konnte Teaser nicht löschen!'}
    end
  end

  def index

  end

  private

  def set_teaser
    @teaser = Teaser.find(params[:teaser_id])
  end

  def set_teaser_by_password
    @teaser = Teaser.find_by(password: params[:password])
  end

  def teaser_params
    params.require(:teaser).permit(:password, :fname, :lname, :logo, :color_hex, :teaser_color)
  end
end
