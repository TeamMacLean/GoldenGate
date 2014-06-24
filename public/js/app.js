var app = angular.module('goldenGate', ['ui.bootstrap']);

app.controller('partController', ['$scope', '$http', function ($scope, $http) {

//    make the scope aware of part groups
    $scope.partsGroups = {};

//    to allow a blank option in selects
    var blankOption = {label: "NONE", fake: true};

//    current gate parts
    $scope.gate = [];

//    get part types from picker
    $scope.partTypes = ['pro', '5u', 'cds', '3u+ter'];

//    data sty;e
//    [{type,[parts]},{type,[parts]},{type,[parts]}]

//    fake part for when a user wants to add their own seq
    var customPart = {_id: 0, label: 'USE YOUR OWN PART', overhang_l: '', overhang_r: '', seq: '', customPart: true};

    $http.get('/vectors').success(function (vectors) {
        $scope.vectors = vectors;
//        console.log($scope.vectors);
    }).error(function () {
        $scope.addAlert($scope.alertTypes.danger, 'We could not get the vectors from /vectors, the app will fail');
    });

//    get all available parts
    $http.get('/parts').success(function (parts) {
        $scope.parts = parts;
//        for eact part type
        $scope.partTypes.forEach(function (pt, int) {
//            describe the object
            $scope.partsGroups[int] = {};
            $scope.partsGroups[int].type = pt;
            $scope.partsGroups[int].parts = [];
//            $scope.partsGroups[int].parts.push(blankOption);
//            for each part


            $scope.parts.forEach(function (part) {
//                get type from label
                var type = part.label.split("-")[0];
//                if the part type is same as the type
                if (pt.toUpperCase() == type.toUpperCase()) {
//                    push matching part into sub array
                    $scope.partsGroups[int].parts.push(part);
                }
            });
            //            add custom part option
            $scope.partsGroups[int].parts.push(customPart);
        });
    }).error(function () {
        $scope.addAlert($scope.alertTypes.danger, 'We could not get the parts from /parts, the app will fail');
    });

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

        $scope.gate[selector.$index] = currentPart;

//        if the selector is blank/reset then it will not have any data bound to it
        if (currentPart) {

            if (currentPart.label == "Custom") {
                console.log('its a custom part');
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
            if (selector.$$prevSibling) {
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
            if (selector.$$nextSibling) {
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


    // array of alert types with css tags
    $scope.alertTypes = {primary: 'primary', info: 'info', warning: 'warning', danger: 'danger', success: 'success'};

//    list of visable alerts
    $scope.alerts = [
    ];


    $scope.addAlert = function (type, message) {

//        limit list to 3
        if ($scope.alerts.length >= 3) {
            $scope.alerts.splice(0, 1);
        }
//        add new alert
        $scope.alerts.push({type: type, msg: message});
    };

//    remove alert from list + view
    $scope.closeAlert = function (index) {
        $scope.alerts.splice(index, 1);
    };

//    process the final output
    $scope.build = function () {
//TODO


        var vector = $scope.vector;
        var parts = $scope.gate;


        //        $('#resultwrap').show();

        $http.post('/buildit', [vector, parts]).success(function () {
            $scope.addAlert($scope.alertTypes.success, 'Got success.');
        }).error(function () {
            $scope.addAlert($scope.alertTypes.danger, 'Got error');
        });
    }
}]);

//handle saved bridges TODO
function gateController($scope, $http) {

    $scope.addGate = function () {

    };

    $scope.loadGate = function () {

    };

}

