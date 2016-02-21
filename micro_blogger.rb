require 'jumpstart_auth'
require 'bitly'

class MicroBlogger
	attr_reader :client

	def initialize
		puts "Initializing MicroBlogger"
		@client = JumpstartAuth.twitter
	end

	def tweet(message)
		if message.length <= 140
			puts @client.update(message) 
		else 
			puts "Too many characters!"
		end
	end

	def dm(target, message)
		screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
		if screen_names.include?(target)
			puts "Trying to send #{target} this direct message"
			puts message
			message = "d @#{target} #{message}"
			tweet(message)		
		else
			puts "You can only Direct Message your followers!"
		end
	end

	def followers_list
		screen_names = []
		@client.followers.each do |follower|
			screen_names << @client.user(follower).screen_name
		end
		return screen_names
	end

	def spam_my_followers(message)
		followers = followers_list
		followers.each do |follower|
			dm(follower, message)
		end		
	end

	def everyones_last_tweet
		friends = []
		@client.followers.each do |follower|
			friends << @client.user(follower)
		end
		friends.sort_by! { |friend| friend.screen_name.downcase }
		friends.each do |friend|
			timestamp = friend.status.created_at
			last_message = friend.status.text

			puts "#{friend.screen_name} at #{timestamp.strftime("%A, %b, %d")} said..."
			puts last_message
			puts ""
		end
	end

	def shorten(original_url)
		puts "Shortening this URL: #{original_url}"
		Bitly.use_api_version_3
		bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
		short_url = bitly.shorten(original_url).short_url
		puts "The new URL is #{short_url}"
	end

	def run
		puts "Weclome to the JSL Twitter Client!"
		command = ""
		while command != "q"
			printf "enter command: "
			input = gets.chomp
			parts = input.split(" ")
			command = parts[0]

			case command
			when "q" then puts "Goodbye!"
			when "t" then tweet(parts[1..-1].join(" "))
			when "dm" then dm(parts[1], parts[2..-1].join(" "))
			when "spam" then spam_my_followers(parts[1..-1].join(" "))
			when "flt" then everyones_last_tweet
			when "s" then shorten(parts[1..-1].join(" "))
			when "turl" then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
			else
				puts "Sorry, I don't know how to #{command}"
			end
		end
	end
end

blogger = MicroBlogger.new
blogger.run

