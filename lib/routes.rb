module Sinatra
	module Routes
	      	  
	  #home, post, new, edit, rss, login, logout
	  
	  #todo: consider using 'padrino-core/application/routing' in the future
	  #todo: combine this with the main route declarations. not dry!
	  	  
	  def path_for (name, opts=nil)
	    build_path_or_url name, false, opts
	  end
	  
	  def url_for (name, opts=nil)
	    build_path_or_url name, true, opts
	  end
	  
	  def build_path_or_url(name,include_domain,opts=nil )
	    base_url = include_domain ? url_for_root : ''
	    
	    result = case name
        when :home then '/'
        when :post then ''
  	    else "/#{name}"
	    end
	    
	    #ruby < 1.9.1 does not keep the sort order on hashes. 
	    # this will appear to work today because there is never more than key per route
	    opts.each_key{|key| result = "#{result}/#{opts[key]}"} if opts
	    base_url + result
	  end
	  
	  def url_for_root
	    full_path_len = request.fullpath.size * -1
	    request.url[0...full_path_len]
	  end

		def url_for_feed(feed_url)
			feed_url ? feed_url : url_for(:atom)
		end
	  
	  def self.registered(app)
			app.helpers Routes
		end
		
	end
end
