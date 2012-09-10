eta
fields
remember
their
visibility ?
    toggle_extra_fields : function (anchor) {
    if (anchor.innerHTML == "More...") {
        Show.these(
            'slug_row',
            'keywords_row',
            'parent_row',
            'filter_row',
            'created_row'
        );
        anchor.innerHTML = 'Less...';
    } else {
        Hide.these(
            'slug_row',
            'keywords_row',
            'parent_row',
            'filter_row',
            'created_row'
        );
        anchor.innerHTML = 'More...';
    }
},
    // Uses server to create preview of content...
    preview_content
:
function (preview_url) {
    $('preview-area').show();
    var params = Form.serialize(document.forms['pageForm']);
    if (params != this.last_preview) {
        $('preview-panel').innerHTML = "<span style='color:blue;'>Loading Preview...</span>";
        new Ajax.Updater(
            'preview-panel',
            preview_url,
            { parameters:params }
        );
    }
    this.last_preview = params;
}
,
cancel : function (url) {
    var current_data = Form.serialize(document.forms['pageForm']);
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

// Layout namespace
var Layout = {};

// This class allows dom objects to stretch with the browser
// (for when a good, cross-browser, CSS approach can't be found)
Layout.LiquidBase = Class.create();
// Base class for all Liquid* layouts...
Object.extend(Layout.LiquidBase.prototype, {
    enabled:true,
    elems:[],
    offset:null,
    // Constructor is (offset, **array_of_elements)
    initialize:function () {
        args = $A(arguments)
        this.offset = args.shift();
        this.elems = args.select(function (elem) {
            return ($(elem) != null)
        });
        if (this.elems.length > 0) {
            this.on_resize(); // Initial size
            Event.observe(window, 'resize', this.on_resize.bind(this));
            Event.observe(window, 'load', this.on_resize.bind(this));
        }
    },
    resize_in:function (timeout) {
        setTimeout(this.on_resize.bind(this), timeout);
    },
    on_resize:function () {
        // Need to override!
        alert('Override on_resize, please!');
    }
});


// Liquid vertical layout
Layout.LiquidVert = Class.create();
Object.extend(Layout.LiquidVert.prototype, Object.extend(Layout.LiquidBase.prototype, {
    on_resize:function () {
        if (this.offset != null && this.enabled) {
            var new_height = ((window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight) - this.offset) + "px";
            this.elems.each(function (e) {
                $(e).style.height = new_height;
            })
        }
    }
}));


// Liquid horizontal layout
Layout.LiquidHoriz = Class.create();
Object.extend(Layout.LiquidHoriz.prototype, Object.extend(Layout.LiquidBase.prototype, {
    on_resize:function () {
        if (this.offset != null && this.enabled) {
            var new_width = ((window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth) - this.offset) + "px";
            this.elems.each(function (e) {
                $(e).style.width = new_width;
            })
        }
    }
}));

// String Extensions... Yes, these are from Radiant! ;-)
Object.extend(String.prototype, {
    upcase:function () {
        return this.toUpperCase();
    },
    downcase:function () {
        return this.toLowerCase();
    },
    strip:function () {
        return this.replace(/^\s+/, '').replace(/\s+$/, '');
    },
    toInteger:function () {
        return parseInt(this);
    },
    toSlug:function () {
        // M@: Modified from Radiant's version, removes multple --'s next to each other
        // This is the same RegExp as the one on the page model...
        return this.strip().downcase().replace(/[^-a-z0-9~\s\.:;+=_]/g, '').replace(/[\s\.:;=_+]+/g, '-').replace(/[\-]{2,}/g, '-');
    }
});

// Run a spinner when an AJAX request in running...
var ComatoseAJAXSpinner = {
    busy:function () {
        if ($('spinner') && Ajax.activeRequestCount > 0) {
            Effect.Appear('spinner', {duration:0.5, queue:'end'});
        }
    },

    notBusy:function () {
        if ($('spinner') && Ajax.activeRequestCount == 0) {
            Effect.Fade('spinner', {duration:0.5, queue:'end'});
        }
    }
}
// Register it with Prototype...
Ajax.Responders.register({
    onCreate:ComatoseAJAXSpinner.busy,
    onComplete:ComatoseAJAXSpinner.notBusy
});


if (!window.Cookie)
    (function () {
        // From Mephisto!
        window.Cookie = {
            version:'0.7',
            cookies:{},
            _each:function (iterator) {
                $H(this.cookies).each(iterator);
            },

            getAll:function () {
                this.cookies = {};
                $A(document.cookie.split('; ')).each(function (cookie) {
                    var seperator = cookie.indexOf('=');
                    this.cookies[cookie.substring(0, seperator)] =
                        unescape(cookie.substring(seperator + 1, cookie.length));
                }.bind(this));
                return this.cookies;
            },

            read:function () {
                var cookies = $A(arguments), results = [];
                this.getAll();
                cookies.each(function (name) {
                    if (this.cookies[name]) results.push(this.cookies[name]);
                    else results.push(null);
                }.bind(this));
                return results.length > 1 ? results : results[0];
            },

            write:function (cookies, options) {
                if (cookies.constructor == Object && cookies.name) cookies = [cookies];
                if (cookies.constructor == Array) {
                    $A(cookies).each(function (cookie) {
                        this._write(cookie.name, cookie.value, cookie.expires,
                            cookie.path, cookie.domain);
                    }.bind(this));
                } else {
                    options = options || {expires:false, path:'', domain:''};
                    for (name in cookies) {
                        this._write(name, cookies[name],
                            options.expires, options.path, options.domain);
                    }
                }
            },

            _write:function (name, value, expires, path, domain) {
                if (name.indexOf('=') != -1) return;
                var cookieString = name + '=' + escape(value);
                if (expires) cookieString += '; expires=' + expires.toGMTString();
                if (path) cookieString += '; path=' + path;
                if (domain) cookieString += '; domain=' + domain;
                document.cookie = cookieString;
            },

            erase:function (cookies) {
                var cookiesToErase = {};
                $A(arguments).each(function (cookie) {
                    cookiesToErase[cookie] = '';
                });

                this.write(cookiesToErase, {expires:(new Date((new Date()).getTime() - 1e11))});
                this.getAll();
            },

            eraseAll:function () {
                this.erase.apply(this, $H(this.getAll()).keys());
            }
        };

        Object.extend(Cookie, {
            get:Cookie.read,
            set:Cookie.write,

            add:Cookie.read,
            remove:Cookie.erase,
            removeAll:Cookie.eraseAll,

            wipe:Cookie.erase,
            wipeAll:Cookie.eraseAll,
            destroy:Cookie.erase,
            destroyAll:Cookie.eraseAll
        });
    })();
