class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :find_post, only: [:show, :edit, :destroy, :update]
  before_action :authorize, only: [:edit, :destroy, :update]

  def new
    @post = Post.new(created_at: :desc)
  end

  def create
    post_params = params.require(:post).permit([:title, :body, :category_id])
    @post = Post.new(post_params)
    @post.user = current_user

    if @post.save
      flash[:notice] = "Post Created"
      redirect_to post_path(@post)
    else
      flash.now[:alert] = 'Please fix errors below'

      render :new
    end
  end

  def show
    @post = Post.find params[:id]
    @comment = Comment.new
    respond_to do |format|
      format.html { render }
      format.json { render json: @post.to_json }
    end
  end

  def index
    @post = Post.order(created_at: :desc)
  end

  def edit
  end

  def update
    @post = Post.find params[:id]
    post_params = params.require(:post).permit([:title, :body, :category_id])
    if @post.update post_params
      redirect_to post_path(@post)
    else
      render :edit
    end
  end

  def destroy
    post = Post.find params[:id]
    post.destroy
    redirect_to posts_path
  end

    private

    def find_post
      @post = Post.find params[:id]
    end

    def authorize
      if cannot?(:manage, @post)
        redirect_to root_path, alert: 'Not authorized!'
      end
    end

end
