
Slugify = function (options) {
    $.extend(this,options);
    this.initialize();
};

Slugify.prototype = {

    source : "input#slugify",
    dest : "input#slug",

    initialize : function() {
        var ctrl = this;

        $(this.source).keyup(function() {
            var slug_input = $(ctrl.dest);
            var delimiter = slug_input.hasClass('delimiter-underscore') ? '_' : '-';
            slug_input.val( ctrl.slugify( $(this).val(), delimiter ) );
        });

    },

    slugify : function (str, delimiter) {
        var opposite_delimiter = (delimiter == '-') ? '_' : '-';
        str = str.replace(/^\s+|\s+$/g, '');
        var from = "ÀÁÄÂÈÉËÊÌÍÏÎÒÓÖÔÙÚÜÛàáäâèéëêìíïîòóöôùúüûÑñÇç";
        var to   = "aaaaeeeeiiiioooouuuuaaaaeeeeiiiioooouuuunncc";
        for (var i=0, l=from.length ; i<l ; i++) {
            str = str.replace(new RegExp(from[i], "g"), to[i]);
        }
        var chars_to_replace_with_delimiter = new RegExp('[·/,:;'+ opposite_delimiter +']', 'g');
        str = str.replace(chars_to_replace_with_delimiter, delimiter);
        var chars_to_remove = new RegExp('[^a-zA-Z0-9 '+ delimiter +']', 'g');
        str = str.replace(chars_to_remove, '').replace(/\s+/g, delimiter).toLowerCase();
        return str;
    }
};