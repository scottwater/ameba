require File.expand_path(File.dirname(__FILE__) +  '/../spec_helper')
require 'slugger'

describe Slugger do
  
  it "should downcase the slug" do
    slug = Slugger.new "TITLE"
    slug.to_slug.should eql("title")
  end
  
  it "should remove stop words" do
    slug = Slugger.new "a title"
    slug.to_slug.should eql("title")
  end
  
  it "should remove leading and trailing white space" do
    slug = Slugger.new "    title     "
    slug.to_slug.should  eql("title")
  end
  
  it "should replace spaces with -" do
    slug = Slugger.new "title title"
    slug.to_slug.should eql("title-title")
    
  end
  
  it "should ensure slugs are less than 25 characters return only 5 words" do
    slug = Slugger.new "abcdef "*10
    slug.to_slug.should eql("abcdef-abcdef-abcdef-abcdef-abcdef")
  end
  
  it "should ensure an empty slug get a #post default" do
    slug = Slugger.new "a an the"
    slug.to_slug.should eql("post")
  end
  
  it "should ensure reserved words cannot be used alone as a slug" do
    
    Slugger::RESERVED_WORDS.each do |word|
      slug = Slugger.new word
      slug.to_slug.should eql("#{word}-post")
    end
    
  end
    
end

describe "Partial Slug Validation" do

  it "should leave in stop words" do
    slug = Slugger.new "A TITLE", false
    slug.to_slug.should eql("a-title")
  end
  
  it "should ensure slug length is not modified" do
    slug = Slugger.new "abcdef "*10, false
    slug.to_slug.should eql("abcdef-abcdef-abcdef-abcdef-abcdef-abcdef-abcdef-abcdef-abcdef-abcdef")
  end
  
end

describe "Custom Slug Validation" do
  
  it "should fail and return once" do
    slugger = Slugger.new "title"
    slug = slugger.to_slug do |temp|
      temp == "title"
    end
    
    slug.should eql("title-2")
  end

  it "should fail and iterate 3 times" do
    
    slugger = Slugger.new "title"
    slug = slugger.to_slug do |temp|
      temp == "title" || temp == "title-2" || temp == "title-3"
    end
    
    slug.should eql("title-4")
    
  end
end
  

