require File.expand_path(File.dirname(__FILE__) +	 '/../spec_helper')

describe "Authorized Pages" do

	before(:all) do
	  User.destroy_all
	  User.create!(:email => 'scottwater@gmail.com', :password => '1234', :name => "Scott Watermasysk")
	end
	
	def visit_and_login(path)
    visit path
    follow_redirect!
		last_request.path.should eql(path_for :login)
    fill_in 'email', :with => 'scottwater@gmail.com'
		fill_in 'password', :with => '1234'
		click_button 'user-button'
		follow_redirect!		
		last_request.path.should eql(path)
  end
	
	before(:each) do
		Post.destroy_all
	end	 
	
	it "should render the editor page" do
		visit_and_login path_for(:new)
		response_body.should contain "Feel inspired & write something"
	end
	
	it 'should throw exception if you try to edit a post which does not exist' do
		boom = lambda {visit_and_login path_for(:edit, :slug => 'i-do-not-exist')}
		boom.should raise_exception(MongoMapper::DocumentNotFound) 
	end

	it "should verify the editor fields are properly poulated" do
		visit_and_login path_for(:new)
		field_labeled("Title:").value.should be_nil #todo: why is this nil and not empty
		field_labeled("Body:").value.should be_empty #todo: why is this empty and not nil
	end
	
	it "should verify the editor fields are properly poulated" do
		Post.create!(:rawbody => 'body text', :title => 'Title Text', :user => a_user)
		visit_and_login path_for(:edit, :slug => 'title-text')
		field_labeled("Title:").value.should == "Title Text"
		field_labeled("Body:").value.should == "body text"
	end
	
	it 'should verify a new post is saved and redirected' do
		visit_and_login path_for(:new)
		fill_in 'post[title]', :with => 'Hello World'
		fill_in 'post[rawbody]', :with => 'I am the post body'
		click_button 'post-button'
		follow_redirect!		
		last_request.path.should eql(path_for(:post, :slug => 'hello-world'))
		response_body.should contain "I am the post body"
	end
	
	it 'should verify a new post which is missing a title cannot be saved' do
		visit_and_login path_for(:new)
		fill_in 'post[rawbody]', :with => 'I am the post body'
		click_button 'post-button'
		last_request.path.should eql(path_for(:new))
		response_body.should contain "Title can't be empty"
	end
	
	it 'should verify a new post without a rawbody cannot be saved' do
		visit_and_login path_for(:new)
		fill_in 'post[title]', :with => 'Hello World'
		click_button 'post-button'
		last_request.path.should eql(path_for(:new))
		response_body.should contain "Rawbody can't be empty" #fixme: this is lame. Rawbody should not be here.
		response_body.should contain "Body can't be empty"
	end
	
	describe 'Editing a standard post' do
	  
	  before(:each) do
  		Post.create!(:title => 'Hello World', :rawbody => 'this is a post body', :user => a_user)
      visit_and_login path_for(:edit, :slug => 'hello-world')
  	end
	
  	it 'should allow me to update the title and body' do
  		fill_in 'post[title]', :with => 'Title Changed'
  		fill_in 'post[rawbody]', :with => 'Body Changed'
  	  click_button 'post-button'
		  follow_redirect!  	  
  	  last_request.path.should eql(path_for(:post, :slug => 'hello-world')) #also verifies changing titles does not change the slug
  	  response_body.should contain "Title Changed"
  	  response_body.should contain "Body Changed"

  	end
	
  	it 'should catch a missing title when editing a post' do
  		fill_in 'post[title]', :with => nil
  		click_button 'post-button'
  		last_request.path.should eql(path_for(:edit, :slug => 'hello-world'))
  		response_body.should contain "Title can't be empty"
  	end
	
  	it 'should catch a missing body when editing a post' do
      fill_in 'post[rawbody]', :with => nil
      click_button 'post-button'
      last_request.path.should eql(path_for(:edit, :slug => 'hello-world'))
      response_body.should contain "Rawbody can't be empty" #fixme: this is lame. Rawbody should not be here.
      response_body.should contain "Body can't be empty"    		
    end
    
  end
  
end