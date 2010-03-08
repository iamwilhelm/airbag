class Datatable < ActiveRecord::Base
  belongs_to :datasource
  has_many :datacolumns, :order => "position asc", :dependent => :destroy

  # NOTE: default_dimension is not an association because we only need the
  # name for the importer.  When there's more operations needed, we
  # can change it.

  validates_presence_of :xpath
  
  class << self
    ########## Nokogiri based table extraction helper methods ##########

    # beware of those using th for row headers
    def headers_of(table)
      headers = table.css('thead tr:first th', 'thead tr:first td')
      return headers unless headers.empty?
      
      headers = table.css('tbody tr:first th', 'tbody tr:first td')
      return headers unless headers.empty?

      headers = table.css('tr:first th', 'tr:first td')
      return headers unless headers.empty?
      
      raise Exception.new("Cannot find headers in table")
    end

    def columns_of(table, header)
      # extract header column number from xpath
      col_num = header.path[/\[(\d+)\]$/, 1]

      columns = extract_column(table, col_num, "tr")
      return columns unless columns.empty?
      
      columns = extract_column(table, col_num, "tbody/tr")
      return columns
    end

    def rows_of(table)
      table.css('tr')
    end

    def cells_of(row)
      row.css('td')
    end
    
    private

    # extract column of a number and its matching row xpath
    def extract_column(table, col_num, row_xpath)
      col_num = col_num.to_i
      row_xpath ||= "tr"
      if table.xpath("#{row_xpath}[position() > 1]/th").empty?
        table.xpath("#{row_xpath}/td[#{col_num}]")
      else
        if col_num == 1
          table.xpath("#{row_xpath}/th[1]")
        else
          table.xpath("#{row_xpath}/td[#{col_num - 1}]")
        end
      end
    end
    
  end

  # for mass assignment of datacolumns from the datatable form
  def datacolumn_attributes=(attributes)
    attributes.select do |position, datacolumn_attrs|
      # we get all columns with an "included" key, meaning the
      # column was selected.  We filter because there are hidden fields that
      # get sent regardless of whether the column is selected.
      datacolumn_attrs.has_key?("included")
    end.each do |position, datacolumn_attrs|
      datacolumn_attrs.delete("included")
      unless datacolumn_attrs.has_key?("position")
        datacolumn_attrs.merge!({ :position => position })
      end
      self.datacolumns.build(datacolumn_attrs)
    end
  end

  # import the datatable into tyra
  def import
    update_attribute(:published_at, Time.now)
    @tyra = Tyra.new(0)
    @tyra.import(metadata, data)
  end

  # package this datatable's metadata together in a hash
  def metadata
    { :name => name,
      :description => description,
      :license => license,
      :source => datasource.title,
      :url => datasource.url,
      :publish_date => published_at,
      :default => default_dim,
      :indvars => datacolumns.independent.map(&:name) }
  end

  # package this datatable's data
  def data
    datacolumns.reduce({}) do |t, col|
      t[col.name] = col.data; t
    end
  end
  
  # convert datarows to string upon assignment
  #--
  # NOTE: decided to store datarows as string, because there currently
  # is no need to access the data by records (rows).  Once there's a
  # need to do so, then we'll make datarows into an AR model
  def datarows=(array)
    self[:datarows] = array.join(",")
  end

  # convert datarows string to array when read
  def datarows
    return [] if self[:datarows].blank?
    self[:datarows].split(",").map(&:to_i)
  end

  # returns the Nokogiri node for the data
  def node
    datasource.document.xpath(xpath).first
  end

  def rows
    datacolumns.map { |dc| dc.data }
  end
  
  def column_checked?(index)
    datacolumns.map(&:position).include?(index)
  end
  
end
