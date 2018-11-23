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
  'arcade' => {
    image: 'planetgr/arcade',
    dockerfile: 'config/dockerfiles/app/Dockerfile',
    command: proc { |tag| "mix build #{tag ? tag : ''}" },
  },
  'challenge' => {
    image: 'planetgr/challenge',
    dockerfile: 'config/dockerfiles/app/Dockerfile',
    command: proc { |tag| "mix build #{tag ? tag : ''}" },
  },
}

namespace :build do
  desc "Builds all services known by the build engine"
  task(:all, [:tag]) do |_, args|
    tag = args[:tag]

    repos.each do |repo, _|
      FileUtils.cd(repo)
      exec(repos[repo][:command].call(tag))
      FileUtils.cd('..')
    end
  end

end
