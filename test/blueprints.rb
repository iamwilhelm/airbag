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
        datasource.datatables.create(:xpath => "/table",
                                     :name => "s",
                                     :description => "a dummy datatable set",
                                     :default_dim => "s",
                                     :is_numeric => true,
                                     :units => "s",
                                     :datarows => [1,2,3,4])
      end
      return datasource.datatables
    end
  end

  module Datacolumn
    def self.build(datatable)
      datatable.datacolumns.create(:xpath => "td[1]",
                                   :position => "1")
    end
  end
end
