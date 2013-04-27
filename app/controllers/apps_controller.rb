class AppsController < ApplicationController
  def index
    @apps = App.all
  end

  def show
    @app = App.find(params[:id])
  end

  def new
    # TODO Extract this
    @default_open_tracking_domain = Rails.configuration.cuttlefish_domain
    @app = App.new
  end

  def create
    # TODO Extract this
    @default_open_tracking_domain = Rails.configuration.cuttlefish_domain
    @app = App.new(app_parameters)
    if @app.save
      flash[:notice] = "App #{@app.name} successfully created"
      redirect_to @app
    else
      render :new
    end
  end

  def destroy
    @app = App.find(params[:id])
    if @app.cuttlefish?
      flash[:error] = "Can't delete the Cuttlefish App"
    else
      flash[:notice] = "App #{@app.name} successfully removed"
      @app.destroy
    end
    redirect_to apps_path
  end

  def new_password
    app = App.find(params[:id])
    app.new_password!
    redirect_to app
  end

  def lock_password
    app = App.find(params[:id])
    app.update_attribute(:smtp_password_locked, true)
    redirect_to app
  end

  private

  def app_parameters
    params.require(:app).permit(:name, :url, :open_tracking_domain)
  end
end