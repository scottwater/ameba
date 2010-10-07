require File.expand_path(File.dirname(__FILE__) +  '/../spec_helper')

describe User do
  
  before(:each) do
    User.destroy_all
    User.create!(:email => 'scottwater@gmail.com', :password => '1234', :name => "Scott Watermasysk")
  end
  
  it 'should allow a user to be created' do
    User.count.should eql(1)
    User.create!(:email => 'scottwater+test@gmail.com', :password => '1234', :name => "Scott Watermasysk")
    User.count.should eql(2)
  end
  
  it 'should allow a user to be authenticated' do
    user = User.authenticate('scottwater@gmail.com', '1234')
    user.should_not be_nil
    user.email.should eql('scottwater@gmail.com')
  end
  
  it 'should disallow a user with invalid credentials' do
    user = User.authenticate('scottwater@gmail.com', '5678')
    user.should be_nil
  end
  
  it 'should not allow two users with the same email address' do
    lambda {User.create!(:email => 'scottwater@gmail.com', :password => '1234')}.should raise_exception(MongoMapper::DocumentNotValid)
    lambda {User.create!(:email => nil, :password => nil)}.should raise_exception(MongoMapper::DocumentNotValid)
  end
  
  it 'should change the password hash only when the password is changed' do
    user = User.find_by_email('scottwater@gmail.com')
    pass_hash = user.password.dup
    user.save()
    pass_hash.should eql(user.password)
    user.password = 'newpassword'
    user.save()
    pass_hash.should_not eql(user.password)
  end
  
  it 'should ignore the case of a users email address' do
    User.authenticate("SCOTTWATER@GMAIL.com", "1234").should_not be_nil
  end
  
  it 'should lowercase all email addresses' do
    User.create!(:email => 'SCOTT@GMAIL.com', :password => '1234', :name => "Scott")
    User.find_by_email('scott@gmail.com').should_not be_nil
    User.authenticate('scott@gmail.com', '1234').should_not be_nil
  end
  
end