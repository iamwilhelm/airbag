# poor man's blueprints.  Replace with actual blueprints later
module Blueprints
  module Datasource
    def self.scaffold(optional_attrs = {})
      required = {
        :url => "http://census.gov", :title => "Census Population"
      }
      required.merge(optional_attrs)
    end
    
    def self.build(optional_attrs = {})
      TextHtml.create(scaffold(optional_attrs))
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
    def self.scaffold(optional_attrs = {})
      required = {
        :xpath => "td[1]",
        :position => "1"
      }
      required.merge(optional_attrs)
    end
    
    def self.build(datatable, optional_attrs = {})
      datatable.datacolumns.create(scaffold(optional_attrs))
    end
  end
end
