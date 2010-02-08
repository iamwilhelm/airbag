module CrudAssertions
  
  def assert_show_page(page_name)
    assert_response :success
    assert_template page_name.to_s
  end  

  def assert_created(model_name)
    assert_difference("#{model_name.to_s.classify}.count") do
      yield
      assert assigns(model_name)
      assert_redirected_to datasource_path(:id => assigns(model_name))
    end
  end

  def assert_contains(model_name, attributes_hash)
    attributes_hash.each do |attr, value|
      assert_equal value, assigns(model_name).send(attr), "attr '#{attr}' has unexpected value"
    end
  end
  
end
