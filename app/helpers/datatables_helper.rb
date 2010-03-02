module DatatablesHelper
  include NokogiriFormatters

  # for datatable row and column selection form
  def column_checked?(datatable, header_path)
    datatable.new_record? or (datatable.column_checked?(header_path))
  end

  def row_checked?(datatable, row_index)
    datatable.datarows.blank? or datatable.datarows.include?(row_index)
  end
  
end
