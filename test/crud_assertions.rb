module CrudAssertions
  
  def assert_show_page(page_name)
    assert_response :success
    assert_template page_name.to_s
  end  

  def assert_created(model_name, &block)
    assert_assigns_proc(1).call(model_name, block)
  end

  def assert_updated(model_name, &block)
    assert_assigns_proc(0).call(model_name, block)
  end

  def assert_destroyed(model_name, &block)
    assert_assigns_proc(-1, datasources_path).call(model_name, block)
  end
  
  def assert_contains(model_name, attributes_hash)
    attributes_hash.each do |attr, value|
      assert_equal value, assigns(model_name).send(attr), "attr '#{attr}' has unexpected value"
    end
  end

  private
  
  def assert_assigns_proc(number, redirect_path = nil)
    proc do |model_name, block|
      assert_difference("#{model_name.to_s.classify}.count", number) do
        block.call
        redirect_path ||= datasource_path(assigns(model_name))
        assert assigns(model_name)
        assert_redirected_to redirect_path
      end
    end
  end

end
