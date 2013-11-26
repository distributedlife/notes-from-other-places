jQuery.fn.exists = function(){return this.length>0;}

var move_to_next_article = function() {
    if ($("#next").exists()) {
        window.open($("#next")[0].href, '_self', false);
    }
};
var move_to_previous_article = function() {
    if ($("#prev").exists()) {
        window.open($("#prev")[0].href, '_self', false);
    }
};

key('right', move_to_next_article);
key('left', move_to_previous_article);