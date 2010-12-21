$:.unshift File.expand_path(File.dirname(__FILE__) + '/lib')

require 'sinatra'
require 'authorization'
require 'models'
require 'routes'
require 'uihelpers'

set :haml, {:format => :html5, :attr_wrapper => '"'}

helpers do
  include Sinatra::Authorization
  include Sinatra::Routes
  include Sinatra::UIHelpers
end

before do
  @site = Site.new
  @robots = "index,follow"
end

get '/new' do
  login_required!    
  editor_form Post.new
end

post '/new' do
  login_required!
  post = Post.new params[:post]
  post.user = current_user
  if post.save
    redirect path_for(:post, :slug => post.slug)
  else
    editor_form post
  end
end

get %r{/edit/(.+)} do |slug|
  login_required!    
  post = Post.find_by_slug!(slug)
  editor_form post
end

post %r{/edit/(.+)} do |slug|
  login_required!  
  post = Post.find_by_slug!(slug)
  post.title = params[:post][:title]
  post.rawbody = params[:post][:rawbody]
  if post.save
    redirect path_for(:post, :slug => post.slug)
  else
    editor_form post
  end
end

get '/logout' do
  logout!
end

get '/login' do
  @user = User.new
  haml :login
end

post '/login' do
  if authorize(params[:email], params[:password])
    redirect_to = session[:return_to] || path_for(:home)
    session[:return_to] = nil
    redirect redirect_to
  else
    flash[:notice] = "Invalid email/password combination"
    haml :login
  end
end

get '/atom' do
  set :haml, {:format => :xhtml}
  content_type "application/xml"
  @posts = Post.recent
  haml :atom, :layout => false
end

get '/about' do
  set_title "About"
  haml :about
end

get '/archive' do
  set_title "Archive"
  @posts = Post.archive
  @robots = "noindex,follow"
  haml :archive
end

get %r{/(.+)} do |slug|
  @post = Post.find_by_slug(slug)
  if @post
    @post.increment_views unless logged_in?
    set_title @post.title
    haml :post
  else
    404
  end
end

get '/' do
  set_title
  @posts = Post.recent(10, params[:page] || 1)
  haml :index
end

not_found do
  set_title "You broke my site!"
  @posts = Post.popular
  haml :'404'
end

def set_title (text=nil)
  @title = text ?  "#{text} : #{@site.title}" : @site.title
end

private

def editor_form(post)
  @post = post
  set_title post.title.present? ? post.title : 'Write Something'
  haml :editor  
end