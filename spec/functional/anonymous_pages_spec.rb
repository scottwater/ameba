require File.expand_path(File.dirname(__FILE__) +	 '/../spec_helper')

describe "Robots" do
  before(:each) do
    Post.destroy_all
  end

  it 'should find noindex on the archive page' do
    visit path_for(:archive)
    response_body.should have_selector("meta[content='noindex,follow']")    
  end
  it 'should find an index on the home page' do
    check_for_index path_for(:home)
  end
  it 'should find an index on a post page' do
      p = Post.create!(:title => "Hello World", :rawbody => "Hello World", :user => a_user)
      check_for_index path_for(:post, :slug => p.slug)
  end
  
  it 'should find index on the about page' do
    check_for_index path_for(:about)
  end
  
  
  def check_for_index(path)
    visit path
    response_body.should have_selector("meta[content='index,follow']")    
  end
end

describe "Feed Settings" do
  
  before(:each) do
    ENV['AMEBA_FEED'] = nil
  end
  
  after(:each) do
    ENV['AMEBA_FEED'] = nil
  end
  
  it 'should find the standard atom feed link' do
    visit '/'
    response_body.should have_selector("link[type='application/atom+xml']")
    response_body.should have_selector("link[href='http://example.org/atom']")
  end
  
  it 'should find the override atom feed link' do
    ENV['AMEBA_FEED'] = "http://feeds.simpable.com/simpable"
    visit '/'
    response_body.should have_selector("link[type='application/atom+xml']")
    response_body.should have_selector("link[href='http://feeds.simpable.com/simpable']")
  end
  
end

describe "Main Pages" do
		
	before(:each) do	 
	  User.destroy_all
		Post.destroy_all
	end	 
	
	it "should reach the home page and grab the dummy text" do
		visit '/'
		response_body.should contain 'An Ameba Blog'
	end
	
	it "should be able to find a post on the home page" do
		
		Post.create!(:rawbody => "First post in all of it's glory", :title => "The First Post", :user => a_user)
		visit '/'
		response_body.should contain "First post"

	end
	
	it "should find handle proper redirects for slugs" do

		p = Post.create!(:rawbody => "First post in all of it's glory", :title => "The First Post", :user => a_user)
		visit '/'
		response_body.should contain "First post"
    visit path_for(:post, :slug => p.slug)
    last_request.path.should eql(path_for(:post, :slug => p.slug))
	  visit path_for(:post, :slug => p.slug + '/')
	  last_request.path.should eql(path_for(:post, :slug => p.slug))
	end

	
  describe "post paging and archives" do

    before(:each) do
      
      (1..12).each do |i|
        Post.create!(:title => "Post Title -#{i}-", :rawbody => "Post Body #{i}", :created_at => Time.utc(2000, "Jan", i), :user => a_user)
      end
    end

    it "should be able to filter the home page to 10 posts" do
      visit path_for(:home)
      12.downto(3).each do |i|
        response_body.should contain "Post Title -#{i}-"
      end
      
      Post.find_by_title("Post Title -11-").should_not be_nil
      response_body.should_not contain "Post Title -1-"
    end
  
    it "should be able to find posts on the second page" do
      visit '/?page=2'
      response_body.should contain "Post Title -2-"
      Post.find_by_title("Post Title -2-").should_not be_nil
    end
    
    it 'should be able to find all of the posts on the archive page' do
      visit path_for(:archive)
      1.upto(12).each do |i|
        response_body.should contain "Post Title -#{i}-"
      end
    end
    
  end 
end