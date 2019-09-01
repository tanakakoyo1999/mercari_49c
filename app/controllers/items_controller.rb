class ItemsController < ApplicationController

  before_action :search
  def index
    # # category has_many items の場合
    # @items = Item.index_items.limit(4).order("id DESC")
    categories_men = Category.last_four(0)
    categories_lady = Category.last_four(1)
    categories_baby = Category.last_four(2)
    categories_cos = Category.last_four(3)

    @items_men = []
    categories_men.map {|category| @items_men << Item.find(category.item_id)}

    @items_lady = [] 
    categories_lady.map {|category| @items_lady << Item.find(category.item_id)}

    @items_baby = []
    categories_baby.map {|category| @items_baby << Item.find(category.item_id)}  

    @items_cos = []
    categories_cos.map {|category| @items_cos << Item.find(category.item_id)}  

  end

  def show
    @items = Item.all
    @item = Item.find(params[:id])
    @image = @item.images
    @category = Category.where(item_id:@item.id)
    @user = User.find(@item.seller_id)
  end

  def new
  end

  def destroy
    Category.find_by(item_id:params[:id]).destroy if Category.find_by(item_id:params[:id])
    Image.find_by(item_id:params[:id]).destroy if Image.find_by(item_id:params[:id])
    Item.find(params[:id]).delete
    redirect_to root_path
  end

  def create
    Item.create(name:item_params[:item_name],description:item_params[:item_description],condition:item_params[:item_condition],price:item_params[:item_price],brand:item_params[:item_brand],deliveryfee:item_params[:item_deliveryfee],area:item_params[:item_area],days_to_ship:item_params[:item_days_to_ship],sales_situation:"出品中",likes_count:0,size:item_params[:item_size],deliveryWay:item_params[:item_deliveryWay],seller_id:current_user.id)
    item_params[:file].each do |image|
      Image.create(image:image,item_id:Item.last.id)
    end
    first = Category.create(name:item_params[:item_category_first],item_id:Item.last.id)
    second = first.children.create(name:item_params[:item_category_second][0],item_id:Item.last.id)
    third = second.children.create(name:item_params[:item_category_third][0],item_id:Item.last.id)
  end

  def search
    @search = Item.ransack(params[:q]) #ransackメソッド推奨
    @search_item = @search.result.page(params[:page]).per(100)
    @search_page = @search_item.current_page
    @search_count = @search.result.count
  end


  def edit
    @item = Item.find(params[:id])
    @image = @item.images
    @images = []
    @images_id = []
    @image.each do |image|
      @images << image.image.url
      @images_id << image.id
    end
    if @item.seller_id == current_user.id
      @category = Category.where(item_id:@item.id)
      @category_grandchildren = @category.third
      @category_children = @category.third.parent
      @category_parent = @category.third.parent.parent
    end 
    
  end
  
  def update
    item = Item.find(params[:id])
    item.update(name:item_params[:item_name],description:item_params[:item_description],condition:item_params[:item_condition],price:item_params[:item_price],brand:item_params[:item_brand],deliveryfee:item_params[:item_deliveryfee],area:item_params[:item_area],days_to_ship:item_params[:item_days_to_ship],sales_situation:"出品中",likes_count:0,size:item_params[:item_size],deliveryWay:item_params[:item_deliveryWay],seller_id:current_user.id)

    if item_params[:image_delate].present?
      item_params[:image_delate].each do |image_del|
        Image.delete(id: image_del)
      end
    end
    if item_params[:image_delate].present?
      item_params[:file].each do |image|
        Image.create(image:image,item_id: item.id)
      end
    end
      redirect_to root_path
  end
  private
  def item_params
    attrs = [:item_name,:item_description,:item_condition,:item_price,:item_brand,:item_deliveryfee,:item_area,:item_days_to_ship,:item_sales_situation,:item_size,:item_deliveryWay,:item_category_first,file:[],item_category_second:[],item_category_third:[],image:[],image_delate:[]]
    params.permit(attrs)
  end

end
