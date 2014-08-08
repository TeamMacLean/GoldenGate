var app = angular.module('goldenGate', ['ui.bootstrap']);

app.config(['$locationProvider', function ($locationProvider) {
    $locationProvider.html5Mode(true);
}]);

app.controller('partController', ['$scope', '$http', '$location', function ($scope, $http, $location) {

    //TODO RE ORDER ALL THIS SHIT!
    var myDoughnutChart;
    $scope.vector = {};
    $scope.notEnoughParts = false;

//    list of visable alerts
    $scope.alerts = [
    ];

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
    $scope.partsGroups = {};


//    to allow a blank option in selects
//    var blankOption = {label: "NONE", fake: true};


    $scope.cannotGetParts = function () {
        $scope.addAlert($scope.alertTypes.danger, 'could not get list of parts, Please try again');
    };

    var locationParts = $location.search();
    if (locationParts && locationParts.parts) {
        var parts = locationParts.parts.split(",");
        if (parts && parts.length && parts.length > 0) {
            $scope.partTypes = parts;
        } else {
            $scope.cannotGetParts();
        }
    } else {
        $scope.cannotGetParts();
    }

//    current gate parts
    $scope.gateParts = [];

//    get part types from picker
//    $scope.partTypes = ['orp', 'u5', 'sdc', '3u+ter'];

//    data style
//    [{type,[parts]},{type,[parts]},{type,[parts]}]

//    fake part for when a user wants to add their own seq
    var customPart = {_id: 0, label: 'USE YOUR OWN PART', overhang_l: '', overhang_r: '', seq: '', customPart: true};

    $http.get('/vectors').success(function (vectors) {
        $scope.vectors = vectors;
    }).error(function () {
        $scope.addAlert($scope.alertTypes.danger, 'We could not get the vectors from /vectors, the app will fail');
    });

    $scope.refreshParts = function () {


//    get all available parts
        $http.get('/parts').success(function (parts) {
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
                $scope.parts.forEach(function (part) {

//                get type from label
                    var type = part.label.split("-")[0];
//                if the part type is same as the type
                    if (pt.toUpperCase() == type.toUpperCase()) {
//                    push matching part into sub array
                        typeCount++;
                        $scope.partsGroups[int].parts.push(part);
                    }
                });
                if (typeCount < 1) {
                    $scope.notEnoughParts = true;
                }
                //            //TODO add custom part option
//                $scope.partsGroups[int].parts.push(customPart);

            });
            if ($scope.notEnoughParts == true) {
                $scope.addAlert($scope.alertTypes.danger, 'We do not have parts for all the types you have requested');
            }
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

//    compare the selects to the left and right, disable incompatible parts
    $scope.checkCompat = function (selector) {

        var currentPart = selector.opt;

        $scope.gateParts[selector.$index] = currentPart;

//        if the selector is blank/reset then it will not have any data bound to it
        if (currentPart) {

            if (currentPart.label == "Custom") {
            }

//            is not far left
            if (!selector.first) {
                processLeft();
            }
//            is not far right
            if (!selector.last) {
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
                    if (currentPart.overhang_l == part.overhang_r) {
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
                    if (currentPart.overhang_r == part.overhang_l) {
                        enableOption(selector.$$nextSibling, part);
                    } else {
                        disableOption(selector.$$nextSibling, part);
                    }
                });
            }
        }

        function enableOption(group, part) {
            $("#" + group.part.type).find("option").filter(function () {
                return part.label === $(this).text();
            }).attr("disabled", false);
        }

        function disableOption(group, part) {
            $("#" + group.part.type).find("option").filter(function () {
                return part.label === $(this).text();
            }).attr("disabled", true);

            if (group.opt && part.label == group.opt.label) {
                group.opt = null;
            }
        }
    };


//    remove alert from list + view
    $scope.closeAlert = function (index) {
        $scope.alerts.splice(index, 1);
    };

//    process the final output
    $scope.build = function () {
//TODO EVERYTHING

        $("#donut").hide();
        $('#resultwrap').slideUp();


        var vector = $scope.vector;
        var parts = $scope.gateParts;

        if (!$scope.vector || !$scope.vector.seq || !$scope.vector.seq.length || !$scope.vector.seq.length > 1) {
            $scope.addAlert($scope.alertTypes.warning, 'Select a vector');
            return;
        }


        if (!parts || !parts.length || !parts.length > 0 || parts.length != $scope.partTypes.length) {
            //TODO ERROR
            $scope.addAlert($scope.alertTypes.warning, 'Please make a selection of each part type');
            return;
        }


        var splitVector = vector.seq.split(vectorSplitter);
        if (splitVector && splitVector.length == 2) {
            //good
//            var tmppy = '';
//            parts.forEach(function (part) {
//                tmppy += '\n' + part.seq;
//            });
//            var whore = splitVector[0] + tmppy + '\n' + splitVector[1];
//            $('#resultstring').text(whore);



            $('#resultwrap').slideDown(400, function(){
                $("#donut").show();
                $scope.renderDonut();
            });



        } else {
            //bad
            $scope.addAlert($scope.alertTypes.warning, 'splitVector not valid or splitVector.length != 2');
        }


        //        $('#resultwrap').show();

        $http.post('/buildit', [vector, parts]).success(function (outputFile) {
            $scope.outputDownload = outputFile;

//            $scope.addAlert($scope.alertTypes.success, 'Got success.');
        }).error(function (response, code) {
            $scope.addAlert($scope.alertTypes.danger, 'http post error ' + code);
        });
    };

    function shuffle(o) { //v1.0
        for (var j, x, i = o.length; i; j = Math.floor(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
        return o;
    }

    $scope.renderDonut = function () {
        var data = [];

        var graphPartCount = parts.length;
        var graphVecPercent = 60;

        var graphPartPercent = (100 - graphVecPercent) / graphPartCount;

        var chartColors = ["#1abc9c", "#2ecc71", "#3498db", "#9b59b6", "#f1c40f", "#e67e22", "#e74c3c"];
        chartColors = shuffle(chartColors);

        data.push(
            {
                value: graphVecPercent,
                color: chartColors[graphPartCount],
                highlight: "#FFC870",
                label: "Yellow",
                labelColor: 'white'
            }
        );
        parts.forEach(function (part, pos) {
            data.push(
                {
                    value: graphPartPercent, color: chartColors[pos], highlight: "#FFC870", label: graphPartPercent
                }
            );
        });

        var ctx = document.getElementById("donut").getContext("2d");
        myDoughnutChart = new Chart(ctx).Doughnut(data, {responsive: true});

//        ctx.translate(0,0);
//        ctx.rotate(5*Math.PI / 180);

        ctx.translate(150, 150);
        ctx.rotate(72 * Math.PI / 180);
        ctx.translate(-150, -150);

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


}]);

