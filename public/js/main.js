//Toggle dropdowns
var tags = $('.tagType');
tags.click(function () {
    var index = tags.index(this);
    console.log(index);
    tags.each(function () {
        var tag = $(this);
        console.log(tag.index());
        var el = tag.find('.toggle-section');
        if (tag.index() != index) {
            el.hide();
            el.parent().find('.caret').removeClass('caret-active');
        } else {
            el.toggle();
            el.parent().find('.caret').toggleClass('caret-active');
        }
    });
});
