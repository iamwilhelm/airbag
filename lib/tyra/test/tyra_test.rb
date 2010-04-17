require 'test/unit'
$LOAD_PATH << File.join(File.dirname(__FILE__), "..")
require 'tyra'

# note: some tests inspect expected and actual values to prevent
# repeating decimals from messing up comparison

class TyraTest < Test::Unit::TestCase
  def setup
    @tyra = Tyra.new(2)
  end

  # remove, then import, then import (with implicit remove)
  def test_import
    content_fname = File.join(File.dirname(__FILE__), "fixtures", "peanut_butter.csv")
    commands_fname = File.join(File.dirname(__FILE__), "bend_csv.yaml")
    expected = true
    actual = @tyra.delegate( "cmd" => "import_text", "content" => File.readlines(content_fname), "commands" => File.readlines(commands_fname) )
    assert_equal expected, actual, "fail"
  end

  def test_search_for_pb
    expected = [{"default"=>"State", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_pb.csv", "units"=>"Gallons", "dim_name"=>"Peanut Butter|Lubricant", "publish_date"=>"Thu Jan 01 00:00:00 -0500 2009", "description"=>"Uses of Peanut Butter", "dim_key"=>"peanut_butter|lubricant"},
                {"default"=>"State", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_pb.csv", "units"=>"Tons", "dim_name"=>"Peanut Butter|Hair Product", "publish_date"=>"Thu Jan 01 00:00:00 -0500 2009", "description"=>"Uses of Peanut Butter", "dim_key"=>"peanut_butter|hair_product"},
                {"default"=>"State", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_pb.csv", "units"=>"Gallons", "dim_name"=>"Peanut Butter|Donut", "publish_date"=>"Thu Jan 01 00:00:00 -0500 2009", "description"=>"Uses of Peanut Butter", "dim_key"=>"peanut_butter|donut"},
                {"default"=>"State", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_pb.csv", "units"=>"Tons", "dim_name"=>"Peanut Butter|Cerial", "publish_date"=>"Thu Jan 01 00:00:00 -0500 2009", "description"=>"Uses of Peanut Butter", "dim_key"=>"peanut_butter|cerial"},
                {"default"=>"State", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_pb.csv", "units"=>"Gallons", "dim_name"=>"Peanut Butter|Smores", "publish_date"=>"Thu Jan 01 00:00:00 -0500 2009", "description"=>"Uses of Peanut Butter", "dim_key"=>"peanut_butter|smores"},
                {"default"=>"State", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_pb.csv", "units"=>"Tons", "dim_name"=>"Peanut Butter|PBJ", "publish_date"=>"Thu Jan 01 00:00:00 -0500 2009", "description"=>"Uses of Peanut Butter", "dim_key"=>"peanut_butter|pbj"}]
    actual = @tyra.delegate( "cmd" => "search", "search_str" => "peanut_butter" )
    assert_equal expected, actual, "fail"
  end

  def test_search_for_banks_by_year
    expected = [{"default"=>"Year", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_banks.csv", "units"=>"Banks", "dim_name"=>"Banks by Year|Banks by Year", "publish_date"=>"Tue Jan 01 00:00:00 -0500 1980", "description"=>"Total Number of Banks by Year", "dim_key"=>"banks_by_year|banks_by_year"},
                {"default"=>"Year", "source_name"=>"fake", "url"=>"http://www.graphbug.com/fakedata_banks.csv", "units"=>"Banks", "dim_name"=>"Banks by Year and Type|Banks by Year and Type", "publish_date"=>"Tue Jan 01 00:00:00 -0500 1980", "description"=>"Total Number of Banks by Year and Type", "dim_key"=>"banks_by_year_and_type|banks_by_year_and_type"}]
    actual = @tyra.delegate( "cmd" => "search", "search_str" => "banks_by_year" )
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
    actual = @tyra.delegate( "cmd" => "search", "search_str" => "butter bank" )
    assert_equal expected, actual, "fail"
  end

  def test_get_meta_pb
    expected = {"name"=>"Peanut Butter","indvars"=>["State"],"license"=>"Public Domain","default"=>"State", "units"=> {"hair_product"=>"Tons",  "pbj"=>"Tons",  "smores"=>"Gallons",  "cerial"=>"Tons",  "donut"=>"Gallons",  "lubricant"=>"Gallons"}, "url"=>"http://www.graphbug.com/fakedata_pb.csv","description"=>"Uses of Peanut Butter","publish_date"=>"Thu Jan 01 00:00:00 -0500 2009","source"=>"fake","depvars"=>["Cerial", "Donut", "Hair Product", "Lubricant", "PBJ", "Smores"]}
    actual = @tyra.delegate( "cmd" => "get_metadata", "dimension" => "peanut_butter|donut" )
    assert_equal expected, actual, "fail"
  end

  def test_get_meta_banks
    expected = {"name"=>"Banks by Year","indvars"=>["State", "Year"],"license"=>"Public Domain","default"=>"Year","units"=>{"banks_by_year"=>"Banks"},"url"=>"http://www.graphbug.com/fakedata_banks.csv","description"=>"Total Number of Banks by Year","publish_date"=>"Tue Jan 01 00:00:00 -0500 1980","source"=>"fake","depvars"=>["Banks by Year"]}
    actual = @tyra.delegate( "cmd" => "get_metadata", "dimension" => "banks_by_year|banks_by_year" )
    assert_equal expected, actual, "fail"
  end

  def test_get_data_pb
    expected = {"data"=>[[203.614855, 204.706163, 201.778098, 203.633325, 203.798818, 203.812551, 204.869054, 202.677525, 203.491069, 204.093372, 202.697603, 203.883058, 203.517462, 204.964772, 203.815169, 203.79117, 203.154543, 202.183466, 203.818079, 204.141685, 203.063433, 202.761119, 203.638636, 200.446189, 202.750051, 200.322383, 200.317806, 202.750172, 204.075531, 203.117898, 204.887546, 204.882811, 203.620026, 200.299641, 204.143727, 203.985326, 202.294487, 201.548337, 204.704822, 203.128288, 200.84293, 203.039577, 204.593019, 202.403375, 202.005532, 201.850835, 200.215327, 204.070569, 200.502795, 200.030247, 201.135656]], "laxislabels"=>nil, "caxislabels"=>nil, "laxis"=>nil, "caxis"=>nil, "xaxislabels"=>[["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"]], "xaxis"=>"State", "dimension"=>"peanut_butter|donut"}
    actual = @tyra.delegate( "cmd" => "get_data", "dimension" => "peanut_butter|donut" )
    assert_equal expected.sort.inspect, actual.sort.inspect, "fail"
  end

  def test_get_data_banks
    expected = {"data"=>[[101.075927686275, 100.969706215686, 100.914484039216, 101.036711647059, 101.046361882353, 101.04291345098, 101.126171784314, 101.038772039216, 101.065189039216, 100.973824529412, 101.098855843137, 101.021243705882]], "laxislabels"=>nil, "caxislabels"=>nil, "laxis"=>nil, "caxis"=>nil, "xaxislabels"=>[["1980", "1981", "1982", "1983", "1984", "1985", "1986", "1987", "1988", "1989", "1990", "1991"]], "xaxis"=>"Year", "dimension"=>"banks_by_year|banks_by_year"}
    actual = @tyra.delegate( "cmd" => "get_data", "dimension" => "banks_by_year|banks_by_year" )
    assert_equal expected.sort.inspect, actual.sort.inspect, "fail"
  end

  def test_get_data_banks_by_state
    expected = {"data"=>[[101.004417666667, 100.9508775, 101.135032166667, 101.274857333333, 101.161742833333, 101.004444166667, 100.977466916667, 101.271830083333, 101.024793416667, 100.96025025, 101.282808, 100.977629583333, 100.780741083333, 101.072813916667, 100.974328583333, 101.038656333333, 100.905820916667, 100.788163416667, 100.969799166667, 100.905048166667, 101.273245666667, 101.281913916667, 100.640407, 101.1335175, 100.990519916667, 100.863977416667, 101.119221666667, 100.922736833333, 100.9156015, 101.219203166667, 100.904613416667, 101.108596083333, 100.937484583333, 100.982796333333, 100.94717125, 100.93671125, 101.267392083333, 100.77983875, 100.969273083333, 100.891248, 101.00025875, 101.083206416667, 101.374173416667, 100.93587975, 101.210482833333, 101.0164025, 101.469882, 101.14817625, 100.886583583333, 101.057846083333, 101.013305416667]], "laxislabels"=>nil, "caxislabels"=>nil, "laxis"=>nil, "caxis"=>nil, "xaxislabels"=>[["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"]], "xaxis"=>"State", "dimension"=>"banks_by_year|banks_by_year"}
    actual = @tyra.delegate( "cmd" => "get_data", "dimension" => "banks_by_year|banks_by_year", "xaxis" => "State" )
    assert_equal expected.sort.inspect, actual.sort.inspect, "fail"
  end

  def test_get_data_cars_count_model
    expected = {"data"=>[[2, 3, 4, 3, 1, 3, 3, 2]], "laxislabels"=>nil, "caxislabels"=>nil, "laxis"=>nil, "caxis"=>nil, "xaxislabels"=>[["Accord", "Camry", "Cherokee", "Civic", "Element", "Fusion", "Prius", "Sentra"]], "xaxis"=>"model", "dimension"=>"cars|odometer"}
    actual = @tyra.delegate( "cmd" => "get_data", "dimension" => "cars|odometer", "op" => "count", "xaxis" => "model" )
    assert_equal expected.sort.inspect, actual.sort.inspect, "fail"
  end

  def test_get_data_cars_avg_price_by_make
    expected = {"data"=>[[3400.0, 4183.33333333333, 4975.0, 1000.0, 3100.0]], "laxislabels"=>nil, "caxislabels"=>nil, "laxis"=>nil, "caxis"=>nil, "xaxislabels"=>[["Ford", "Honda", "Jeep", "Nissan", "Toyota"]], "xaxis"=>"make", "dimension"=>"cars|price"}
    actual = @tyra.delegate( "cmd" => "get_data", "dimension" => "cars|price", "op" => "mean", "xaxis" => "make" )
    assert_equal expected.sort.inspect, actual.sort.inspect, "fail"
  end

  def test_get_data_cars_avg_odometer_by_model
    expected = {"data"=>[[112570.0, 45840.0, 99830.0, 83375.3333333333, 60030.0, 34095.6666666667, 61371.0, 130123.0]], "laxislabels"=>nil, "caxislabels"=>nil, "laxis"=>nil, "caxis"=>nil, "xaxislabels"=>[["Accord", "Camry", "Cherokee", "Civic", "Element", "Fusion", "Prius", "Sentra"]], "xaxis"=>"model", "dimension"=>"cars|odometer"}
    actual = @tyra.delegate( "cmd" => "get_data", "dimension" => "cars|odometer", "op" => "mean", "xaxis" => "model" )
    assert_equal expected.sort.inspect, actual.sort.inspect, "fail"
  end

  def test_get_data_banks_by_year_state
    expected = {"data"=>[[100.078951, 100.667766, 101.504442, 101.761123, 101.735232, 101.025333, 101.475903, 100.97986, 100.624463, 101.059537, 101.072447, 101.896543, 100.150109, 101.135286, 101.628124, 101.763568, 100.943711, 100.751338, 100.61732, 101.271983, 100.632116, 101.222725, 100.266961, 100.844742, 100.402049, 101.494431, 101.390065, 100.878607, 101.618209, 101.787917, 100.490486, 101.813711, 100.470803, 100.107587, 101.183973, 101.576278, 101.617129, 100.579394, 101.970604, 101.368984, 100.964196, 100.699389, 101.614277, 101.062114, 101.453362, 100.464101, 101.490804, 101.20016, 100.68216, 100.230451, 101.151488], [100.73246, 100.465369, 101.012927, 101.160863, 101.328273, 100.161925, 100.384866, 101.410277, 101.904378, 100.971085, 101.284783, 100.289487, 100.395345, 100.98566, 100.334951, 101.998744, 100.588439, 101.266196, 100.004649, 100.445614, 101.898684, 101.0456, 100.288904, 101.910947, 100.376132, 100.725537, 101.310126, 100.068079, 100.771547, 101.92892, 101.662303, 100.067578, 100.355022, 100.563179, 100.380765, 101.116064, 101.460091, 101.137537, 101.245014, 100.78583, 101.008952, 100.908247, 101.773185, 101.709328, 101.616009, 100.2493, 101.872221, 100.685754, 100.31342, 101.195031, 101.89942], [101.083044, 101.325459, 101.136588, 101.2712, 100.114649, 101.461424, 101.891752, 101.574183, 100.742079, 100.049322, 100.501877, 101.85542, 100.068989, 101.74685, 101.170626, 100.536845, 100.847612, 101.236165, 101.11578, 100.840351, 100.654041, 101.47989, 100.090579, 100.754178, 100.962515, 101.39697, 100.682906, 100.123646, 100.188302, 100.477809, 100.0736, 100.83535, 100.093857, 101.621395, 101.629736, 100.266637, 101.78678, 100.044969, 100.626494, 100.326667, 100.461676, 101.605246, 101.316694, 100.199971, 100.973965, 101.229663, 101.154808, 101.528498, 100.726089, 100.946282, 101.809258], [101.648148, 100.582933, 101.403823, 101.673302, 100.930366, 100.962331, 100.043724, 101.597983, 100.181548, 100.843767, 101.761473, 100.099626, 101.369006, 101.010879, 100.736817, 100.232359, 101.052613, 101.325586, 101.530323, 101.587567, 101.73296, 101.805987, 100.609827, 100.87041, 100.688891, 100.081009, 101.046399, 101.089473, 100.667579, 101.845379, 101.014354, 101.981039, 100.095244, 100.715827, 100.358943, 101.003123, 100.616018, 100.245477, 101.329292, 101.290887, 101.639984, 100.347958, 101.654856, 100.888715, 101.665058, 100.637404, 101.903798, 101.516826, 101.160776, 101.198203, 100.596424], [101.789047, 100.276873, 101.533921, 101.429238, 100.714704, 100.165711, 101.805963, 101.416596, 101.465313, 101.600624, 100.512107, 100.296206, 100.363924, 100.136875, 100.7319, 101.901215, 101.644491, 100.424321, 100.855737, 100.718292, 100.424383, 100.704475, 100.982524, 101.328519, 101.321006, 100.251316, 101.962962, 101.657012, 101.962389, 100.920456, 100.970413, 100.995317, 100.813679, 101.353274, 101.618653, 100.790291, 100.099432, 101.51698, 101.646419, 101.335791, 101.442776, 101.386959, 101.536229, 100.753731, 100.343235, 100.42244, 100.718388, 100.934509, 100.848651, 101.966116, 100.573073], [100.386588, 101.910555, 100.111373, 101.08036, 100.039744, 101.760612, 100.896985, 101.943305, 101.677684, 101.608804, 101.908656, 100.749373, 101.516386, 101.894869, 101.175914, 100.325352, 100.758463, 100.739388, 100.462582, 100.659529, 100.308311, 100.632805, 100.104347, 101.187736, 100.866271, 100.007817, 101.736433, 100.544708, 100.434621, 101.137713, 100.130865, 101.999836, 101.117193, 101.290562, 100.971361, 101.538674, 101.480091, 101.184785, 101.139284, 100.241336, 101.25394, 101.948167, 101.956942, 101.728444, 100.788131, 100.764556, 101.875763, 100.365061, 101.330954, 100.75061, 100.764747], [100.51054, 101.525773, 101.404183, 100.948454, 101.948155, 100.857115, 100.304257, 101.854338, 101.239965, 100.701697, 101.777492, 101.365936, 101.797306, 101.357702, 101.408344, 101.144414, 101.336057, 100.44253, 101.655997, 101.059188, 101.900932, 100.927734, 101.514179, 100.704662, 101.035686, 100.800231, 101.402651, 101.944143, 100.267993, 101.314195, 100.350698, 101.751505, 100.050522, 100.819379, 100.642484, 101.172655, 100.960557, 101.027173, 100.234929, 101.440745, 101.020476, 100.082868, 101.297783, 101.237352, 100.853355, 101.02597, 101.835408, 101.456912, 100.654547, 101.717189, 101.350405], [101.242758, 101.453989, 101.418245, 101.736373, 101.485987, 101.760121, 100.966326, 101.286609, 100.118525, 101.472075, 101.156696, 100.10659, 100.697535, 100.257068, 101.489473, 101.560783, 100.660433, 100.760124, 101.75956, 100.838023, 101.090016, 101.485152, 100.101523, 101.790986, 100.584332, 101.277558, 100.616168, 101.106559, 100.876795, 100.898791, 101.661459, 100.983519, 101.113505, 101.530097, 101.376738, 100.220424, 101.462383, 101.070584, 100.240106, 100.979641, 100.227359, 100.748403, 101.309945, 100.955555, 100.996107, 101.857169, 101.803445, 100.985354, 100.153782, 100.233413, 101.013213], [101.220554, 101.537518, 100.997693, 101.96308, 101.562541, 101.529957, 101.882303, 100.400148, 100.197566, 100.425673, 101.37471, 101.610263, 100.423608, 101.920679, 100.416056, 101.361405, 100.571405, 101.143367, 100.446646, 100.504731, 101.874547, 101.58924, 100.714644, 100.475553, 101.997655, 101.332661, 100.041012, 100.745912, 100.636582, 100.813095, 101.339261, 100.655785, 101.673417, 101.237578, 101.050774, 100.195053, 101.774881, 101.475494, 100.054817, 100.340602, 100.283861, 101.634478, 101.268229, 100.537568, 101.394241, 101.726883, 100.927442, 101.027734, 101.896802, 100.746681, 101.372256], [101.134526, 100.124494, 101.593193, 100.739552, 101.374886, 100.449398, 100.068955, 100.951613, 101.751503, 101.89297, 101.232084, 101.709696, 100.081663, 100.727986, 100.317903, 101.268432, 101.354008, 100.08033, 101.207962, 100.508634, 101.810269, 101.941582, 100.610537, 100.66247, 100.573296, 101.357446, 101.051937, 101.789376, 101.297804, 100.880875, 100.177554, 100.007071, 101.906123, 100.160587, 100.6157, 100.401021, 101.381079, 100.941518, 100.872232, 101.168182, 101.830491, 101.074773, 100.187874, 100.150518, 100.976335, 101.779478, 101.634559, 101.686303, 100.857749, 100.96376, 100.346764], [100.250221, 100.852533, 100.135736, 100.173096, 101.968848, 101.227858, 101.068898, 100.608437, 101.313497, 100.429135, 101.52818, 101.40715, 101.976233, 100.710098, 101.871092, 100.037897, 100.738517, 100.651643, 101.471204, 101.307459, 101.281056, 100.910084, 101.114516, 101.876024, 101.744335, 100.798731, 101.568792, 101.08222, 101.752113, 101.219173, 101.819348, 101.981658, 101.88756, 101.367983, 100.431958, 101.039562, 101.842044, 100.090602, 101.57704, 100.552454, 100.151305, 101.203981, 101.527425, 100.217565, 101.583774, 100.282891, 100.78386, 101.487115, 101.47872, 101.527046, 100.132981], [101.976175, 100.687268, 101.368262, 101.361647, 100.737529, 100.691545, 100.939671, 101.238612, 101.081, 100.468314, 101.283191, 100.345265, 100.528789, 100.989815, 100.410743, 100.332862, 100.374102, 100.636973, 100.50983, 101.119207, 101.671633, 101.637693, 101.286343, 101.195983, 101.334071, 100.844022, 100.621209, 100.043107, 100.513284, 101.406115, 101.16502, 100.230784, 101.67289, 101.026108, 101.10497, 101.920753, 100.72822, 100.043552, 100.695046, 100.863857, 101.718089, 101.358008, 101.046642, 101.789696, 101.882222, 101.756975, 101.638088, 100.903889, 100.535353, 101.219371, 101.149636]], "laxislabels"=>nil, "caxislabels"=>["1980", "1981", "1982", "1983", "1984", "1985", "1986", "1987", "1988", "1989", "1990", "1991"], "laxis"=>nil, "caxis"=>"Year", "xaxislabels"=>[["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"], ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"], ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"], ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"], ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"], ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"], ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"], ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"], ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"], ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"], ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"], ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"]], "xaxis"=>"State", "dimension"=>"banks_by_year|banks_by_year"}
    actual = @tyra.delegate( "cmd" => "get_data", "dimension" => "banks_by_year|banks_by_year", "op" => "mean", "xaxis" => "State", "caxis" => "Year" )
    assert_equal expected.sort.inspect, actual.sort.inspect, "fail"
  end

  def test_get_data_banks_by_year_some_states
    expected = {"data"=>[[101.813711, 101.183973], [100.067578, 100.380765], [100.83535, 101.629736], [101.981039, 100.358943], [100.995317, 101.618653], [101.999836, 100.971361], [101.751505, 100.642484], [100.983519, 101.376738], [100.655785, 101.050774], [100.007071, 100.6157], [101.981658, 100.431958], [100.230784, 101.10497]], "laxislabels"=>nil, "caxislabels"=>["1980", "1981", "1982", "1983", "1984", "1985", "1986", "1987", "1988", "1989", "1990", "1991"], "laxis"=>nil, "caxis"=>"Year", "xaxislabels"=>[["NJ", "NY"], ["NJ", "NY"], ["NJ", "NY"], ["NJ", "NY"], ["NJ", "NY"], ["NJ", "NY"], ["NJ", "NY"], ["NJ", "NY"], ["NJ", "NY"], ["NJ", "NY"], ["NJ", "NY"], ["NJ", "NY"]], "xaxis"=>"State", "dimension"=>"banks_by_year|banks_by_year"}
    actual = @tyra.delegate( "cmd" => "get_data", "dimension" => "banks_by_year|banks_by_year", "op" => "mean", "xaxis" => "State", "desired_xlabels" => ["NY", "NJ"], "caxis" => "Year" )
    assert_equal expected.sort.inspect, actual.sort.inspect, "fail"
  end

  def test_get_data_banks_by_some_years_some_states
    expected = {"data"=>[[101.981658, 100.431958], [100.230784, 101.10497]], "laxislabels"=>nil, "caxislabels"=>["1990", "1991"], "laxis"=>nil, "caxis"=>"Year", "xaxislabels"=>[["NJ", "NY"], ["NJ", "NY"]], "xaxis"=>"State", "dimension"=>"banks_by_year|banks_by_year"}
    actual = @tyra.delegate( "cmd" => "get_data", "dimension" => "banks_by_year|banks_by_year", "op" => "mean", "xaxis" => "State", "desired_xlabels" => ["NY", "NJ"], "caxis" => "Year", "desired_clabels" => ["1990", "1991"] )
    assert_equal expected.sort.inspect, actual.sort.inspect, "fail"
  end

  def test_get_data_cars_avg_price_and_color_by_make
    expected = {"data"=>[[3400.0, 4183.33333333333, 4975.0, 1000.0, 3100.0]], "laxislabels"=>[[3, 6, 4, 2, 6]], "caxislabels"=>nil, "laxis"=>"make", "caxis"=>nil, "xaxislabels"=>[["Ford", "Honda", "Jeep", "Nissan", "Toyota"]], "xaxis"=>"make", "dimension"=>"cars|price"}
    actual = @tyra.delegate( "cmd" => "get_data", "dimension" => "cars|price", "op" => "mean", "xaxis" => "make", "laxis" => "make", "lop" => "count" )
    assert_equal expected.sort.inspect, actual.sort.inspect, "fail"
  end

end


if __FILE__ == $0
  require 'test/unit/ui/console/testrunner'
  Test::Unit::UI::Console::TestRunner.run(TyraTest)
end
