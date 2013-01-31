load "./tvlistings.rb"
require "test/unit"
class TestSimpleNumber < Test::Unit::TestCase
    def test_channels
        r = TVListings.new(:date => "2013-01-31", :channels => ["CW", "ABC"]).get
        assert_equal(r["channels"].size, 2)
        assert_equal(r["channels"][0]["name"], "ABC")
        assert_equal(r["channels"][1]["name"], "CW")
        assert_equal(r["channels"][0]["airings"].size, 5)
        assert_equal(r["channels"][1]["airings"].size, 3)
    end
end
