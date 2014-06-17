console.log('started loading');

$(document).ready(function () {
    var features;

    NProgress.configure({ showSpinner: false });
    NProgress.start();

    var vec = $('#VEC');
    var pro = $('#PRO');
    var uu = $('#5U');
    var nt = $('#NT2');
    var cds = $('#CDS');
    var ter = $('#TER');

    var inputs = [pro, uu, nt, cds, ter]; //TODO get rid of the currently used input/select

    var ws = new WebSocket('ws://localhost:3000/echo');
    ws.onopen = function () {
        console.log('Connection opened');
    };

    ws.onmessage = function (msg) {

        var res = JSON.parse(msg.data);

        features = res;

        res.forEach(function (fist) {


//            if (fist.label.toUpperCase().indexOf("VEC") > -1) {
//                vec.append(new Option(fist.label, fist._id));
//            }
            if (fist.label.toUpperCase().indexOf("PRO") > -1) {
                pro.append(new Option(fist.label, fist._id));
            }
            if (fist.label.toUpperCase().indexOf("5U") > -1) {
                uu.append(new Option(fist.label, fist._id));
            }
            if (fist.label.toUpperCase().indexOf("NT2") > -1) {
                nt.append(new Option(fist.label, fist._id));
            }
            if (fist.label.toUpperCase().indexOf("CDS") > -1) {
                cds.append(new Option(fist.label, fist._id));
            }
            if (fist.label.toUpperCase().indexOf("TER") > -1) {
                ter.append(new Option(fist.label, fist._id));
            }
        });
        NProgress.done(true);

    };

    $('#buildit').click(function () {
        NProgress.start();
        var proFeature = getFeatureById(pro.val());
        var uuFeature = getFeatureById(uu.val());
        var ntFeature = getFeatureById(nt.val());
        var cdsFeature = getFeatureById(cds.val());

        var out;

        if (finalCompatCheck()) {

            if (proFeature && uuFeature && ntFeature && cdsFeature) {
                out = proFeature.seq + '' + uuFeature.seq + '' + ntFeature.seq + '' + cdsFeature.seq;
            } else {
                out = 'Have you filled out all available options?';
            }
        } else {
            out = 'Not all of your parts are compatible, please check them';
        }

        if (out) {
            $('#resultstring').text(out);
            $('#resultwrap').show();
        } else {
            alert('error, could not combine parts');
        }
        NProgress.done(true);
    });

    function checkCompat(selector) {

        selector.css("border", "none");

        inputs.forEach(function (input) {
            input.prop('disabled', true);
        });

        NProgress.start();
        console.log('Checking compat', selector[0].id);


        // get changed select option
        var thisFeatureID = selector.val();
        var thisFeature = getFeatureById(thisFeatureID);
        if (thisFeature) {


            if (features) {
                inputs.forEach(
                    function (selection, index) {

                        if (selection[0].id == selector[0].id) {


                            // TO THE LEFT
                            if (index - 1 > -1) {
                                var leftInput = inputs[index - 1];
                                var leftChildren = leftInput.children();
                                leftChildren.each(function (leftInxex, leftChild) {
                                    leftChild = $(leftChild);
                                    var leftFeature = getFeatureById(leftChild.val());
                                    if (leftFeature) {
                                        if (leftFeature.overhang_r == thisFeature.overhang_l) {
                                            leftChild.prop('disabled', false);
                                        } else {
                                            leftChild.prop('disabled', true);
                                        }
                                    }
                                });
                            }

                            // TO THE RIGHT
                            if (index + 1 < inputs.length) {
                                var rightInput = inputs[index + 1];
                                var rightChildren = rightInput.children();
                                rightChildren.each(function (rightInxex, rightChild) {
                                    rightChild = $(rightChild);
                                    var rightFeature = getFeatureById(rightChild.val());
                                    if (rightFeature) {
                                        if (rightFeature.overhang_l == thisFeature.overhang_r) {
                                            rightChild.prop('disabled', false);
                                        } else {
                                            rightChild.prop('disabled', true);
                                        }
                                    }
                                });
                            }
                        }
                    });
            }
        }

        inputs.forEach(function (input) {
            input.prop('disabled', false);
        });
        NProgress.done(true);
    }

    function getFeatureById(id) {
        var returnable;
        if (features) {
            features.forEach(function (feature) {
                if (feature._id == id) {
                    returnable = feature;
                }
            });
            return returnable;
        } else {
            console.log('features not loaded');
            alert('error, features not loaded');
        }
    }


    inputs.forEach(
        function (selection) {
            console.log('Added checkCompat on change to', selection.selector);
            selection.change(function () {
                checkCompat(selection);
            });
        });


    function finalCompatCheck() {
        var safe;

        inputs.forEach(function (input) {

            var feature = getFeatureById(input.val());

            if (feature) {
                input.css("border", "none");
                safe = true;
            } else {
                input.css("border-style", "solid");
                input.css("border-color", "#e74c3c");
            }


        });
        return safe;
    }
});


