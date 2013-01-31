load "./tvlistings.rb"
Camping.goes :WebTVListings
module WebTVListings::Controllers
    class Index < R '/'
        def get
            redirect Search
        end
    end
    class Search
        def get
            render :search
        end
    end
    class Listings
        def post
            p @input
            @result = TVListings.new(@input).get
            render :listings
        end
    end
end
module WebTVListings::Views
    def layout
        html do
            head do
                title { "TV Listings" }
            end
	    a :href => "http://github.com/yazgoo/tvlistings" do
		    img :style => "position: absolute; top: 0; right: 0; border: 0;",
		    :src => "https://s3.amazonaws.com/github/ribbons/forkme_right_gray_6d6d6d.png",
		    :alt => "Fork me on GitHub"
	    end
            h1 "TV Listings"
            body { self << yield }
        end
    end
    def search
        p "Search listings"
        form :action => R(Listings), :method => :post do
            listings = TVListings.new
            r = listings.get
            h3 :Categories
            categories = []
            r["channels"].each do |channel|
                channel["airings"].each do |airing|
                    categories.push airing["category"] if not categories.include? airing["category"]
                end
            end
            categories.each do |category|
                label category
                input :type => :checkbox, :name => "categories[]", :value => category
            end
            h3 :isNew
            ["true", "false"].each do |isNew|
                label isNew
                input :type => :checkbox, :name => :isNew, :value => isNew
            end
            h3 :Channels
            r["channels"].each do |channel|
                label channel["name"]
                input :type => :checkbox, :name => "channels[]", :value => channel["name"]
            end
            h3 :Date
            select :name => :date do
                listings.available_dates.each do |date|
                    option :value => date do date end
                end
            end
            br
            input :type => :submit, :value => "Ok"
        end
    end
    def listings
        table do
            @result["channels"].each do |channel|
                tr do
                    td :style => "background-color: #dddddd;" do
                        b channel["longName"]
                    end
                    td :style => "background-color: #dddddd;" do
                        table do
                            tr do
                                channel["airings"].each do |airing|
                                    td :style => "background-color: #ededef;" do
                                        b do airing["title"] + " " end
                                        a :style => "background-color: #da4973;" do :new end if airing["isNew"]
                                        div do airing["episodeTitle"] end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
