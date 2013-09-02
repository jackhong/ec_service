require 'sinatra'

get '/' do
  #@info = Resque.info
  erb :index
end

post '/' do
  EcRunner.perform_async(params)
  redirect "/"
end

__END__

@@ index
<html>
  <head><title>Resque Demo</title></head>
  <body>
    <form method="POST">
      <input type="submit" value="Create New Job"/>
    </form>
  </body>
</html>

