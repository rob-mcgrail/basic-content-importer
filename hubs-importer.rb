require 'bundler/setup'

Bundler.require(:default)
Dotenv.load

Dir['./lib/*.rb'].each {|file| require file }

opts = Slop.parse do
  on '-p', '--path', 'a pathname to convert'
  on '-s', '--selector', 'a CSS selector for what we want to import', default: '#content'
  on '-v', '--verbose', 'enable verbose mode'
  on '-h', '--hidden', 'print hidden characters'
  on '-m', '--markdown', 'output as markdown'
end

path = opts[:path] || ARGV.first
selector = opts[:selector]

unless path
  puts opts
  exit
end


puts "Requesting #{path}".colorize(:green)

response = HTTParty.get(path)

puts "Parsing response down to #{selector}".colorize(:green)

page = Nokogiri::HTML(response.body)
content = page.css(selector).to_s

puts "Sanitizing content".colorize(:green)

clean_content = Sanitize.clean(content, Sanitize::HubsConfig::DEFAULT)

# Strip out annoying white space.
clean_content.gsub!(/[[:blank:]]+/, " ");
clean_content.gsub!(/\n[[:blank:]]+/, "\n");
clean_content.gsub!(/[\n]+/, "\n");

if opts[:markdown]

  ReverseMarkdown.config do |config|
    config.unknown_tags     = :raise
    config.github_flavored  = true
  end

  puts "Converting to Markdown".colorize(:green)
  clean_content = ReverseMarkdown.convert clean_content
end


puts "Done!".colorize(:green)

if opts[:hidden]
  puts clean_content.dump
else
  puts clean_content
end
