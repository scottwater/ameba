class Slugger
  
  STOP_WORDS = %w{a an and are as at be but by for if in into is it no of on or such that the their then there these they this to was will with}
  RESERVED_WORDS =  %w{update edit feed rss create new tag login logout atom about archive}
  
  def initialize(text_to_slug, validate=true)
    @slug = text_to_slug
    @validate = validate
  end
  
  def to_slug(&block)
    
    #this will allow us to safely re-run to_slug if necessary
    slug = @slug.downcase.strip
    
    if @validate
      slug = clean(slug)
    end
    
    slug = slug.strip.gsub(/ +/,'-')
    slug = (slug.split('-')[0...5]).join('-') if slug.size > 25 && @validate
    
    slug = check_words(slug)
    
    if block_given?
      slug = run_validation(slug, &block)
    end
    
    slug
    
  end
  
  private 
  
  def clean(slug)
    slug = slug.gsub(/[\W_-]/, ' ')
    slug = slug.split(' ').select{|s| s unless s.empty?}.collect{|s| s unless STOP_WORDS.include?(s)}.join(' ')
    slug
  end
  
  def check_words(slug)
    slug = 'post' if slug.empty?
    slug = "#{slug}-post" if  RESERVED_WORDS.include?(slug)
    slug
  end
  
  def unique_slug(slug, text)
    "#{slug}-#{text}"
  end
  
  def run_validation(slug,&block)
       i=1
       
       loop do
         i+=1
         break unless block.call(unique_slug(slug,i))
       end if block.call(slug)
       
      slug = unique_slug(slug,i) if i > 1    
      slug
    
  end
  
end