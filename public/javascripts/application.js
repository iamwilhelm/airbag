// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {
    // Highlights dimension columns in the datatable forms
    var datacolumnHighlighter = function() {
        $("tr.datacolumn input[type=checkbox]")
            .click(function(event) {
                $(event.target).parents('tr.datacolumn')
                    .toggleClass("included").toggleClass("excluded");
            });
    };
    datacolumnHighlighter();
    
    var searchResultMechanics = function() {
        $(".query_control form").submit(function() {
            $(".query_results").slideDown("slow");
        });

        $("a.draw_dimension").live("click", function() {
            $(".query_results").slideUp("slow");
        });
    };
    searchResultMechanics();

});

