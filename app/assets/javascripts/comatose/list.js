// List View Functions
//= require ./cookie
//= require_self

var ComatoseList = {
    save_node_state:true,
    state_store:'cookie', // Only 'cookie' for now
    state_key:'ComatoseTreeState',

    init:function () {
        var items = ComatoseList._read_state();
        items.each(function (node) {
            ComatoseList.expand_node(node.replace('page_controller_', ''))
        });
    },

    toggle_tree_nodes:function (img, id) {
        if (/expanded/.test(img.src)) {
            $('#page_list_' + id).addClass('collapsed');
            img.attr("src", img.attr("src").replace(/expanded/, 'collapsed'));
            if (ComatoseList.save_node_state) {
                var items = ComatoseList._read_state();
                items = items.select(function (id) {
                    return id != img.id;
                })
                ComatoseList._write_state(items);
            }
        } else {
            $('#page_list_' + id).removeClass('collapsed');
            img.attr("src", img.attr("src").replace(/collapsed/, 'expanded'));
            if (ComatoseList.save_node_state) {
                var items = ComatoseList._read_state();
                items.push(img.id);
                ComatoseList._write_state(items);
            }
        }
    },

    expand_node:function (id) {
        $('#page_list_' + id).removeClass('collapsed');
        $('#page_controller_' + id).attr("src", $('#page_controller_' + id).attr("src").replace(/collapsed/, 'expanded'));
    },

    collapse_node:function (id) {
        $('#page_list_' + id).addClass'collapsed');
        $('#page_controller_' + id).attr("src", $('#page_controller_' + id).attr("src").replace(/expanded/, 'collapsed'));
    },

    item_hover:function (node, state, is_delete) {
        if (state == 'over') {
            $(node).addClassName((is_delete) ? 'hover-delete' : 'hover');
        } else {
            $(node).removeClassName((is_delete) ? 'hover-delete' : 'hover');
        }
    },

    toggle_reorder:function (node, anc, id) {
        if ($(node).hasClass('do-reorder')) {
            $(node).removeClass('do-reorder');
            $(anc).removeClass('reordering');
            $(anc).html("reorder children");
        } else {
            $(node).addClass('do-reorder');
            $(anc).addClass('reordering');
            $(anc).html("finished reordering");
            // Make sure the children are visible...
            ComatoseList.expand_node(id);
        }
    },

    _write_state:function (items) {
        var cookie = {};
        var options = {};
        var expiration = new Date();
        cookie[ ComatoseList.state_key ] = items.join(',');
        expiration.setDate(expiration.getDate() + 30)
        options['expires'] = expiration;
        Cookie.write(cookie, options);
    },

    _read_state:function () {
        var state = Cookie.read(ComatoseList.state_key);
        return (state != "" && state != null) ? state.split(',') : [];
    }
}