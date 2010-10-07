require File.expand_path(File.dirname(__FILE__) +  '/../spec_helper')

describe Post do
  
  before(:each) do
    User.destroy_all
    Post.destroy_all
  end
  
  describe "simple post tests" do
    
    before(:each) do
      @content = load_test_data_to_h "simplepost.txt"
      @post = Post.create! :rawbody => @content[:content], :title => @content[:title], :user => a_user
    end
    
    it "should save a post" do
      @post.title.should eql("Simple Post")
    end
    
    it 'should save a post' do
      @post.title.should == "Simple Post"
    end

    it 'should catch a duplicate post' do
      post =  Post.create! :rawbody => @content[:content], :title => @content[:title], :user => a_user
      post.slug.should eql("simple-post-2")
    end
    
  
   it 'should not be able to update a post with a nil title' do
     post = Post.find_by_slug("simple-post")
     lambda {post.save!}.should_not raise_exception
     post.title = nil
     lambda{ post.save!}.should raise_exception(MongoMapper::DocumentNotValid)   
    end
  end

  describe "Slugs" do
    
    it 'should be able to name your own slug' do
      content = load_test_data_to_h "customslug.txt"
      post = Post.create! :rawbody => content[:content], :title => content[:title], :slug => content[:slug], :user => a_user
      post.title.should eql("Simple Post")
      post.slug.should eql("not-a-simple-post")
    end

    it 'custom slugs should get autoimcremented' do
      content = load_test_data_to_h "customslug.txt"
      Post.create! :rawbody => content[:content], :title => content[:title], :slug => content[:slug], :user => a_user
    
      post = Post.create! :rawbody => content[:content], :title => content[:title], :slug => content[:slug], :user => a_user
      post.slug.should eql("not-a-simple-post-2")
    end
  end
    
  describe "Next & Previous" do
    
    before(:each) do
      Post.create(:title => "p1", :rawbody => "x", :created_at => Time.utc(2000, "Jan", 1), :user => a_user)
      Post.create(:title => "p2", :rawbody => "x", :created_at => Time.utc(2001, "Jan", 1), :user => a_user)
      Post.create(:title => "p3", :rawbody => "x", :created_at => Time.utc(2002, "Jan", 1), :user => a_user)
      Post.create(:title => "p4", :rawbody => "x", :created_at => Time.utc(2003, "Jan", 1), :user => a_user)
      Post.create(:title => "p5", :rawbody => "x", :created_at => Time.utc(2004, "Jan", 1), :user => a_user)
    end
    
    it 'should result in a error if we try to use next and previous on a new post' do
      lambda{Post.new.next}.should raise_exception
      lambda{Post.new.previous}.should raise_exception
    end
    
    it 'should be able find the next post' do
      
      post = Post.find_by_slug('p1')
      post.should_not be_nil
      
      2.upto(5).each do |i|
        post = post.next
        post.title.should eql("p#{i}")
      end
      
      post.next.should be_nil
      
    end

    it 'should be able find the previous post' do
      
      post = Post.find_by_slug('p5')
      post.should_not be_nil

      4.downto(1).each do |i|

        post = post.previous
        post.title.should eql("p#{i}")
      end


      post.previous.should be_nil
      
    end

    
  end
  
end