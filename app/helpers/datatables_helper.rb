module DatatablesHelper
  include NokogiriFormatters

  # for datatable row and column selection form
  def column_checked?(datatable, col_index)
    result = nil
    col_time = Timer::timer do
      result = datatable.new_record? || datatable.column_checked?(col_index)
    end
    puts "column_checked: #{col_time} secs" if col_time > 0.01
    return result
  end

  def row_checked?(datatable, row_index)
    result = nil
    row_time = Timer::timer do
      result = datatable.datarows.blank? || datatable.datarows.include?(row_index)
    end
    puts "row_checked: #{row_time} secs" if row_time > 0.01
    return result
  end
  
end
