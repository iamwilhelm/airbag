# poor man's blueprints.  Replace with actual blueprints later
module Blueprints
  module Datasource
    def self.build
      TextHtml.create(:url => "http://census.gov", :title => "Census Population")
    end
  end

  module Datatable
    def self.build(datasource, number = 2)
      number.times do
        datasource.datatables.create(:table_heading => "s",
                                     :col_heading => "s",
                                     :col_labels_one => "s",
                                     :col_labels_two => "s",
                                     :col_labels_content => "s",
                                     :row_heading => "s",
                                     :row_labels_one => "s",
                                     :row_labels_two => "s",
                                     :row_labels_content => "s",
                                     :data_one => "s",
                                     :data_two => "s",
                                     :default_dim => "s",
                                     :is_numeric => true,
                                     :units => "s")
      end
      return datasource.datatables
    end
  end
end
