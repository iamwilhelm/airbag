require 'test/unit'
require '../tyra'

# note: some tests inspect expected and actual values to prevent
# repeating decimals from messing up comparison

class TyraTest < Test::Unit::TestCase
  def setup
    @tyra = Tyra.new(2)
  end

  # remove, then import, then import (with implicit remove)
  def test_remove_import_both
    expected = true
    actual = @tyra.process( "cmd" => "remove", "dataset" => "peanut_butter" )
    assert_equal expected, actual, "fail"

    actual = @tyra.process( "cmd" => "import_csv", "fname" => "fixtures/peanut_butter.csv" )
    assert_equal expected, actual, "fail"

    actual = @tyra.process( "cmd" => "import_csv", "fname" => "fixtures/peanut_butter.csv" )
    assert_equal expected, actual, "fail"
  end

  def test_search_for_pb
    expected = [{"default"=>"State", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_pb.csv", "units"=>"Gallons", "dim_name"=>"Peanut Butter|Lubricant", "publish_date"=>"Thu Jan 01 00:00:00 -0500 2009", "description"=>"Uses of Peanut Butter", "dim_key"=>"peanut_butter|lubricant"},
                {"default"=>"State", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_pb.csv", "units"=>"Tons", "dim_name"=>"Peanut Butter|Hair Product", "publish_date"=>"Thu Jan 01 00:00:00 -0500 2009", "description"=>"Uses of Peanut Butter", "dim_key"=>"peanut_butter|hair_product"},
                {"default"=>"State", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_pb.csv", "units"=>"Gallons", "dim_name"=>"Peanut Butter|Donut", "publish_date"=>"Thu Jan 01 00:00:00 -0500 2009", "description"=>"Uses of Peanut Butter", "dim_key"=>"peanut_butter|donut"},
                {"default"=>"State", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_pb.csv", "units"=>"Tons", "dim_name"=>"Peanut Butter|Cerial", "publish_date"=>"Thu Jan 01 00:00:00 -0500 2009", "description"=>"Uses of Peanut Butter", "dim_key"=>"peanut_butter|cerial"},
                {"default"=>"State", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_pb.csv", "units"=>"Gallons", "dim_name"=>"Peanut Butter|Smores", "publish_date"=>"Thu Jan 01 00:00:00 -0500 2009", "description"=>"Uses of Peanut Butter", "dim_key"=>"peanut_butter|smores"},
                {"default"=>"State", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_pb.csv", "units"=>"Tons", "dim_name"=>"Peanut Butter|PBJ", "publish_date"=>"Thu Jan 01 00:00:00 -0500 2009", "description"=>"Uses of Peanut Butter", "dim_key"=>"peanut_butter|pbj"}]
    actual = @tyra.process( "cmd" => "search", "search_str" => "peanut_butter" )
    assert_equal expected, actual, "fail"
  end

  def test_search_for_banks_by_year
    expected = [{"default"=>"Year", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_banks.csv", "units"=>"Banks", "dim_name"=>"Banks by Year|Banks by Year", "publish_date"=>"Tue Jan 01 00:00:00 -0500 1980", "description"=>"Total Number of Banks by Year", "dim_key"=>"banks_by_year|banks_by_year"},
                {"default"=>"Year", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_banks.csv", "units"=>"Banks", "dim_name"=>"Banks by Year and Type|Banks by Year and Type", "publish_date"=>"Tue Jan 01 00:00:00 -0500 1980", "description"=>"Total Number of Banks by Year and Type", "dim_key"=>"banks_by_year_and_type|banks_by_year_and_type"}]
    actual = @tyra.process( "cmd" => "search", "search_str" => "banks_by_year" )
    assert_equal expected, actual, "fail"
  end

  def test_search_for_butter_bank
    expected = [{"default"=>"State", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_pb.csv", "units"=>"Gallons", "dim_name"=>"Peanut Butter|Lubricant", "publish_date"=>"Thu Jan 01 00:00:00 -0500 2009", "description"=>"Uses of Peanut Butter", "dim_key"=>"peanut_butter|lubricant"},
                {"default"=>"State", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_pb.csv", "units"=>"Tons", "dim_name"=>"Peanut Butter|Hair Product", "publish_date"=>"Thu Jan 01 00:00:00 -0500 2009", "description"=>"Uses of Peanut Butter", "dim_key"=>"peanut_butter|hair_product"},
                {"default"=>"State", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_pb.csv", "units"=>"Gallons", "dim_name"=>"Peanut Butter|Donut", "publish_date"=>"Thu Jan 01 00:00:00 -0500 2009", "description"=>"Uses of Peanut Butter", "dim_key"=>"peanut_butter|donut"},
                {"default"=>"State", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_pb.csv", "units"=>"Tons", "dim_name"=>"Peanut Butter|Cerial", "publish_date"=>"Thu Jan 01 00:00:00 -0500 2009", "description"=>"Uses of Peanut Butter", "dim_key"=>"peanut_butter|cerial"},
                {"default"=>"State", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_pb.csv", "units"=>"Gallons", "dim_name"=>"Peanut Butter|Smores", "publish_date"=>"Thu Jan 01 00:00:00 -0500 2009", "description"=>"Uses of Peanut Butter", "dim_key"=>"peanut_butter|smores"},
                {"default"=>"State", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_pb.csv", "units"=>"Tons", "dim_name"=>"Peanut Butter|PBJ", "publish_date"=>"Thu Jan 01 00:00:00 -0500 2009", "description"=>"Uses of Peanut Butter", "dim_key"=>"peanut_butter|pbj"},
                {"default"=>"Year", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_banks.csv", "units"=>"Banks", "dim_name"=>"Banks by Year|Banks by Year", "publish_date"=>"Tue Jan 01 00:00:00 -0500 1980", "description"=>"Total Number of Banks by Year", "dim_key"=>"banks_by_year|banks_by_year"},
                {"default"=>"Year", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_banks.csv", "units"=>"Banks", "dim_name"=>"Banks by Year and Type|Banks by Year and Type", "publish_date"=>"Tue Jan 01 00:00:00 -0500 1980", "description"=>"Total Number of Banks by Year and Type", "dim_key"=>"banks_by_year_and_type|banks_by_year_and_type"}]
    actual = @tyra.process( "cmd" => "search", "search_str" => "butter bank" )
    assert_equal expected, actual, "fail"
  end

  def test_get_meta_pb
    expected = {"name"=>"Peanut Butter","indvars"=>["State"],"license"=>"Public Domain","default"=>"State", "units"=> {"hair_product"=>"Tons",  "pbj"=>"Tons",  "smores"=>"Gallons",  "cerial"=>"Tons",  "donut"=>"Gallons",  "lubricant"=>"Gallons"}, "url"=>"http://www.graphbug.com/fakedata_pb.csv","description"=>"Uses of Peanut Butter","publish_date"=>"Thu Jan 01 00:00:00 -0500 2009","source"=>"fake","depvars"=>["Cerial", "Donut", "Hair Product", "Lubricant", "PBJ", "Smores"]}
    actual = @tyra.process( "cmd" => "get_metadata", "dimension" => "peanut_butter|donut" )
    assert_equal expected, actual, "fail"
  end

  def test_get_meta_banks
    expected = {"name"=>"Banks by Year","indvars"=>["State", "Year"],"license"=>"Public Domain","default"=>"Year","units"=>{"banks_by_year"=>"Banks"},"url"=>"http://www.graphbug.com/fakedata_banks.csv","description"=>"Total Number of Banks by Year","publish_date"=>"Tue Jan 01 00:00:00 -0500 1980","source"=>"fake","depvars"=>["Banks by Year"]}
    actual = @tyra.process( "cmd" => "get_metadata", "dimension" => "banks_by_year|banks_by_year" )
    assert_equal expected, actual, "fail"
  end

  def test_get_data_pb
    expected = {"data"=> [203.614855, 204.706163, 201.778098, 203.633325, 203.798818, 203.812551, 204.869054, 202.677525, 203.491069, 204.093372, 202.697603, 203.883058, 203.517462, 204.964772, 203.815169, 203.79117, 203.154543, 202.183466, 203.818079, 204.141685, 203.063433, 202.761119, 203.638636, 200.446189, 202.750051, 200.322383, 200.317806, 202.750172, 204.075531, 203.117898, 204.887546, 204.882811, 203.620026, 200.299641, 204.143727, 203.985326, 202.294487, 201.548337, 204.704822, 203.128288, 200.84293, 203.039577, 204.593019, 202.403375, 202.005532, 201.850835, 200.215327, 204.070569, 200.502795, 200.030247, 201.135656], "xaxislabels"=> ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"], "xaxis"=>"State", "dimension"=>"peanut_butter|donut"}
    actual = @tyra.process( "cmd" => "get_data", "dimension" => "peanut_butter|donut" )
    assert_equal expected, actual, "fail"
  end

  def test_get_data_banks
    expected = {"data"=>[101.075927686275, 100.969706215686, 100.914484039216, 101.036711647059, 101.046361882353, 101.04291345098, 101.126171784314, 101.038772039216, 101.065189039216, 100.973824529412, 101.098855843137, 101.021243705882], "xaxislabels"=>["1980", "1981", "1982", "1983", "1984", "1985", "1986", "1987", "1988", "1989", "1990", "1991"], "xaxis"=>"Year", "dimension"=>"banks_by_year|banks_by_year"}
    actual = @tyra.process( "cmd" => "get_data", "dimension" => "banks_by_year|banks_by_year" )
    assert_equal expected.inspect, actual.inspect, "fail"
  end

  def test_get_data_banks_by_state
    expected = {"data"=>[101.004417666667, 100.9508775, 101.135032166667, 101.274857333333, 101.161742833333, 101.004444166667, 100.977466916667, 101.271830083333, 101.024793416667, 100.96025025, 101.282808, 100.977629583333, 100.780741083333, 101.072813916667, 100.974328583333, 101.038656333333, 100.905820916667, 100.788163416667, 100.969799166667, 100.905048166667, 101.273245666667, 101.281913916667, 100.640407, 101.1335175, 100.990519916667, 100.863977416667, 101.119221666667, 100.922736833333, 100.9156015, 101.219203166667, 100.904613416667, 101.108596083333, 100.937484583333, 100.982796333333, 100.94717125, 100.93671125, 101.267392083333, 100.77983875, 100.969273083333, 100.891248, 101.00025875, 101.083206416667, 101.374173416667, 100.93587975, 101.210482833333, 101.0164025, 101.469882, 101.14817625, 100.886583583333, 101.057846083333, 101.013305416667], "xaxislabels"=>["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"], "xaxis"=>"State", "dimension"=>"banks_by_year|banks_by_year"}
    actual = @tyra.process( "cmd" => "get_data", "dimension" => "banks_by_year|banks_by_year", "xaxis" => "State" )
    assert_equal expected.inspect, actual.inspect, "fail"
  end

  def test_get_data_cars_count_model
    expected = {"data"=>[2, 3, 4, 3, 1, 3, 3, 2], "xaxislabels"=>["Accord", "Camry", "Cherokee", "Civic", "Element", "Fusion", "Prius", "Sentra"], "xaxis"=>"model", "dimension"=>"cars|odometer"}
    actual = @tyra.process( "cmd" => "get_data", "dimension" => "cars|odometer", "op" => "count", "xaxis" => "model" )
    assert_equal expected, actual, "fail"
  end

  def test_get_data_cars_avg_price_by_make
    expected = {"data"=>[3400.0, 4183.33333333333, 4975.0, 1000.0, 3100.0], "xaxislabels"=>["Ford", "Honda", "Jeep", "Nissan", "Toyota"], "xaxis"=>"make", "dimension"=>"cars|price"}
    actual = @tyra.process( "cmd" => "get_data", "dimension" => "cars|price", "op" => "mean", "xaxis" => "make" )
    assert_equal expected.inspect, actual.inspect, "fail"
  end

  def test_get_data_cars_avg_odometer_by_model
    expected = {"data"=>[112570.0, 45840.0, 99830.0, 83375.3333333333, 60030.0, 34095.6666666667, 61371.0, 130123.0], "xaxislabels"=>["Accord", "Camry", "Cherokee", "Civic", "Element", "Fusion", "Prius", "Sentra"], "xaxis"=>"model", "dimension"=>"cars|odometer"}
    actual = @tyra.process( "cmd" => "get_data", "dimension" => "cars|odometer", "op" => "mean", "xaxis" => "model" )
    assert_equal expected.inspect, actual.inspect, "fail"
  end
end


if __FILE__ == $0
  require 'test/unit/ui/console/testrunner'
  Test::Unit::UI::Console::TestRunner.run(TyraTest)
end
