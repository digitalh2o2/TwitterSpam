require 'net/http'

host = 'www.htmldog.com'
path = '/guides/html/beginner/'

http = Net::HTTP.new(host)
headers, body = http.get(path)
if headers.code == "200"
	puts body
else
	puts "#{headers.code} #{headers.message}"
end