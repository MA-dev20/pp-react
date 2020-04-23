class Integer
	def to_minutes
    Time.at(self).utc.strftime("%M:%S").to_s.sub!(/^0/, "")
	end
end