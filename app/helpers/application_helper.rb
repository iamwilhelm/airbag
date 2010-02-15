# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # creates a link for a tab to deselect all other tabs and tab
  # sections and show section and highlighted tabs
  # The sections should have a class of .tabsection
  def link_to_tab(name, tab_name, section_name)
    clear_tabs_func = ["$('ul.menu.tabbed li').removeClass('selected');",
                       "$('.tabsection').fadeOut();"].join
    select_tab_func = ["$('##{tab_name}').addClass('selected');",
                       "$('##{section_name}').fadeIn();"].join
    link_to_function name, clear_tabs_func + select_tab_func
  end
end
