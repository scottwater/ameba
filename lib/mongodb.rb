require 'mongo_mapper'

if ENV['MONGOHQ_URL']
    mongo_uri = URI.parse(ENV['MONGOHQ_URL'])
    ENV['MONGOMAPPER_HOST'] = mongo_uri.host
    ENV['MONGOMAPPER_PORT'] = mongo_uri.port.to_s
    ENV['MONGOMAPPER_USERNAME'] = mongo_uri.user
    ENV['MONGOMAPPER_PASSWORD'] = mongo_uri.password
    ENV['MONGOMAPPER_DATABASE'] = mongo_uri.path.gsub("/", "")
end

mongo_host =     ENV['MONGOMAPPER_HOST']      || 'localhost'
mongo_db  =      ENV['MONGOMAPPER_DATABASE']  || "ameba-#{ENV['RACK_ENV']}"
mongo_port =     ENV['MONGOMAPPER_PORT']      || Mongo::Connection::DEFAULT_PORT
mongo_user =     ENV['MONGOMAPPER_USERNAME']
mongo_password = ENV['MONGOMAPPER_PASSWORD']

MongoMapper.connection = Mongo::Connection.new(mongo_host,mongo_port, :logger => nil)
MongoMapper.database = mongo_db
MongoMapper.connection[mongo_db].authenticate(mongo_user,mongo_password) if mongo_user && mongo_password