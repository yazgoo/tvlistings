load "./tvlistings.rb"
require "test/unit"
class Tests < Test::Unit::TestCase
    def test_channels
        r = TVListings.new(:date => "2013-01-31", :channels => ["CW", "ABC"],
                           :cache => "./tests/cache/").get
        assert_equal(r["channels"].size, 2)
        assert_equal(r["channels"][0]["name"], "ABC")
        assert_equal(r["channels"][1]["name"], "CW")
        assert_equal(r["channels"][0]["airings"].size, 5)
        assert_equal(r["channels"][1]["airings"].size, 3)
    end
    def test_all
        r = TVListings.new(:date => "2013-01-31",
                           :cache => "./tests/cache/").get
        r["channels"].each do |channel| puts channel["name"] end
    end
end
