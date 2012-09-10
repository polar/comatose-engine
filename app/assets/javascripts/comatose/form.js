// Edit Form Functions
var ComatoseEditForm = {

    default_data:{},
    last_preview:{},
    last_title_slug:'',
    mode:null,
    liquid_horiz:true,
    width_offset:325,

    // Initialize the page...
    init:function (mode) {
        this.mode = mode;
        this.default_data = Form.serialize(document.forms['comatose-page-form']);
        $('#page_title').focus();
        Hide.these(
            '#preview-area',
            '#slug_row',
            '#parent_row',
            '#keywords_row',
            '#filter_row',
            '#created_row'
        );
        $('page_title').select();
        // Create the horizontal liquidity of the fields
        if (this.liquid_horiz) {
            xOffset = this.width_offset;
            new Layout.LiquidHoriz((xOffset + 50), 'page_title');
            new Layout.LiquidHoriz(xOffset, 'page_slug', 'page_keywords', 'page_parent', 'page_body');
        }
    },
    // Todo: Make the meta fields remember their visibility?
    toggle_extra_fields:function (anchor) {
        if (anchor.html() == "More...") {
            Show.these(
                '#slug_row',
                '#keywords_row',
                '#parent_row',
                '#filter_row',
                '#created_row'
            );
            anchor.html('Less...');
        } else {
            Hide.these(
                '#slug_row',
                '#keywords_row',
                '#parent_row',
                '#filter_row',
                '#created_row'
            );
            anchor.html('More...');
        }
    },

    // Uses server to create preview of content...
    preview_content:function (preview_url) {
        $('#preview-area').show();
        var params = Form.serialize(document.forms['comatose-page-form']);
        if (params != this.last_preview) {
            $('#preview-panel').html("<span style='color:blue;'>Loading Preview...</span>");
            new Ajax.Updater(
                '#preview-panel',
                preview_url,
                { parameters:params }
            );
        }
        this.last_preview = params;
    },

    cancel:function (url) {
        var current_data = Form.serialize(document.forms['comatose-page-form']);
        var data_changed = (this.default_data != current_data)
        if (data_changed) {
            if (confirm('Changes detected. You will lose all the updates you have made if you proceed...')) {
                location.href = url;
            }
        } else {
            location.href = url;
        }

    }
}

var Hide = {
    these:function () {
        for (var i = 0; i < arguments.length; i++) {
            try {
                $(arguments[i]).hide();
            } catch (e) {
            }
        }
    }
}

var Show = {
    these:function () {
        for (var i = 0; i < arguments.length; i++) {
            try {
                $(arguments[i]).show();
            } catch (e) {
            }
        }
    }
}