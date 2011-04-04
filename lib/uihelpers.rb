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
		
	  def link_to(link_name, link_url, opts = {})
			opts[:href] = link_url
			attributes = ''
			opts.each {|k,v| attributes = " #{attributes} #{k.to_s}='#{h(v)}'"}
	    "<a#{attributes}>#{link_name}</a>"
	  end		

		def editor_action_link(post)
			post.new? ? path_for(:new) : path_for(:edit, :slug => post.slug)
		end
		
		def editor_button_text(post)
			post.new? ? "Publish" : 'Update Post'
		end

    def smart_path(post)
      post.url.blank? ? path_for(:post, :slug => post.slug) : post.url
    end
    
		def smart_url(post)
      post.url.blank? ? url_for(:post, :slug => post.slug) : post.url
    end

    def smart_footer(post)
      "#{link_to('#', path_for(:post, :slug => post.slug), :title => "Permanent link to '#{post.title}'")} Published <time datetime=\"#{post.created_at.iso8601}\" pubdate=\"true\">#{kronic(post.created_at)}</time>"
    end

		def smart_atom_content(post)

			link = link_to('#', url_for(:post, :slug => post.slug), :title => "Permanent link to '#{post.title}'")

			"#{post.body}<p>#{link} Published #{post.created_at.strftime('%B %e, %Y')}</p>"
		end

    def smart_title(post)
      title = h(post.title)
      post.url.blank? ? title : link_to(title, post.url) 
    end

		#probably needs to be in it's own helper

		def last_updated(posts)
			posts.max{|a,b| greater_value(a.created_at, a.updated_at) <=> greater_value(b.created_at, b.updated_at)}
		end	
		
		def greater_value(obj1, obj2)
		  obj1 > obj2 ? obj1 : obj2
		end

    
    def self.registered(app)
			app.helpers UIHelpers
		end


	
  end
end
