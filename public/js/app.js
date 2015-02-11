//GoldenGate Angular app
var app = angular.module('goldenGate', ['ui.bootstrap']);

app.config(['$locationProvider', function ($locationProvider) {
    $locationProvider.html5Mode(true);
}]);

//Parts Controller
app.controller('partController', ['$scope', '$http', '$location', function ($scope, $http, $location) {

    //TODO RE ORDER ALL THIS SHIT!
    $scope.vector = {};
    $scope.notEnoughParts = false;

//    list of visable alerts
    $scope.alerts = [];

    // array of alert types with css tags
    $scope.alertTypes = {primary: 'primary', info: 'info', warning: 'warning', danger: 'danger', success: 'success'};

    $scope.addAlert = function (type, message) {

//        limit list to 3
        if ($scope.alerts.length >= 3) {
            $scope.alerts.splice(0, 1);
        }
//        add new alert
        $scope.alerts.push({type: type, msg: message});
    };

    var vectorSplitter = 'GGAGTGAGACCGCAGCTGGCACGACAGGTTTGCCGACTGGAAAGCGGGCAGTGAGCGCAACGCAATTAATGTGAGTTAGCTCACTCATTAGGCACCCCAGGCTTTACACTTTATGCTTCCGGCTCGTATGTTGTGTGGAATTGTGAGCGGATAACAATTTCACACAGGAAACAGCTATGACCATGATTACGCCAAGCTTGCATGCCTGCAGGTCGACTCTAGAGGATCCCCGGGTACCGAGCTCGAATTCACTGGCCGTCGTTTTACAACGTCGTGACTGGGAAAACCCTGGCGTTACCCAACTTAATCGCCTTGCAGCACATCCCCCTTTCGCCAGCTGGCGTAATAGCGAAGAGGCCCGCACCGATCGCCCTTCCCAACAGTTGCGCAGCCTGAATGGCGAATGGCGCCTGATGCGGTATTTTCTCCTTACGCATCTGTGCGGTATTTCACACCGCATATGGTGCACTCTCAGTACAATCTGCTCTGATGCCGCATAGTTAAGCCAGCCCCGACACCCGCCAACACCCGCTGACGCGCCCTGACGGGCTTGTCTGCTCCCGGCATCCGCTTACAGACAAGCTGTGACGGTCTCACGCT';
//    make the scope aware of part groups
    $scope.partsGroups = [];


//    to allow a blank option in selects
//    var blankOption = {label: "NONE", fake: true};


    $scope.cannotGetParts = function () {
        $scope.addAlert($scope.alertTypes.danger, 'could not get list of parts, Please try again');
    };

    var locationParts = $location.search();
    if (locationParts && locationParts.parts) {
        var parts = locationParts.parts.split(",");
        if (parts && parts.length && parts.length > 0) {

            var fixedParts = [];

            parts.forEach(function (part) {
                fixedParts.push(part.replace(" ", "+"));
            });

            $scope.partTypes = fixedParts;
        } else {
            $scope.cannotGetParts();
        }
    } else {
        $scope.cannotGetParts();
    }

//    current gate parts
    $scope.gateParts = [];

//    fake part for when a user wants to add their own seq
//    var customPart = {_id: 0, label: 'USE YOUR OWN PART', overhang_l: '', overhang_r: '', seq: '', customPart: true};

    $http.get('/vectors').success(function (vectors) {
        $scope.vectors = vectors;
    }).error(function () {
        $scope.addAlert($scope.alertTypes.danger, 'We could not get the vectors from /vectors, the app will fail');
    });

    $scope.refreshParts = function () {


//    get all available parts
        $http.get('/parts').success(function (parts) {
            //console.log(parts);
            $scope.parts = parts;
//        for each part type
            $scope.partTypes.forEach(function (pt, int) {
//            describe the object

                $scope.partsGroups[int] = {};
                $scope.partsGroups[int].type = pt;
                $scope.partsGroups[int].parts = [];
//            $scope.partsGroups[int].parts.push(blankOption);
//            for each part
                var typeCount = 0;
                //FIX ME bug where pt does not have a plut
                $scope.parts.forEach(function (part) {

                    var type = part.type;
//                if the part type is same as the type
//                    console.log(pt,type, pt.toUpperCase() == type.toUpperCase());
                    if (pt.toUpperCase() == type.toUpperCase()) {
//                    push matching part into sub array
                        typeCount++;
                        $scope.partsGroups[int].parts.push(part);
                    }
                });
                if (typeCount < 1) {
                    $scope.notEnoughParts = true;
                }


            });
            if ($scope.notEnoughParts == true) {
                $scope.addAlert($scope.alertTypes.danger, 'We do not have parts for all the types you have requested');
            }

            $scope.partsGroups.forEach(function (pg) {
                pg.parts.push({label: 'CUSTOM'});
            });


        }).error(function () {
            $scope.addAlert($scope.alertTypes.danger, 'We could not get the parts from /parts, the app will fail');
        });
    };

    $scope.refreshParts();

//    return the append for the col styles based on the amount of items in partTypes the list
    $scope.getColSize = function () {
        switch ($scope.partTypes.length) {
            case 0:
                break;
            case 1:
                return 12;
                break;
            case 2:
                return '6';
                break;
            case 3:
                return '4';
                break;
            case 4:
                return '3';
                break;
            case 5:
//                custom css rule
                return 'fifth';
                break;
            case 6:
                return '2';
                break;
            case 7:
//                custom css rule
                return 'seventh';
                break;
            default:
                return 1;
                break;
        }
    };

    function resetCustomPart(part) {
        part._id = "CUSTOM";
        part.file = undefined;
        part.overhang_l = "";
        part.overhang_r = "";
        part.seq = "";
        part.type = "CUSTOM";
    }

    $scope.updateCustomPart = function (selector) {


        var seq = selector.customSeq;
        var part = selector.part.parts[selector.part.parts.length - 1];


        if (seq.length >= 4) {
            part.overhang_l = seq.substring(0, 4);
        }

        if (seq.length >= 8) {
            part.overhang_r = seq.substring(seq.length - 4);
        }
        if (seq.length > 8) {
            part.seq = seq;
        }
        $scope.checkCompat(selector);
    };

    $scope.changePart = function (selector) {
        console.log(selector);
        var currentPart = selector.opt;
        if (currentPart.label == "CUSTOM") {
            console.log('gonna reset custom part');
            resetCustomPart(currentPart);
        }
        $scope.checkCompat(selector);
    };

    $scope.finalCheck = function () {
        var prev;
        var good = true;

        $scope.gateParts.forEach(function (part) {
            if (prev && prev.overhang_r !== part.overhang_l) {
                good = false;
            }
            prev = part;
        });

        return good;
    };


    $scope.checkCompat = function (selector) {


        var currentPart = selector.opt;


        $scope.gateParts[selector.$index] = currentPart;

//        if the selector is blank/reset then it will not have any data bound to it
        if (currentPart) {
//            is not far left
            if (!selector.$first) {
                processLeft();
            }
//            is not far right
            if (!selector.$last) {
                processRight();
            }
        } else {

//            enable sides of selection that was reset/emptied
            if (selector.$$prevSibling) {
                selector.$$prevSibling.part.parts.forEach(function (part) {
                    enableOption(selector.$$prevSibling, part);
                });
            }

            if (selector.$$nextSibling) {
                selector.$$nextSibling.part.parts.forEach(function (part) {
                    enableOption(selector.$$nextSibling, part);
                });
            }
        }

        //        process the select to the left of the modified select
        function processLeft() {
            if (selector.$$prevSibling && selector.$$prevSibling.part) {
                selector.$$prevSibling.part.parts.forEach(function (part) {
                    enableOption(selector.$$prevSibling, part);
//                    if (currentPart.overhang_l == part.overhang_r || currentPart.label == "CUSTOM" || part.label == "CUSTOM") {
                    if (currentPart.overhang_l == part.overhang_r || part.label == "CUSTOM") {
                        enableOption(selector.$$prevSibling, part);
                    } else {
                        disableOption(selector.$$prevSibling, part);
                    }
                });

            }
        }

//        process the select to the right of the modified select
        function processRight() {
            if (selector.$$nextSibling && selector.$$nextSibling.part) {
                selector.$$nextSibling.part.parts.forEach(function (part) {
//                    if (currentPart.overhang_r == part.overhang_l || currentPart.label == "CUSTOM" || part.label == "CUSTOM") {
                    if (currentPart.overhang_r == part.overhang_l || part.label == "CUSTOM") {
                        enableOption(selector.$$nextSibling, part);
                    } else {
                        disableOption(selector.$$nextSibling, part);
                    }
                });
            }
        }

        //enable select option
        function enableOption(group, part) {
            var select = group.part.type.replace('+', '\\+');
            $("#" + select).find("option").filter(function () {
                return part.label === $(this).text();
            }).attr("disabled", false);
        }

        //disable select option
        function disableOption(group, part) {
            var select = group.part.type.replace('+', '\\+');
            $("#" + select).find("option").filter(function () {
                return part.label === $(this).text();
            }).attr("disabled", true);

            if (group.opt && part.label == group.opt.label) {
                group.opt = null;
            }
        }
    };


    //remove alert from list + view
    $scope.closeAlert = function (index) {
        $scope.alerts.splice(index, 1);
    };

    //process the final output
    $scope.build = function () {

        //$('.ct-chart').hide();
        var resultWrap = $('#resultwrap');
        resultWrap.slideUp();

        var vector = $scope.vector;
        var parts = $scope.gateParts;

        if (!$scope.vector || !$scope.vector.seq || !$scope.vector.seq.length || !$scope.vector.seq.length > 1) {
            $scope.addAlert($scope.alertTypes.warning, 'Select a vector');
            return;
        }


        var test = parts.filter(function (item) {
            return item === null;
        });


        if (!parts || !parts.length || !parts.length > 0 || parts.length != $scope.partTypes.length || !test > 0) {


            //TODO ERROR
            $scope.addAlert($scope.alertTypes.warning, 'Please make a selection of each part type');
            return;
        }


        if ($scope.finalCheck()) {
            var splitVector = vector.seq.split(vectorSplitter);
            if (splitVector && splitVector.length == 2) {

                resultWrap.slideDown(400, function () {
                    $scope.genChart();
                });


            } else {
                //bad
                $scope.addAlert($scope.alertTypes.warning, 'splitVector not valid or splitVector.length != 2');
            }


            $http.post('/buildit', [vector, parts]).success(function (outputFile) {
                $scope.outputDownload = outputFile;

            }).error(function (response, code) {
                $scope.addAlert($scope.alertTypes.danger, 'http post error ' + code);
            });
        } else {
            $scope.addAlert($scope.alertTypes.warning, 'Parts to not build correctly');
        }
    };


    $scope.saveBridge = function () {

        var vector = $scope.vector;
        var parts = $scope.gateParts;

        var gateName = $scope.bridgeName;

        var partsSeqs = [];

        parts.forEach(function (p) {
            partsSeqs.push(p.label);
        });

        $http.post('/savebridge', [gateName, vector.label, partsSeqs]).success(function () {
            $scope.addAlert($scope.alertTypes.success, 'Saved it.');
            $scope.reloadBridges();
        }).error(function () {
            $scope.addAlert($scope.alertTypes.danger, 'Failed to save.');
        });
    };

    $scope.reloadBridges = function () {
        $http.get('/loadbridge').success(function (bridges) {
            $scope.savedBridges = bridges;
        }).error(function () {
        });
    };
    $scope.reloadBridges();

    $scope.setBridge = function (bridgeToLoad) {

        $scope.partTypes = [];

        bridgeToLoad.parts.forEach(function (part) {
            var type = part.split("-")[0];
            $scope.partTypes.push(type);
        });

    };

    //generate the donut chart
    $scope.genChart = function () {

        //current vector
        var vector = $scope.vector;
        //current parts
        var parts = $scope.gateParts;

        //vector should take up 60% of the chart
        var vectorPercent = 60;
        //sum of parts should take up 40% of the chart
        var partsPercent = 40;
        //one percent of 360 degrees
        var percent = 360 / 100;
        //offset the rotation of the chart to center it
        var startAngle = -((partsPercent / 2) * percent);
        var series = [];
        var labels = [];
        var partPercent = (partsPercent / parts.length) * percent;


        //+++++++++++
        //This is VERY brittle!

        series.push(vectorPercent * percent);

        parts.forEach(function (part) {
            labels.push(part.label);
            series.push(partPercent);
        });

        labels.push(vector.label);

        labels.reverse();
        series.reverse();

        //+++++++++++

        var chartWidth = 50;
        var chartHoverWidth = 60;
        var animationSpeed = 300; //lower is quicker

        new Chartist.Pie('.ct-chart', {
                series: series,
                labels: labels
            }, {
                donut: true,
                donutWidth: chartWidth,
                startAngle: startAngle,
                total: 360,
                showLabel: false
            }
        );

        //voodoo
        var easeOutQuad = function (x, t, b, c, d) {
            return -c * (t /= d) * (t - 2) + b;
        };

        //dom el of chart
        var $chart = $('.ct-chart');

        var $toolTip = $chart
            .append('<div class="tooltipper"></div>')
            .find('.tooltipper')
            .hide();


        //on mouse enter
        $chart.on('mouseenter', '.ct-slice', function () {
            var $point = $(this);
            var position = $point.parent().index();
            var seriesName = labels[position];

            //if ($point.css('stroke-width') == chartWidth + 'px') {
            $point.animate({'stroke-width': chartHoverWidth + 'px'}, animationSpeed, easeOutQuad);
            //}

            $toolTip.html(seriesName).show();
        });

        //on mouse leave
        $chart.on('mouseleave', '.ct-slice', function () {
            var $point = $(this);
            $point.animate({'stroke-width': chartWidth + 'px'}, animationSpeed, easeOutQuad);
            $toolTip.hide();
        });

        //on mouse move
        $chart.on('mousemove', function (event) {
            $toolTip.css({
                left: event.offsetX - $toolTip.width() / 2 - 10,
                top: event.offsetY - $toolTip.height() + 40
            });
        });
    };


}]);

