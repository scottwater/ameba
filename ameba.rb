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
  v :login
end

post '/login' do
  if authorize(params[:email], params[:password])
    redirect_to = session[:return_to] || path_for(:home)
    session[:return_to] = nil
    redirect redirect_to
  else
    flash[:notice] = "Invalid email/password combination"
    v :login
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
  v :about
end

get '/archive' do
  @posts = Post.archive
  @robots = "noindex,follow"
  v :archive
end

get '/queue' do
	login_required!
	@posts = Post.queued
	@robots = "noindex,nofollow"
	v :queue
end

get %r{/(.+)} do |slug|
  @post = Post.find_by_slug(slug)
  if @post
    @post.increment_views unless logged_in?
    v :post
  else
    404
  end
end

get '/' do
  @posts = Post.recent(10, params[:page] || 1)
  v :index
end

not_found do
  @posts = Post.popular
  v :'404'
end

def set_title (text=nil)
  @title = text ?  "#{text} : #{@site.title}" : @site.title
  pjax? ? "<title>#{@title}</title>" : ''
end

private

def editor_form(post)
  @post = post
  v :editor  
end

def date_from_form(date)
	date = 'now' if date.blank?
	Chronic.parse(date).ago(@site.timezone_offset.hours).utc
end

def pjax?
  env['HTTP_X_PJAX']
end

def v(name)
  slim name, :layout => !pjax?
end
