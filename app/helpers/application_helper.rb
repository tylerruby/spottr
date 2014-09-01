module ApplicationHelper

	def has_coordinates?
		session[:coordinates].present?
	end
end
