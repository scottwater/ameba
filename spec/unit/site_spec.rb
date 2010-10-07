require File.expand_path(File.dirname(__FILE__) +  '/../spec_helper')


describe Site do
  
  def reset_site_attrs
    ENV['AMEBA_TITLE'] = nil
    ENV['AMEBA_SUBTITLE'] = nil
    ENV['AMEBA_FEED'] = nil
  end
    
  
  before(:each) do
    reset_site_attrs
  end
  
  after(:each) do
    reset_site_attrs
  end

  it 'should be able to read the default site settings' do
    site = Site.new
    site.title.should eql("An Ameba Blog")
    site.subtitle.should eql("You should change this value")
    site.feed.should be_nil
  end
  
  it 'should be able to change the default site settings' do
    ENV['AMEBA_TITLE'] = "changed"
    ENV['AMEBA_SUBTITLE'] = "changed"
    ENV['AMEBA_FEED'] = "changed"
    site = Site.new
    site.title.should eql("changed")
    site.subtitle.should eql("changed")
    site.feed.should eql("changed")        
  end
  
end