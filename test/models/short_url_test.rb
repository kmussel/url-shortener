require 'test_helper'

class ShortUrlTest < ActiveSupport::TestCase
  test "the that a unique key is automatically created" do
    shorturl = ShortUrl.create(key: "TestOne", source: "https://test.com")
    assert_not_empty shorturl.key, "Key Created"
  end
end
