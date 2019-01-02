source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'sinatra'
gem "sinatra-cross_origin", "~> 0.3.1"
gem 'puma'
gem 'json'
gem 'pi_piper'
gem 'httparty'
gem 'dotenv'
