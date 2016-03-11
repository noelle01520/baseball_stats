$(function(){

    /**
     * @name players_table
     * @desc Datatable for sorting/paging stats
     */
    var players_table = $('#players').DataTable({
        sPaginationType: "full_numbers",
        bJQueryUI: true,
        stateSave: true,
        bFilter: false,
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#players').data('source'),
        dom: '<"toolbar">frtip',
        fnServerParams: function (data) {
            data.push({"name": "sSearch", "value": $('#selected_year').val()});
        },
        order: [5, 'desc'],
        columnDefs: [
            { type: "num", targets: [5, 6, 7, 8, 9, 10] }
        ]
    });

    populateToolbar(selected_year, select_years);
    update_table();

    ////////////////////////////////////////////////////////////////////////

    /**
     * @name populateToolbar
     * @desc add the years select to the datatable toolbar and attach change handler
     * @param selected_year - 4 digit year to display stats for
     * @param years - Array of integers representing 4 digit possible years the user can select from
     */
    function populateToolbar(selected_year, years)
    {
        var toolbar = $('div.toolbar');
        var years_select = $('<select />').attr('id', 'selected_year');
        years.split(',').forEach(function(year){
            years_select.append($('<option />').text(year).val(year));
        });
        toolbar.append(years_select);
        years_select.val(selected_year)
            .on( 'change', function () {
                $('.header_year').text($(this).val())
                update_table();
            });
    }

    /**
     * @name update_table
     * @desc Updates players_table
     */
    function update_table(){
        players_table.draw();
    }
});