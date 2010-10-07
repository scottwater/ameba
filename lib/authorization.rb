module Sinatra
	module Authorization
	  
	  def logout!
	    session[:auth] = nil
	    redirect path_for(:home)
	  end
	  
	  def login_required!
	    if logged_in?
	      return false
	    else
	      session[:return_to] = request.fullpath
	      redirect path_for(:login)
	    end

	  end
	  
		def logged_in?
			session[:auth].present?
		end

		def current_user
			logged_in? ? User.find_by_id(session[:auth]) : nil
		end
		
		def authorize(email, pass)
		  user = User.authenticate(email,pass)
		  session[:auth] = user ? user.id : nil
		  !!session[:auth]
		end

		def self.registered(app)
			app.helpers Authorization
		end
	end
end