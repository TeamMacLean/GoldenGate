console.log('started loading');

$( document ).ready(function() {

    NProgress.configure({ showSpinner: false });
    NProgress.start();

    var pro = $('#PRO');
    var uu = $('#5U');
    var nt = $('#NT2');
    var cds = $('#CDS');

    var ws = new WebSocket('ws://localhost:3000/echo');
    ws.onopen = function () {
        console.log('Connection opened');
    };

    ws.onmessage = function (msg) {

        var res = JSON.parse(msg.data);
//    console.log(res);

        res.forEach(function (fist) {
//        console.log(fist);

            if (fist.label.toUpperCase().indexOf("PRO") > -1) {
                pro.append(new Option(fist.label, fist.seq));
            }
            if (fist.label.toUpperCase().indexOf("5U") > -1) {
                uu.append(new Option(fist.label, fist.seq));
            }
            if (fist.label.toUpperCase().indexOf("NT2") > -1) {
                nt.append(new Option(fist.label, fist.seq));
            }
            if (fist.label.toUpperCase().indexOf("CDS") > -1) {
                cds.append(new Option(fist.label, fist.seq));
            }
        });
        console.log('added options');
        NProgress.done(true);

    };

    function checkCompat(){
        console.log('Checking compat');

    }

    [pro, uu, nt, cds].forEach(
        function (selection) {
            console.log('Added checkCompat on change to', selection.selector);
            selection.change(function(){
//                alert('change');
                checkCompat();
            });
        });



    $('#buildit').click(function () {
        var out = pro.val() +''+ uu.val() +''+ nt.val() +''+ cds.val();
        $('#resultstring').text(out);
        $('#resultwrap').show();
    });

});