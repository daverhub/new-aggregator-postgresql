require "sinatra"
require "pry"
require "csv"
require "pg"
error = nil
article = nil
url = nil
des = nil


def db_connection
  begin
    connection = PG.connect(dbname: "news_aggregator_development")
    yield(connection)
  ensure
    connection.close
  end
end




post "/send" do

  article = params["article"]
  url = params["url"]
  des = params["des"]
  if params["article"] == "" || params["url"] == "" || params["des"] == ""
    error = "please fill out all items in the form"
    redirect "/error"
  elsif params["url"]
  end
  # CSV.open("news.csv", "a+") do |csv|
  #   csv << [article, url, des]
  # end
  db_connection do |conn|
      conn.exec_params("INSERT INTO articles (title,url,description) VALUES ($1,$2,$3)", [article, url, des])
  end

  redirect "/articles/:articles"
end




post "/create_file" do
  db_connection do |conn|
      conn.exec_params("INSERT INTO new_table (title,url,description) VALUES ($1,$2,$3)", [article, url, des])
  end

  redirect "/articles/:articles"
end

get "/articles/file" do


  file = params["file"]
  db_connection do |conn|
    conn.exec("CREATE TABLE table (name varchar(255))")
  end

  erb :file, locals: { file: file }
end

get "/articles/new" do


  article = params["article"]
  url = params["url"]
  des = params["des"]
  clear_error = nil

  erb :index, locals: { errors: clear_error, article: article, url: url, des: des }
end


get "/error" do

  erb :index, locals: { error: error, article: article, url: url, des: des }
end

get "/articles/:articles" do

  news_array = db_connection do |conn|
    conn.exec("SELECT * FROM articles").to_a
  end
  # CSV.foreach('news.csv', headers: true, header_converters: :symbol) do |row|
  #   news_array << row.to_hash
  # end

  erb :articles, locals: { articles: news_array}
end
