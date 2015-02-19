require 'pry'
require 'httparty'

def prompt_for_token
  print "Enter your github token: "
  gets.chomp
end

TOKEN = ENV['GITHUB_TOKEN'] || prompt_for_token 

def prompt_for_org
  print "Enter the Org you want to investigate: "
  gets.chomp
end

ORG =  prompt_for_org


class Githubstats
  include HTTParty  
  
  base_uri "https://api.github.com"

  def initialize
    @headers = {
      "Authorization" => "token #{TOKEN}",
      "User-Agent"    => "classbot"
    }
  end

  def members 
    users = self.class.get("/orgs/#{ORG}/members", headers: @headers).map {|x| x["login"]}
    users
  end

  def repos user
    repos = self.class.get("/users/#{user}/repos", headers: @headers)
    user_repos = repos.map {|x| x["name"]}
    user_repos
  end

  def stats user, user_repos
    adds = 0
    deletes = 0
    changes = 0
  
    user_repos.each do |x|
      begin  
        stats = self.class.get("/repos/#{user}/#{x}/stats/contributors", headers: @headers)
        weeks = stats[0]["weeks"]
        adds += weeks.map{|y| y["a"]}.inject(:+)
        deletes += weeks.map{|y| y["d"]}.inject(:+)
        changes += weeks.map{|y| y["c"]}.inject(:+)
      rescue
      end
    end
    puts "#{user} \t\t #{adds} \t\t #{deletes} \t\t #{changes}"
  end

end

api = Githubstats.new
puts "\tUSER\tADDITIONS\tDELETIONS\tCHANGES"

api.members.each do |x|
  api.stats(x, api.repos(x)) 
end

