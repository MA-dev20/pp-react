module TasksHelper
    def format_time time
        Time.at(time).utc.strftime("%M:%S").sub!(/^0/, "")
    end
end