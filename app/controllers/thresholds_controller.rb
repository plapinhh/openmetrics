class ThresholdsController < ApplicationController

  def index
    redirect_to users_path
  end

  def show
    @threshold = Threshold.find(params[:id])
#    @systems = System.find(@threshold.metric_identifiers.map { ||}, :order => "name")
    @systems = System.find(@threshold.system_filter_ids, :order => "name")
  end

  def new
    @threshold = Threshold.new
    @systems = []
    System.find(:all, :order => "name").each do |s|
      s[:id_s] = s.id.to_s
      @systems << s if s.has_service_of_type?("CollectdService")
    end
  end

  def create
    @threshold = Threshold.new(params[:threshold])
    @systems = []
    System.find(:all, :order => "name").each do |s|
      s[:id_s] = s.id.to_s
      @systems << s if s.has_service_of_type?("CollectdService")
    end
    if @threshold.save
      redirect_to users_path
    else
      render 'new'
    end
  end

  def edit
    @threshold = Threshold.find(params[:id])

    @systems = []
    System.find(:all, :order => "name").each do |s|
      s[:id_s] = s.id.to_s
      @systems << s if s.has_service_of_type?("CollectdService")
    end
  end

  def update
    @threshold = Threshold.find(params[:id])
    if @threshold.update_attributes(params[:threshold])
      redirect_to users_path
    else
      render 'edit'
    end
  end

  def destroy
    @threshold = Threshold.find(params[:id])
    if @threshold.destroy
      redirect_to users_path
    else
      redirect_to users_path
    end
  end

end
