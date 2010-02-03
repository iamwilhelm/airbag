require 'test/unit'
require 'tyra'

class TyraTest < Test::Unit::TestCase
  def setup
    @tyra = Tyra.new(2)
  end

  def test_can_lookup
    expected = [{'dim' => 'oil|production', 'source_name' => 'fake', 'description' => 'Info about oil', 'default' => 'Year', 'url' => 'http://www.graphbug.com/fakedata_oil_1995.csv', 'publish_date' => 'Sun Jan 01 00:00:00 -0500 1995', 'units' => 'Barrels'},
                {'dim' => 'oil', 'source_name' => 'fake', 'description' => 'Info about oil', 'default' => 'Year', 'url' => 'http://www.graphbug.com/fakedata_oil_1995.csv', 'publish_date' => 'Sun Jan 01 00:00:00 -0500 1995', 'units' => 'Barrels'},
                {'dim' => 'oil|consumption`heat', 'source_name' => 'fake', 'description' => 'Info about oil', 'default' => 'Year', 'url' => 'http://www.graphbug.com/fakedata_oil_1995.csv', 'publish_date' => 'Sun Jan 01 00:00:00 -0500 1995', 'units' => 'Barrels'},
                {'dim' => 'oil|consumption`kill', 'source_name' => 'fake', 'description' => 'Info about oil', 'default' => 'Year', 'url' => 'http://www.graphbug.com/fakedata_oil_1995.csv', 'publish_date' => 'Sun Jan 01 00:00:00 -0500 1995', 'units' => 'Barrels'},
                {'dim' => 'oil|consumption', 'source_name' => 'fake', 'description' => 'Info about oil', 'default' => 'Year', 'url' => 'http://www.graphbug.com/fakedata_oil_1995.csv', 'publish_date' => 'Sun Jan 01 00:00:00 -0500 1995', 'units' => 'Barrels'},
                {'dim' => 'oil|consumption`motor', 'source_name' => 'fake', 'description' => 'Info about oil', 'default' => 'Year', 'url' => 'http://www.graphbug.com/fakedata_oil_1995.csv', 'publish_date' => 'Sun Jan 01 00:00:00 -0500 1995', 'units' => 'Barrels'},
                {'dim' => 'oil|total', 'source_name' => 'fake', 'description' => 'Info about oil', 'default' => 'Year', 'url' => 'http://www.graphbug.com/fakedata_oil_1995.csv', 'publish_date' => 'Sun Jan 01 00:00:00 -0500 1995', 'units' => 'Barrels'}]
    assert_equal expected, @tyra.lookup('Oil'), "Oil lookup failed"
  end
end
