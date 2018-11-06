require "rubygems"
require "bundler/setup"
require "shellwords"
require "fileutils"
require "json"
require "hashie"
require "colors"
require "oj"
require "oj/mimic"
require "fileutils"
require "open3"

repos = {
  "arcade" => {
    image: "planetgr/gold-rush-app",
    dockerfile: "config/dockerfiles/app/Dockerfile"
  },
}

namespace :build do

  #  Executes the command and prints its output to the console.
  #
  def execute_command(cmd)
    puts cmd.hl( :yellow )

    Open3.popen3( cmd ) do |stdin, stdout, stderr, thread|
      stdout.each_line { |line| puts line }
      stderr.each_line { |line| puts line }

      unless thread.value.success?
        puts "Command failed".hl( :red )
        exit 1
      end
    end
  end

  desc "Checks that the working directory is clean"
  task :check do
    puts "Checking working directory state...".hl( :green )
    # unless `git status`.include?("nothing to commit, working directory clean")
    #   puts "Please commit everything first".red
    #   exit 1
    # end
  end

  desc "Builds a specific service as per Rake task arguments"
  task(:build, [:service, :tag]) do |task, args|
    service = args[:service]
    tag = args[:tag]

    unless tag =~ /r\d+\.\d+\.\d+/
      puts "Please supply tag in the format of rX.Y.Z".hl( :red )
      exit 1
    end

    FileUtils.cd( service )

    image_name = repos[ service ][ :image ] + ":" + tag

    puts "Building \"#{service}\" Docker image as \"#{ image_name }\"".hl( :green )
    branch, stdout, stderr = Open3.capture3('git symbolic-ref --short -q HEAD')
    execute_command "docker build --build-arg CLONE_BRANCH=#{branch.strip} -f #{ repos[ service ][ :dockerfile ] } -t #{ image_name } ."
    # execute_command "docker build -f #{ repos[ service ][ :dockerfile ] } -t #{ image_name } ."

    puts "Pushing \"#{ image_name }\" image into registry".hl( :green )
    execute_command "docker push #{ image_name }"

    FileUtils.cd( ".." )
  end

  desc "Builds all services known by the build engine"
  task(:all, {[:tag] => :check}) do |task, args|
    tag = args[:tag]

    repos.each do |repo, config|
      Rake::Task["build:build"].invoke(repo, tag)
      Rake::Task["build:build"].reenable
    end
  end

end
