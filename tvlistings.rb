#!/usr/bin/env ruby
require 'rubygems'
require 'open-uri'
require 'json'
require 'fileutils'
class Array
    def select!
        values = []
        each { |x| values.push x if yield x }
        clear
        values.each { |x| push x }
    end
end
class TVListings
    def available_dates
        entries = Dir.entries(@cache_dir)
        entries.delete "."
        entries.delete ".."
        entries
    end
    def channel_matches channel, parameters
        parameters[:channels].nil? or parameters[:channels].include? channel["name"]
    end
    def airing_matches airing, parameters
        (parameters[:isNew].nil? or parameters[:isNew] == airing["isNew"].to_s)\
            and (parameters[:categories].nil? or parameters[:categories].include? airing["category"])
    end
    def load_cached_listing parameters
        FileUtils.mkdir_p @cache_dir
        file_path = "#{@cache_dir}#{parameters[:date]}"
        url = "http://www.sidereel.com/_television/tvlistings.json?time_zone=EST"
        file = File.exists?(file_path) ? open(file_path) : open(url, "UserAgent" => "tvlistings")
        contents = file.read
        listings = JSON.parse(contents)
        date = listings["globalStartTime"].split("T")[0]
        file_path =  "#{@cache_dir}#{date}"
        File.new(file_path, "w").write contents if not File.exists? file_path
        file.close
        throw "could not find a listing for #{parameters[:date]}\
        on server nor on cache, server answered with #{date} "\
        if date != parameters[:date]
        @listings = listings
    end
    def initialize(parameters = {})
        parameters = Hash[parameters.map{ |k, v| [k.to_sym, v] }]
        @cache_dir = (parameters[:cache_dir].nil? ? "#{ENV["HOME"]}/.cache/tvlistings/" : parameters[:cache_dir]) + "/"
        [:channels, :categories].each do |name|
            parameters[name] = [parameters[name]] if parameters[name].kind_of? String
        end
        parameters[:date] = Time.now.strftime("%F") if parameters[:date].nil?
        load_cached_listing parameters
        @listings["channels"].select! do |channel|
            if channel_matches channel, parameters 
                channel["airings"].select! do |airing|
                    airing_matches airing, parameters
                end
            else
                false
            end
        end
    end
    def get
        @listings
    end
    def puts
        @listings["channels"].each do |channel|
            channel["airings"].each do |airing|
                Kernel.puts "#{channel["longName"]}: #{airing["title"]}: #{airing["episodeTitle"]} at #{airing["startTime"]}"
            end
        end
    end
end
