$(document).ready(function() {
    timer = function(name, block) {
        var start = new Date();
        block();
        var elapsed = (new Date() - start) / 1000;
        console.log(name + ": " + elapsed + "secs");
        return elapsed;
    };
    
    module("Object extensions");
    test("can begat an object", function() {
            var fixture = { name: "homer" };
            var expected = { name: "homer", kids: { bart: "aye carumba!" } };
            var result = Object.begat(fixture, "kids", { bart: "aye carumba!" });
            same(result, expected, "Expect object to have child objects" );
        });
    test("can begat an object merging the child hash", function() {
            var fixture = { name: "homer", kids: { bart: "aye carumba!" } };
            var expected = { name: "homer", kids: { bart: "aye carumba!", lisa: "bart!" } };
            var result = Object.begat(fixture, "kids", { lisa: "bart!" });
            same(result, expected, "Expect object to merge child object");
        });
    test("can begat an object by using a function", function() {
            var fixture = { name: "homer" };
            var expected = { name: "homer", wives: { marge: "homie!" } };
            var result = Object.begat(fixture, "wives", function(record) {
                    return { marge: "homie!" };
                });
            same(result, expected, "Expect object to have a wife named marge");
        });
    test("can dynamically create object", function() {
            var expected = { song: "Hey Soul Sister" }
            same(Object.n("song", "Hey Soul Sister"), expected, "Object has incorrect key or value");
        });
    
    module("Maybe macros");
    test("maybe zero returns zero when zero", function() {
            var divisor = 0;
            same(0, maybe_t.zero(divisor, function(context) { return 10 / divisor; }), "returns default of zero");

            divisor = 5;
            same(2, maybe_t.zero(divisor, function(context) { return 10 / divisor; }), "returns value");
        });
    
    module("Nullify macros");
    test("can nullify if value is a nan or none", function() {
            same("hello", nullify_t.nan("hello"), "is not nan");
            same(null, nullify_t.nan("nan"), "is nan");
            same("hello", nullify_t.none("hello"), "is not none");
            same(null, nullify_t.none("none"), "is none");

            same("hello", nullify_t.nan(nullify_t.none("hello")), "is not nan or none");
            same(null, nullify_t.nan(nullify_t.none(null)), "is not nan or none");
            same(null, nullify_t.none(nullify_t.nan(null)), "is not none or nan");
        });

    module("Tuftee Data Matrix",  { 
            setup: function() {
                this.tuftee = Tuftee("visualization", 640, 800);
                this.dataMatrix = this.tuftee.dataMatrix;

                this.initFishAndOilByYear = function() {
                    this.dataMatrix.add(["year", [1990, 1991]], ["fish", [1, 2]]);
                    ok(this.dataMatrix.hasDataset("year", "fish"), "has fish dataset?");
                    this.dataMatrix.add(["year", [1991, 1992]], ["oil", [3, 5]]);
                    ok(this.dataMatrix.hasDataset("year", "oil"), "has oil dataset?");
                };

                this.initFishAndOilByCategoryStateYear = function() {
                    this.initOilInStateYear();
                    this.initFishInYearCategory();
                };

                this.initOilInStateYear = function() {
                    this.dataMatrix.add(["year", [1991, 1992]], ["oil", [3, 4]]);
                    ok(this.dataMatrix.hasDataset("year", "oil"), "has oil by year dataset?");
                    this.dataMatrix.add(["state", ["NY", "CA"]], ["oil", [5, 6]]);
                    ok(this.dataMatrix.hasDataset("state", "oil"), "has oil by state dataset?");
                };

                this.initFishInYearCategory = function() {
                    this.dataMatrix.add(["year", [1991, 1992]], ["fish", [3, 4]]);
                    ok(this.dataMatrix.hasDataset("year", "fish"), "has fish by year dataset?");
                    this.dataMatrix.add(["category", ["salmon", "tuna"]], ["fish", [5, 6]]);
                    ok(this.dataMatrix.hasDataset("state", "fish"), "has fish by state dataset?");                    
                };
            }});
    test("can add dataset", function() {
            ok(!_.isUndefined(this.tuftee), "Is Tuftee defined?");
            ok(!_.isUndefined(this.dataMatrix), "Is Tuftee's dataMatrix defined?");
            
            // add the first dataset
            this.dataMatrix.add(["year", [1990, 1991]], ["fish", [1, 2]]);
            ok(this.dataMatrix.hasDataset("year", "fish"), "has the new dataset?");

            var expected = { year: { 1990: { fish: 1 }, 1991: { fish: 2 } } }
            same(this.dataMatrix.recordsets, expected, "Is recordsets correct?");

            var expected = { fish: { year: true } }
            same(this.dataMatrix.axisGraph, expected, "Is axisGraph correct?");

            // add the second dataset
            this.dataMatrix.add(["state", ["NY", "CA"]], ["fish", [3, 4]]);

            var expected = { year: { 1990: { fish: 1 }, 1991: { fish: 2 } },
                             state: { "NY": { fish: 3 }, "CA": { fish: 4 } } }
            same(this.dataMatrix.recordsets, expected, "Is recordsets correct?");
            
            var expected = { fish: { year: true, state: true } }
            same(this.dataMatrix.axisGraph, expected, "Is axisGraph correct?");
        });
    test("can remove dataset", function() {
            // setup
            this.initFishAndOilByYear();

            // test
            this.dataMatrix.remove("year", "fish");
            
            var expected = { year: { 1990: {}, 1991: { oil: 3 }, 1992: { oil: 5 } } }
            same(this.dataMatrix.recordsets, expected, "Is recordsets correct?");
            
            var expected = { oil: { year: true } }
            same(this.dataMatrix.axisGraph, expected, "Is axisGraph correct?");

            ok(!this.dataMatrix.hasDataset("year", "fish"), "removed fish dataset?");
            ok(this.dataMatrix.hasDataset("year", "oil"), "still has oil dataset?");
        });
    test("can clear datasets", function() {
            // setup
            this.initFishAndOilByYear();
            
            // test
            this.dataMatrix.clear();
            
            same(this.dataMatrix.recordsets, {}, "Is recordsets cleared?");
            same(this.dataMatrix.axisGraph, {}, "Is axisGraph cleared?");
            equal(this.dataMatrix.activeOrdinal, null, "Is recordsets cleared?");
        });
    test("can get all ordinal keys", function() {
            ok(_.isEmpty(this.dataMatrix.ordinalKeys()), "ordinal keys is empty");
            
            this.dataMatrix.add(["year", [1990]], ["oil", [3]]);
            this.dataMatrix.add(["state", [1990]], ["oil", [3]]);
            same(this.dataMatrix.ordinalKeys(), ["year", "state"], "has set of ordinal keys");
        });
    test("can get all cardinal keys", function() {
            ok(_.isEmpty(this.dataMatrix.cardinalKeys()), "cardinal keys is empty");
            
            this.dataMatrix.add(["year", [1990]], ["fish", [3]]);
            this.dataMatrix.add(["year", [1990]], ["oil", [3]]);
            same(this.dataMatrix.cardinalKeys(), ["fish", "oil"], "has set of cardinal keys");
        });
    test("can get ordinal link keys", function() {
            this.initOilInStateYear();
            same(this.dataMatrix.ordinalLinkKeys(), ["year", "state"], "has state and year as ordinal axis");

            this.dataMatrix.addLinkKey("year", "oil");
            same(this.dataMatrix.ordinalLinkKeys(), ["year", "state"], "has state and year as ordinal axis");

            this.dataMatrix.addLinkKey("city", "oil");
            same(this.dataMatrix.ordinalLinkKeys(), ["year", "state", "city"], "has city, state, and year");
        });
    test("can get cardinal link key of a specific ordinal key", function() {
            this.initOilInStateYear();
            same(this.dataMatrix.cardinalLinkKeysOf("year"), ["oil"], "knows cardinal key of ordinal key of 'year'");
            same(this.dataMatrix.cardinalLinkKeysOf("state"), ["oil"], "knows cardinal key of ordinal key of 'state'");
        });
    test("can get active ordinal values", function() {
            ok(_.isEmpty(this.dataMatrix.activeOrdinalValues()), "ordinal values is empty");
            
            // setups and test
            this.initOilInStateYear();
            same(this.dataMatrix.activeOrdinalValues(), ["1991", "1992"], "are the same ordinal values?");

            this.dataMatrix.activateOrdinal("state");
            same(this.dataMatrix.activeOrdinalValues(), ["NY", "CA"], "are the same ordinal values?");
        });
    test("can get array^2 matrix of cardinal dimensions", function() {
            var expected = [[]];
            result = this.dataMatrix.matrix();
            same(result, expected, "matrix is empty");
            
            // test for overlapping datasets
            this.initFishAndOilByYear();
            expected = [[1, null], [2, 3], [null, 5]];
            result = this.dataMatrix.matrix();
            same(result, expected, "marix is the same");
        });
    test("can count number of datasets", function() {
            equal(this.dataMatrix.numDatasets(), 0, "has no datasets?");

            this.dataMatrix.add(["year", [1990, 1991]], ["fish", [1, 2]]);
            equal(this.dataMatrix.numDatasets(), 1, "has one dataset?");
            
            this.dataMatrix.add(["year", [1990, 1991]], ["fish", [1, 2]]);
            equal(this.dataMatrix.numDatasets(), 1, "has not added a dataset?");

            this.dataMatrix.add(["year", [1990, 1991]], ["oil", [1, 2]]);
            equal(this.dataMatrix.numDatasets(), 2, "has added a different cardinalkey dataset?");

            this.dataMatrix.add(["state", ["CA", "NY"]], ["oil", [1, 2]]);
            equal(this.dataMatrix.numDatasets(), 3, "has added a different ordinalkey dataset?");

            this.dataMatrix.addLinkKey("city", "fish");
            console.log("axisGraph: " + this.dataMatrix.axisGraph);
            equal(this.dataMatrix.numDatasets(), 3, "has added ordinal link keys?");
        });
    test("can get max length of combined datasets", function() {
            equal(this.dataMatrix.maxDataLength(), 0, "has zero length");
            
            this.dataMatrix.add(["year", [1990, 1991]], ["fish", [1, 2]]);
            equal(this.dataMatrix.activeOrdinal, "year", "primary dimension is year");
            equal(this.dataMatrix.maxDataLength(), 2, "has 2 datapoints");
            
            this.dataMatrix.add(["year", [1990]], ["oil", [3]]);
            equal(this.dataMatrix.maxDataLength(), 2, "less datapoints retains 2 datalegnth count");
            
            this.dataMatrix.add(["year", [1990, 1991, 1992]], ["car", [3, 4, 5]]);
            equal(this.dataMatrix.maxDataLength(), 3, "more datapoints ups to 3 datalength count");
            
            this.dataMatrix.add(["state", ["IL", "CA", "NY", "MD"]], ["fish", [1, 2, 3, 4]]);
            equal(this.dataMatrix.maxDataLength(), 3, "activePrimeDim dictates datalength");
            
            this.dataMatrix.activateOrdinal("state");
            equal(this.dataMatrix.maxDataLength(), 4, "activePrimeDim dictates datalength");
        });
    test("can get the max data value of combined datasets", function() {
            equal(this.dataMatrix.maxDataValue(), -Infinity, "has nothing");
            
            this.dataMatrix.add(["year", [1990, 1991]], ["fish", [1, 2]]);
            same(this.dataMatrix.maxDataValue(), 2, "finds max in one dataset");

            this.dataMatrix.add(["state", ["IL", "CA", "NY", "MD"]], ["fish", [1, 2, 3, 4]]);
            same(this.dataMatrix.maxDataValue(), 2, "data in non-active ordinal dimension have no effect");

            this.dataMatrix.add(["year", [1989, 1990, 1991, 1992]], ["fish", [1, 2, 3, 4]]);
            same(this.dataMatrix.maxDataValue(), 2, "data in non-active ordinal dimension have no effect");            
        });

});
