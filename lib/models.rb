require 'mongodb'
autoload :Slugger, 'slugger'
autoload :RedCloth, 'redcloth'


#keeping Site simple and only supporting values which are used
#in more than one location. Sidebar and About will simply be set in
#the views
class Site

   #semi borrowed from active_support/core_ext/module_attr_accessor_with_default
   def self.attr_env_reader(sym, opts={})
     define_method(sym, Proc.new{ENV["#{opts[:namespace]}#{sym.to_s.upcase}"] || opts[:default] })
   end
   
   attr_env_reader :title, :namespace => 'AMEBA_', :default => 'An Ameba Blog'
   attr_env_reader :subtitle, :namespace => 'AMEBA_', :default =>'You should change this value'
   # attr_env_reader :timezone_offset, :namespace => 'AMEBA_', :default => 0
   attr_env_reader :feed, :namespace => 'AMEBA_'

	 def timezone_offset
		 ( ENV['AMEBA_TIMEZONE_OFFSET'] || '0').to_i
	 end
  
end

class User
  include MongoMapper::Document
  
  key :name, String, :required => true
  key :email, String, :required => true, :unique => true
  key :password, String, :required => true
  key :salt, String, :required => true

  many :posts
  
  before_validation_on_create :creating_new_user
  before_validation_on_update :updating_existing_user
  
  def creating_new_user
    
    self.email = self.email.downcase if self.email
    
    if(self.password)
      self.salt = User.random_string(10)
      self.password = User.encrypt(self.password, self.salt)
    end
  end
  
  def updating_existing_user
    
    self.email = self.email.downcase if self.email && self.email_changed?
    
    
    if(self.password_changed?)
      self.salt = User.random_string(10)
      self.password = User.encrypt(self.password, self.salt)
    end
  end
  
  def self.authenticate(email, pass)
    user = User.find_by_email(email.downcase)
    (user && user.password == User.encrypt(pass, user.salt)) ? user : nil
  end

  #borrowed and stole encrypt and random_string from Sinatra Authentication
  
  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest(pass+salt)
  end

  def self.random_string(len)
    #generate a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end  
  
end

class Post
  include MongoMapper::Document
  
  key :title, String, :required => true, :allow_blank => false
	key :url, String 
  key :rawbody, String, :required => true, :allow_blank => false
  key :body, String, :required => true, :allow_blank => false
  key :slug, String, :required => true, :allow_blank => false, :unique => true, :index => true
  key :user_id, ObjectId, :required => true
  key :views, Integer, :default => 0
  timestamps!
  belongs_to :user
  
  before_validation_on_create :create_before_validation
  before_validation_on_update :update_before_validation
  
  scope :sorted, sort(:created_at.desc)
  scope :filtered, query.ignore(:rawbody)
  scope :light, query.only(:title, :slug, :created_at, :views)
  
	def when 
		self.created_at.since(Site.new.timezone_offset.hours).localtime.strftime("%b %d, %Y at %l:%M %p") unless self.created_at.nil?
	end

  def self.published
    where(:created_at.lte => Time.current.utc)
  end

  def self.not_published
    where(:created_at.gte => Time.current.utc)
  end


  def self.recent(page_size=10, page=0)
   page = page.to_i
   q = sorted.filtered.limit(page_size)
   q = q.skip(page_size * (page - 1)) if page > 1
   q.published
  end
  
  def self.popular(page_size=10)
    light.sort(:views.desc).limit(page_size).all
  end
  
  def self.archive()
    sorted.light.published
  end

	def self.queued()
		light.not_published.sort(:created_at.asc)
	end
  
  def next()
    raise "cannot use next on a new post" if new?
    Post.sort(:created_at).where(:created_at.gte => self.created_at, :_id.ne => self.id).first
  end
  
  def previous()
    raise "cannot use previous on a new post" if new?
    Post.sort(:created_at.desc).where(:created_at.lte => self.created_at, :_id.ne => self.id).first
  end
  
  def increment_views()
    Post.collection.update({:_id => self.id}, {'$inc' => {:views => 1}})
  end
  
  private 
  
  def create_before_validation
    set_standard_values do |slg|
      Post.exists?(:slug => slg)
    end
  end

  def update_before_validation
    set_standard_values do |slg|
      Post.exists?(:slug => slg, :_id.ne => self._id)
    end
  end
  
  def set_standard_values(&blog_validation)
    self.slug = Slugger.new(self.slug || self.title, !(!!self.slug)).to_slug(&blog_validation) if self.new?
    self.body = RedCloth.new(self.rawbody).to_html 
  end
  
end
