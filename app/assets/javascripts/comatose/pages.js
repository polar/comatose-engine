//= require jquery.jstree
//= require ./slugify
//= require jquery.remotipart
//= require rails.validations
//= require_self

/**
 * This function may be overwritten in the case that the engine is mounted
 * in someplace other than the default.
 *
 * @return {String}
 */
function reorder_url() {
   return "/comatose/pages/reorder";
}

$(function () {
    $("#close_preview_button").click(function () {
        $("#preview-area").hide();
    });
    $("#import_link2").click(function () {
        $("#import_form").show();
    });
    var slugify = new Slugify({
        source:"#page_title",
        dest:"#page_slug"
    });
    $("#pages_list_root").jstree({
        // the `plugins` array allows you to configure the active plugins on this instance
        "plugins":["themes", "html_data", "crrm", "dnd"],
        // each plugin you have included can have its own config object
        "core":{ "initially_open":[ ".root" ] },

        // it makes sense to configure a plugin only if overriding the defaults
        "themes":{
            "theme":"apple",
            "dots":false,
            "icons":true
        },
        "crrm":{
            "move":{
                "check_move":function (m) {
                    var p = this._get_parent(m.o);
                    if (!p) {
                        return false;
                    }
                    p = p == -1 ? this.get_container() : p;
                    if (p === m.np) {
                        return true;
                    }
                    if (p[0] && m.np[0] && p[0] === m.np[0]) {
                        return true;
                    }
                    return false;
                }
            }
        },
        "dnd":{
            "drop_target":false,
            "drag_target":false
        }
    })
    .bind("move_node.jstree", function (e, data) {
        data.rslt.o.each(function (i) {
            $.ajax({
                async : false,
                type : "POST",
                url  : reorder_url(),
                data : {
                    "id" : $(this).attr("id").replace("page_",""),
                    "position" : data.rslt.cp + i,
                    "copy" : data.rslt.cy ? 1 : 0
                },
                success : function (t) {
                    if (!r.status) {
                        $.jstree.rollback(data.tlbk);
                    }
                    else {
                        $(data.rslt.oc).attr("id", "page_" + r.id);
                        if (data.rslt.cy && $(data.rslt.oc).children("UL").length) {
                            data.inst.refresh(data.inst._getParent(data.rslt.oc));
                        }
                    }
                }

            });
        });
    });

    /*
     * The following is for the Page List.
     */
    $("#import_form").hide();

    $("a.delete-page").live("click",function () {
        $("#" + $(this).attr("data_delete_form")).show();
        return false;
    });

    $("a.delete-cancel").live("click", function () {
        $(".delete_form").hide();
    });
})
;
