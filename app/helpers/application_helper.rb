module ApplicationHelper

	def has_coordinates?
		!!session[:coordinates]
	end
end
