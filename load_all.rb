# run pry -r <path/to/this/file> to load entire application

require_relative 'require_app'
require_app
include YouFind
include Database

def app = YouFind::App