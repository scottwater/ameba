require File.expand_path(File.dirname(__FILE__) +	 '/../spec_helper')

describe "Login and Logout" do
  
  before(:all) do
    User.destroy_all
    User.create!(:email => 'scottwater@gmail.com', :password => '1234', :name => "Scott Watermasysk")
  end
  
  it "should allow me to log in" do
    visit path_for(:login)
    fill_in 'email', :with => 'scottwater@gmail.com'
		fill_in 'password', :with => '1234'
		click_button 'user-button'
		last_request.path.should eql(path_for(:home))
    
  end
  
  #fixme the logic here is garbage. Need to figure out how to get access to the session hash and properly verify logging out
  it "should allow me to login and then logout" do
    visit path_for(:login)
    fill_in 'email', :with => 'scottwater@gmail.com'
		fill_in 'password', :with => '1234'
		click_button 'user-button'
		last_request.path.should eql(path_for(:home))
		visit path_for(:logout)
		visit path_for(:new)
		last_request.path.should eql(path_for(:login))
    
  end

  it 'should say my credentials are not valid' do
    visit path_for(:login)
    fill_in 'email', :with => 'not_scottwater@gmail.com'
	  fill_in 'password', :with => '1234'
		click_button 'user-button'
    last_response.should contain "Invalid email/password combination"
    
    fill_in 'email', :with => 'scottwater@gmail.com'
	  fill_in 'password', :with => '7890'
		click_button 'user-button'
    last_response.should contain "Invalid email/password combination"
    
    visit path_for(:login)
		click_button 'user-button'
    last_response.should contain "Invalid email/password combination"    
    
  end
  
  it 'should redirect me to the login page when I request /new' do
    visit path_for(:new)
    last_request.path.should eql(path_for(:login))
  end

  it 'should redirect me to the login page when I request /edit/some-page' do
    visit path_for(:edit, :slug => 'some-page')
    last_request.path.should eql(path_for(:login))
  end
  
end

