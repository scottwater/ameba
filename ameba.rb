$:.unshift File.expand_path(File.dirname(__FILE__) + '/lib')

require 'sinatra'
require "sinatra/reloader" if development?
require 'authorization'
require 'models'
require 'routes'
require 'uihelpers'
require 'slim'
autoload :Chronic, 'chronic'

helpers do
  include Sinatra::Authorization
  include Sinatra::Routes
  include Sinatra::UIHelpers
end

configure :development do 
	Slim::Engine.set_default_options :pretty => true
end

before do
  @site = Site.new
  @robots = "index,follow"
	@queue_count = Post.not_published.count if current_user
end

get '/new' do
  login_required!    
  editor_form Post.new
end

post '/new' do
  login_required!
  post = Post.new params[:post]
	post.created_at = date_from_form(params[:post][:when]) 
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
	post.created_at = date_from_form(params[:post][:when]) 
	post.url = params[:post][:url]
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
	set_title = 'Log In'
  @user = User.new
  slim :login
end

post '/login' do
  if authorize(params[:email], params[:password])
    redirect_to = session[:return_to] || path_for(:home)
    session[:return_to] = nil
    redirect redirect_to
  else
    flash[:notice] = "Invalid email/password combination"
    slim :login
  end
end

get '/atom' do
  #set :haml, {:format => :xhtml}
  content_type "application/xml"
  @posts = Post.recent
	set :slim, {:format => :xhtml}
  slim :atom, :layout => false
end

get '/about' do
  set_title "About"
  textile :about, :layout_engine => :slim
end

get '/archive' do
  set_title "Archive"
  @posts = Post.archive
  @robots = "noindex,follow"
  slim :archive
end

get '/queue' do
	login_required!
	set_title "Queue"
	@posts = Post.queued
	@robots = "noindex,nofollow"
	slim :queue
end

get %r{/(.+)} do |slug|
  @post = Post.find_by_slug(slug)
  if @post
    @post.increment_views unless logged_in?
    set_title @post.title
    slim :post
  else
    404
  end
end

get '/' do
  set_title
  @posts = Post.recent(10, params[:page] || 1)
  slim :index
end

not_found do
  set_title "You broke my site!"
  @posts = Post.popular
  slim :'404'
end

def set_title (text=nil)
  @title = text ?  "#{text} : #{@site.title}" : @site.title
end

private

def editor_form(post)
  @post = post
  set_title post.title.present? ? post.title : 'Write Something'
  slim :editor  
end

def date_from_form(date)
	date = 'now' if date.blank?
	Chronic.parse(date).ago(@site.timezone_offset.hours).utc
end
