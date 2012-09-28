# Dependencies
require 'jumpstart_auth'
require 'bitly'
require 'klout'


# Class Definition
class JSTwitter
	#attr_reader :client

	def initialize
		puts "Initializing"
		@client = JumpstartAuth.twitter
		@k = Klout::API.new('6f2zva63qwtan3hgwvesa7b8')
	end

	def tweet(message)
		if message.length <= 140
			@client.update(message)
		else
			puts "Tweets must be 140 characters or less."
		end	 
	end

	def run
		puts "Welcome to the JSL Twitter client!"
		command = ""
		while command != "q"
			printf "enter command: "
			input = gets.chomp
			parts = input.split
			command = parts[0]
			case command
				when 'q' then puts "Goodbye!"
				when 't' then tweet(parts[1..-1].join(" "))
				when 'dm' then dm(parts[1], parts[2..-1].join(" "))
				when 'spam' then spam_my_followers(parts[1..-1].join(" "))
				when 'elt' then everyones_last_tweet
				when 's' then shorten(parts[1..-1].join(" "))
				when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
				else
					puts "Sorry, I don't know how to #{command}"
			end
		end	
	end

	def dm(target, message)
		# Note: target is case sensitive
		screen_names = @client.followers.collect{|follower| follower.screen_name}
		#puts screen_names
		text = "d #{target} #{message}"
		if screen_names.include?("#{target}")
			tweet(text)
			puts "Trying to send #{target} this direct message"
			puts message
		else
			puts "Oops! #{target} doesn't follow you."
		end
	end	

	def followers_list
		screen_names = []
		@client.followers.each do |follower|
			screen_names << follower["screen_name"]
		end
		return screen_names
	end

	def spam_my_followers(message)
		followers_list.each do |follower|
			dm(follower, message)
		end
	end		

	def everyones_last_tweet
		friends = @client.friends
		friends = friends.sort_by{|friend| friend.screen_name.downcase}
		friends.each do |friend|
			timestamp = friend.status.created_at
			timestamp = timestamp.strftime("%A, %b %d")
			#find each friend's last messae
			message = friend.status.text
			#print each friend's screen_name
			puts friend.screen_name + " said this on " + timestamp
			#print each friend's last message
			puts message
			puts "" # Just print a blank line to separate people
		end
	end

	def shorten(original_url)
		Bitly.use_api_version_3
		bitly = Bitly.new('o_7sdokp1men','R_606b3d1d375183d7a6293cbccdc823ae')
		# Shortening code		
		puts "Shortening this URL: #{original_url}"
		puts bitly.shorten("#{original_url}").short_url
		return bitly.shorten("#{original_url}").short_url
	end

	def klout_score
		friends = @client.friends.collect{|f| f.screen_name}
		friends.each do |friend|
			# print friend's screen name
			puts friend
			# print friend's klout score
			puts @k.klout("#{friend}")["users"][0]["kscore"]
			puts "" # Print a blank line to separate each friend
		end
	end
end

# Script
jst = JSTwitter.new
#jst.run
jst.klout_score



