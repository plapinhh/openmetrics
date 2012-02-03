class InventoryItemsController < ApplicationController
  # GET /inventory_items
  # GET /inventory_items.xml
  def index
    @inventory_items = InventoryItem.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @inventory_items }
    end
  end

  # GET /inventory_items/1
  # GET /inventory_items/1.xml
  def show
    @inventory_item = InventoryItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @inventory_item }
    end
  end

  # GET /inventory_items/new
  # GET /inventory_items/new.xml
  def new
    @inventory_item = InventoryItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @inventory_item }
    end
  end

  # GET /inventory_items/1/edit
  def edit
    @inventory_item = InventoryItem.find(params[:id])
  end

  # POST /inventory_items
  # POST /inventory_items.xml
  def create
    @inventory_item = InventoryItem.new(params[:inventory_item])

    respond_to do |format|
      if @inventory_item.save
        flash[:notice] = 'InventoryItem was successfully created.'
        format.html { redirect_to(@inventory_item) }
        format.xml  { render :xml => @inventory_item, :status => :created, :location => @inventory_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @inventory_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /inventory_items/1
  # PUT /inventory_items/1.xml
  def update
    @inventory_item = InventoryItem.find(params[:id])

    respond_to do |format|
      if @inventory_item.update_attributes(params[:inventory_item])
        flash[:notice] = 'InventoryItem was successfully updated.'
        format.html { redirect_to(@inventory_item) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @inventory_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /inventory_items/1
  # DELETE /inventory_items/1.xml
  def destroy
    @inventory_item = InventoryItem.find(params[:id])
    @inventory_item.destroy

    respond_to do |format|
      format.html { redirect_to(inventory_items_url) }
      format.xml  { head :ok }
    end
  end
end
