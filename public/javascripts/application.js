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
            $(".query_results").slideDown("fast");
        });

        $(".query_control input.search").focus(function() {
            if ($(this).val() != "") {
                $(".query_results").slideDown("fast");
            }
        });

        $(".query_control a#close_query").click(function() {
            $(".query_results").slideUp("fast");
            return false;
        });

        // $(".query_control input.search").blur(function() {
        //     $(".query_results").slideUp("fast")
        // });

        // // FIXME live doesn't catch clicks in FF or Safari
        // $("a.draw_dimension").live("click", function() {
        //     $(".query_results").slideUp("fast");
        // });
    };
    searchResultMechanics();

});

