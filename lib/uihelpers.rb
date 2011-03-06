require 'kronic'
require 'rack'

module Sinatra
  module UIHelpers
    
    def kronic(date)
      Kronic.format date, :format => "%B %e, %Y"
    end
    
    def h(text)
			Rack::Utils.escape_html(text)
		end
		
    def n(number, delimiter=",")
      number.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
    end		
		
	  def link_to(link_name, link_url)
	    "<a href=\"#{link_url}\">#{link_name}</a>"
	  end		

		def editor_action_link(post)
			post.new? ? path_for(:new) : path_for(:edit, :slug => post.slug)
		end
		
		def editor_button_text(post)
			post.new? ? "Publish" : 'Update Post'
		end
    
    def self.registered(app)
			app.helpers UIHelpers
		end

		#probably needs to be in it's own helper

		def last_updated(posts)
			posts.max{|a,b| a.updated_at <=> b.updated_at}
		end	

    
  end
end
