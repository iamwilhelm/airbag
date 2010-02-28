// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {
    // Highlights dimension columns in the datatable forms
    var datacolumnHighlighter = function() {
        $(".datacolumn input[type=checkbox]")
            .click(function(event) {
                var th = $(event.target).parents('.datacolumn');
                // we add one to account for extra checkbox column
                var index = th.parent().children().index(th) + 1;
                var table = th.parents('table')
                if (event.target.checked == true) {
                    th.addClass("included").removeClass("excluded");
                    table.find('tr').children("td:nth-child(" + index + ")")
                        .addClass("included").removeClass("excluded");
                } else {
                    th.addClass("excluded").removeClass("included");
                    table.find('tr').children("td:nth-child(" + index + ")")
                        .addClass("excluded").removeClass("included");
                }
            });
        $(".datarow input[type=checkbox]")
            .click(function(event) {
                if (event.target.checked == true) {
                    $(event.target).parents('.datarow').children('td, th')
                        .addClass("included").removeClass("excluded");
                } else {
                    $(event.target).parents('.datarow').children('td, th')
                        .addClass("excluded").removeClass("included");
                }
            });

    };
    datacolumnHighlighter();
    
    // the mechanics of UI for searching
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

