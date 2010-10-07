require File.expand_path(File.dirname(__FILE__) +  '/../spec_helper')

describe 'View Counts' do
  
  before(:each) do
    Post.destroy_all
    @post = Post.create!(:title => "x", :rawbody => "x", :user => a_user)
  end
  
  it 'should count a view' do
      @post.views.should eql(0)
      visit path_for(:post, :slug => @post.slug)
      Post.find_by_slug(@post.slug).views.should eql(1)
      visit path_for(:post, :slug => @post.slug)
      Post.find_by_slug(@post.slug).views.should eql(2)
      
  end
  
  # it 'should not count a view if I am logged in' do
  #   @post.views.should eql(0)
  #   
  #   #force webrat to treat the request as authorized
  #   Sinatra::Authorization.class_eval <<-EOE
  #       def logged_in?
  #         true
  #       end
  #   EOE
  # 
  #   visit path_for(:post, :slug => @post.slug)
  #   Post.find_by_slug(@post.slug).views.should eql(0)
  # end
  
end