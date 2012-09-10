// CSS Browser Selector   v0.2.3b (M@: added noscript support)
// Documentation:         http://rafael.adm.br/css_browser_selector
// License:               http://creativecommons.org/licenses/by/2.5/
// Author:                Rafael Lima (http://rafael.adm.br)
// Contributors:          http://rafael.adm.br/css_browser_selector#contributors
var css_browser_selector = function () {
    var
        ua = navigator.userAgent.toLowerCase(),
        is = function (t) {
            return ua.indexOf(t) != -1;
        },
        h = document.getElementsByTagName('html')[0],
        b = (!(/opera|webtv/i.test(ua)) && /msie (\d)/.test(ua)) ? ((is('mac') ? 'ieMac ' : '') + 'ie ie' + RegExp.$1)
            : is('gecko/') ? 'gecko' : is('opera') ? 'opera' : is('konqueror') ? 'konqueror' : is('applewebkit/') ? 'webkit safari' : is('mozilla/') ? 'gecko' : '',
        os = (is('x11') || is('linux')) ? ' linux' : is('mac') ? ' mac' : is('win') ? ' win' : '';
    var c = b + os + ' js';
    h.className = h.className.replace('noscript', '') + h.className ? ' ' + c : c;
}();
