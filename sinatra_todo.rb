require 'rubygems'
require 'sinatra'

script_path = Dir.chdir(File.expand_path(File.dirname(__FILE__))) { Dir.pwd }
lib_path = Dir.chdir(script_path + '/lib') { Dir.pwd }
$:.unshift lib_path

require 'todo'

TODO_FILE = ENV['TODO_FILE'] || ARGV[0] || './todo'

# Stupid simple auth
use Rack::Auth::Basic do |username, password|
  username == 'admin' && password == 'todos'
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  
  def all_priorities
    Todo.priorities
  end

  def link_to_priority(priority)
    "<a href='/priority/#{priority}'>#{priority}</a>"
  end

  def all_tags
    Todo.tags
  end

  def link_to_tag(tag)
    "<a href='/tagged/#{tag}'>##{tag}</a>"
  end

  def edit_link(todo)
    "<a class='small' href='/edit/#{todo.line_number}'>(edit)</a>"
  end
end

get '/' do
  @todos = Todo.active
  erb :index
end

get '/all' do
  @todos = Todo.all
  erb :index
end

get '/priority/:priority' do
  @todos = Todo.find_by_priority(params[:priority])
  erb :index
end

get '/tagged/:tag' do
  @todos = Todo.find_by_tag(params[:tag])
  erb :index
end

get '/add' do
  if params.empty?
    erb :add
  else
    redirect '/', 303
  end
end

post '/add' do
  open(TODO_FILE,'a') { |f| f.puts(params[:todo]) }
  redirect '/', 303
end

get '/edit/:line' do
  @todo = Todo.find(params[:line])
  erb :edit
end

put '/update' do
  @todo = Todo.find(params[:line])
  @todo.update(params[:todo])
  redirect '/', 302
end
