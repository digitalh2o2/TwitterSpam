require 'socket'
require 'json'


server = TCPServer.open(2000) #socket problems on my machine

loop do #server runs forever
  client = server.accept

#loops until whole header is grabbed
  header = ""
  while line = client.gets
    header << line
    break if header =~ /\r\n\r\n$/
  end

  #parses out method and path from status line
  method = header.split[0]
  path = header.split[1][1..-1]



#if it's a GET request for a valid file, create a GET response
  if method == "GET" && File.exist?(path)
    response_body = (File.open(path, 'r')).read
    response_head = "HTTP/1.0 200 OK\nContent-Length: #{response_body.length}\r\n\r\n"

#if it's a valid POST request
  elsif method == "POST" && File.exist?(path)

  #iterate likewise to grab the request body
    body = ""
    while line = client.gets
      body << line
      break if body =~ /\r\n\r\n$/
    end
    body = body.chomp.chomp #remove the double newline


  #parse out the JSON received into a block of HTML
    params = {}
    params = JSON.parse(body)
    list_entries = ""
    params["viking"].each do |key, value|
      list_entries += "<li>#{key}: #{value}</li>\n      "
    end


  #open the HTML file and create a POST response by subbing in the parameters
    file = File.open(path)
    response_body = file.read.gsub("<%= yield %>", list_entries)
    response_head = "HTTP/1.0 200 OK\nContent-Length: #{response_body.length}\r\n\r\n"

  else
    response_head = ("HTTP/1.0 404 Not Found\r\n\r\n")
    response_body = ("Sorry, file not found.")
  end

#whatever the response is, output it here and close
  client.puts(response_head)
  client.puts(response_body)
  client.close
end