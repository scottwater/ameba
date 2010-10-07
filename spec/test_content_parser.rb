require 'yaml'
require 'date'
require 'uri'

module ContentParser 
  
  #todo: Could ContentParser get initialized and handle the same tasks?
  
  #todo: split into smaller pieces. doing too much
  def self.to_frontmatter(content)
    
    data = {}
    if content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
       content = content[($1.size + $2.size)..-1]
       
       YAML.load($1).each_pair do |key,value|
         data[normalized_key(key)] = value
       end
       
       data[:tags] = check_tags(data[:tags]) unless data[:tags].instance_of? Array
       data[:format] = 'textile' unless data[:format]
       data[:date] = DateTime.parse(data[:date]) if data[:date]
       data[:date] = DateTime.parse(data[:rawDate]) if data[:rawDate] && !(!!data[:date])
       
       #puts "Raw Date #{data[:rawDate]}"
      
      if(data[:old_url])
        u = URI.parse(data[:old_url])
        data[:slug] = u.path[1..u.path.size-2]
      end

      
    end
    
    raise 'content already exists in the front matter' if data.include? :content
    
    data[:content] = content.strip
    
    data
    
  end
  
  private 

  NORMALIZED_FIELDS = {:t => :title, :permalink => :slug, :f => :format, :rawDate => :date}


  def self.check_tags(tags)
    tags.to_s.split(',').map{|s| s.strip}
  end

  def self.normalized_key(key)
    NORMALIZED_FIELDS.default = key.to_sym
    NORMALIZED_FIELDS[key]
  end

    
end