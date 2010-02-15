/* Tuftee is a fluid tool for exploration between different datasets */

// helper maybe and default macros.  It's questionable how much better they make things
//We'll keep them around for the time being and see if they are actually resuable
var maybe_t = function(compare_func, default_value) {
    return function(cond_var, value_func) {
        return ( compare_func(cond_var) ) ? default_value : value_func();
    };
};
maybe_t.zero = maybe_t(function(x) { return (x === 0); }, 0);
maybe_t.inf = maybe_t(function(x) { return (x == -Infinity || x == Infinity); }, 100);
    
// transmorgify isn't being used as well as zeroify.  it's a generalization of nullify
var transify_t = function(default_value) {
    return function (test_value) {
        return function(x) {
            return ( x === test_value ) ? default_value : x;
        };
    };
};
transify_t.zeroify = transify_t(0)(0);
transify_t.nanify = transify_t("nan")(null);
transify_t.noneify = transify_t("none")(null);

var nullify_t = function(test_value) {
    return function(x) {
        return ( x === test_value ) ? null : x;
    };
};
nullify_t.nan = nullify_t("nan");
nullify_t.none = nullify_t("none");

var Tuftee = 
(function() {
    var T = window.tf = function(dom_id, width, height) {
        return new T.fn.init(dom_id, width, height);
    };
    
    // a filter function for every nth element
    var every_t = function(number, default_value) {
        return function(index, block_func, binding) {
            if ( (index % number) === 0 ) {
                return block_func.call(binding || this, index);
            } else {
                return default_value;
            }
        };
    };
    var every_five = every_t(5, "");
    
    T.fn = T.prototype = {
        // Constructor to create the instance object's inner members
        init: function(dom_id, width, height, options) {
            var inst = this;
            
            // Things that stay the same and initialized
            this.dom_id = dom_id;
            this.canvasWidth = width || 620;
            this.canvasHeight = height || 400;
            
            this.axisWidth = 40;
            this.axisHeight = 20;
            this.bandRatio = 0.9;
            
            // Things that change when updating graph    
            this.vis = new pv.Panel(dom_id)
                .width(this.canvasWidth)
                .height(this.canvasHeight)
                .bottom(this.axisHeight)
                .left(this.axisWidth)
                .right(5)
                .top(5);
            
            this.xlabel = null;
            
            this.legend = new T.Legend("ordinal", "cardinal");
            this.dataMatrix = new T.DataMatrix();
            
            this.clear();
            
            return this;
        },
        
        byBar: function() {
            // need to use instance because "this" refers to the panel instead of Tuftee
            // and we need both in the callbacks.
            var inst = this;
            
            var bar = this.vis.add(pv.Panel)
                  .data(function() { 
                      return inst.dataMatrix.matrix();
                  })
                  .left(function() { 
                      return inst.xAxis(this.index); 
                  })
                .add(pv.Bar)
                  .data(function(a) {
                      return a; 
                  })
                  .left(function() { 
                      var numDatasets = inst.dataMatrix.numDatasets();
                      var mark = this;
                      return maybe_t.zero(numDatasets, function() {
                          return mark.index * inst.xAxis.range().band / numDatasets;
                      });
                  })
                  .width(function() { 
                      var numDatasets = inst.dataMatrix.numDatasets();
                      return ( numDatasets === 0 ) ? inst.canvasWidth : inst.xAxis.range().band / numDatasets;
                  })
                  .bottom(0)
                  .height(function(d) { 
                      var maxDataValue = inst.dataMatrix.maxDataValue();
                      return maybe_t.inf(d, function() {
                          return 0.95 * d * (inst.canvasHeight / maxDataValue);
                      });
                  })
                  .fillStyle(pv.Colors.category20().by(pv.index));
            
            bar.anchor("top").add(pv.Label)
                .textStyle("#777")
                .textBaseline("bottom")
                .text(function(l) { 
                    return every_five(this.parent.index, function(i) { 
                        return l || "";
                    }, this);
                });
            
            this.xlabels = this.vis.add(pv.Label)
                .data(function() {
                    return pv.range(inst.dataMatrix.maxDataLength());
                })
                .bottom(0)
                .left(function() { 
                    return inst.xAxis(this.index) + inst.xAxis.range().band / 2;
                })
                .textMargin(5)
                .textBaseline("top")
                .textStyle("#000")
                .textAlign("center")
                .text(function() { 
                    return inst.dataMatrix.activeOrdinalValues()[this.index]; 
                });
            
            this.vis.add(pv.Rule)
                .data(function() { 
                    return inst.yAxis.ticks(); 
                })
                .bottom(function(d) { 
                    return Math.round(inst.yAxis(d)) - 0.5; 
                })
                .strokeStyle("rgba(240, 240, 240, 0.8)")
              .add(pv.Rule)
                .left(0)
                .width(5)
                .strokeStyle("#000")
                .anchor("left")
              .add(pv.Label);
            
            return this;
        },
        
        // can enable or disable for debugging
        render: function(enable) {
            enable = (_.isUndefined(enable)) ? true : enable;
            this.legend.update("ordinal", this.dataMatrix);
            this.legend.update("cardinal", this.dataMatrix);
            
            this.xAxis = pv.Scale.ordinal(this.dataMatrix.activeOrdinalValues())
                           .splitBanded(0, this.canvasWidth, this.bandRatio);
            this.yAxis = pv.Scale.linear(0, 1.05 * this.dataMatrix.maxDataValue() || 10)
                           .range(0, this.canvasHeight);
            
            this._adjustXaxis();
            
            (enable === true) ? this.vis.render() : this.debugging();
            
            return this;
        },
        
        debugging: function() {
            console.log("xAxis");
            console.log(this.xAxis.range());
            console.log(this.xAxis.range().band);
            
            console.log("yAxis");
            console.log(this.yAxis.range());
            
            console.log("dataMatrix's matrix");
            console.log(this.dataMatrix.matrix());
            console.log("numDatasets: " + this.dataMatrix.numDatasets());
            console.log("maxDataValue: " + this.dataMatrix.maxDataValue());
            console.log("maxDataLength: " + this.dataMatrix.maxDataLength());
            
            return this;
        },
         
        /* for now, link key additions is separate from adding datasets */
        addLinkKeys: function(ordinalKeys, cardinalKey) {
            _.each(ordinalKeys, function(linkKey) {
                this.dataMatrix.addLinkKey(linkKey, cardinalKey);
            }, this);
            return this;
        },
        
        /* remove all link keys of a cardinal dataset */
        removeLinkKeys: function(cardinalKey) {
            this.dataMatrix.removeLinkKey(cardinalKey);
            return this;
        },
        
        /* adds a cardinal/ordinal dataset pair.
         * each datapack is just the label and the data in an array
         *
         *   ["oil", [1,2,3,4]]
         */
        add: function(ordinalDatapack, cardinalDatapack) {
            var result = this.dataMatrix.add(ordinalDatapack, cardinalDatapack);
            if ( result === false )
                throw("Could not add duplicate datapack");
            return this;
        },
        
        remove: function(cardinalKey) {
            this.dataMatrix.removeCardinal(cardinalKey);
            return this;
        },
        
        clear: function() {
            this.dataMatrix.clear();
            this.legend.clearLabels();
            return this;
        },

        /* We want to adjust the labels at the time of render 
         * rotate the xaxis labels if there's too many xaxis
         */
        _adjustXaxis: function() {
            // for now, we hard code it at 10 bars before we rotate
            if ( this.dataMatrix.maxDataLength() < 10 ) {
                this.axisHeight = 40;
                this.xlabels
                    .textAlign("center")
                    .textAngle(0)
                    .textBaseline("top");
                this.vis.bottom(this.axisHeight);
            } else {
                this.axisHeight = 100;
                var labelWidth = 10;
                var barWidth = this.axisWidth / this.dataMatrix.maxDataLength();
                var labelAngle = Math.acos(barWidth / labelWidth);
                
                this.xlabels
                    .textAlign("left")
                    .textAngle(labelAngle)
                    .textBaseline("center");
                this.vis.bottom(this.axisHeight);
            }
        }
        
    };
    
    /* Makes the init function's prototype the same as Tuftee's prototype,
      So when we instanciate T.fn.init, the correct public methods are attached */
    T.fn.init.prototype = T.fn;

    /* UI helper functions */
    
    // There will only ever be one legend, so we won't use prototype objects
    // and just use private vars
    // TODO depends on hardcoded location of cancel icon
    T.Legend = function(ord_id, card_id) {
        var ordinal_id = ord_id;
        var cardinal_id = card_id;
        
        this.cardinalView = function(dimKey) {
            var html = ["<li id=\"", T.Dimension.toHtmlId(dimKey), "\">"];
            html = html.concat(["<a href='' data-remote='false' ", 
                                "onclick=\"deactivateGraph('", dimKey, "')\">",
                                T.Dimension.toName(dimKey), "</a>"]);
            html = html.concat(["<a href='' data-remote='false' ", 
                                "onclick=\"removeGraph('", dimKey, "')\">",
                                "<image src='/images/icons/cancel_16.png' /></a>"]);
            html.push("</li>");
            return html.join("");
        };
        
        this.ordinalView = function(axisLabel, dimKeys) {
            var html = ["<li id=\"", axisLabel, "\">"];
            html = html.concat(["<a href='' data-remote='false' ",
                                "onclick=\"changeOrdinal('" + axisLabel + "', ['" + dimKeys.join("','") + "'])\">", 
                                axisLabel, "</a>"]);
            html = html.concat(["</li>"]);
            return html.join("");
        };
        
        this.clearLabels = function() {
            $("ul#" + cardinal_id).html("");
            $("ul#" + ordinal_id).html("");
            return true;
        };
        
        this.update = function(axis, dataMatrix) {
            if ( axis == "ordinal" ) {
                $("ul#ordinal").html("");
                var ordinalLinkKeys = dataMatrix.ordinalLinkKeys();
                _.each(ordinalLinkKeys, function(ordinalLinkKey) {
                           var cardinalLinkKeys = dataMatrix.cardinalLinkKeysOf(ordinalLinkKey);
                           var view = this.ordinalView(ordinalLinkKey, cardinalLinkKeys);
                           $("ul#" + ordinal_id).append(view);
                       }, this);
            } else {
                $("ul#cardinal").html("");
                var cardinalLinkKeys = dataMatrix.cardinalKeys();
                _.each(cardinalLinkKeys, function(cardinalLinkKey) {
                           var view = this.cardinalView(cardinalLinkKey);
                           $("ul#" + cardinal_id).append(view);
                       }, this);
            }
            return true;
        };
        
    };
    
    T.Dimension = function(dimension) { };
    T.Dimension.transformer = function(replacement) {
        return function(dimKey) {
            return dimKey.replace(/[\|`]/g, replacement);
        };
    };
    T.Dimension.toHtmlId = function(dimKey) {
        return T.Dimension.transformer("_")(dimKey);
    };
    T.Dimension.toName = function(dimKey) {
        return T.Dimension.transformer(" ")(dimKey);
    };
    
    /* Stores the matrix of datasets that are currently visualized */
    T.DataMatrix = function() {
        /* datasets of records for each axis 
         * { year: { 1991: { oil: 1, whale: 2 },
         *           1992: { oil: 2, whale: 3 }},
         *   state:{ illinois: { oil: 1, whale: 3 },
         *           california: { oil: 2 } } } */
        this.recordsets = {};
        
        /* The connections between dataset name to ordinal names 
         *
         * { oil: { year: true, state: false },
         *   whale: { year: true }
         *
         * When true, it notes that recordsets has already saved data for that 
         * ordinal/cardinal combination.  If it's false, it just means that 
         * we know there are other ordinal axis to request, 
         */
        this.axisGraph = {};
        
        // The active unique dimesion of the recordsets that we can use 
        // as a primary key between records
        this.activeOrdinal = null;
        
    };
    
    T.DataMatrix.prototype = {
        /* sets the active unique dimension */
        activateOrdinal: function(dimension_key) {
            this.activeOrdinal = dimension_key;
            return true;
        },
        
        // adds ordinal/cardinal key pair that link them to each other
        addLinkKey: function(ordinalKey, cardinalKey) {
            if ( !(cardinalKey in this.axisGraph) )
                this.axisGraph[cardinalKey] = {};
            
            // avoid overwriting any key that already exists.
            // we set it to false, because there's no data for this cardinal/ordinal
            // key combination yet.
            if ( !(ordinalKey in this.axisGraph[cardinalKey]) )
                this.axisGraph[cardinalKey][ordinalKey] = false;
            
            return true;
        },
        
        // removes an ordinal/cardinal key pair
        removeLinkKey: function(cardinalKey) {
            if ( !(cardinalKey in this.axisGraph) )
                return false;
            
            delete this.axisGraph[cardinalKey];
            return true;
        },
        
        /* adds a dataset, where cardinal is the cardinal name and values
         *
         *   add(["year", [1990, 1991, 1992]], ["oil", [1,2,3]]) 
         * 
         * if there had been no active primary dimension
         */
        add: function(ordinalDatapack, cardinalDatapack) {
            var cardinalKey = cardinalDatapack[0], 
                cardinalData = cardinalDatapack[1],
                ordinalKey = ordinalDatapack[0],
                ordinalData = ordinalDatapack[1];
            
            if (cardinalData.length != ordinalData.length)
                throw("Cardinal and ordinal data lengths differs: " + cardinalData + " : " + ordinalData);
            var dataLength = cardinalData.length;
            
            if ( this.hasDataset(ordinalKey, cardinalKey) )
                return false;
            
            if ( _.isNull(this.activeOrdinal) ) 
                this.activateOrdinal(ordinalKey);
            
            // populate data in recordsets
            Object.begat(this.recordsets, ordinalKey, function(recordset) {
                for (var i = 0; i < dataLength; i++) {
                    Object.begat(recordset, ordinalData[i], 
                                 Object.n(cardinalKey, cardinalData[i]));
                };
                return recordset; 
            });
            
            // record this ordinal/cardinal pair as being loaded.
            Object.begat(this.axisGraph, cardinalKey, Object.n(ordinalKey, true));
            
            return true;
        },
        
        removeCardinal: function(cardinalKey) {
            _.each(this.ordinalKeys(), function(ordinalKey) {
                this.remove(ordinalKey, cardinalKey);
            }, this);
            return true;
        },
        
        remove: function(ordinalKey, cardinalKey) {
            if ( !this.hasDataset(ordinalKey, cardinalKey) )
                return false;
            
            // remove all cardinal dimensions in recordsets
            _(this.recordsets[ordinalKey]).chain()
                .values()
                .each(function(r) {
                    delete r[cardinalKey];
                }).values();
            
            // remove all ordinal dimensions in axisgraph for the cardinal key
            delete this.axisGraph[cardinalKey][ordinalKey];
            if ( _.isEmpty(this.axisGraph[cardinalKey]) )
                delete this.axisGraph[cardinalKey];
            
            return true;
        },
        
        clear: function() {
            this.recordsets = {};
            this.axisGraph = {};
            this.activeOrdinal = null;
            return true;
        },
        
        /* gives us the activeRecordset */
        activeRecordset: function() {
            return this.recordsets[this.activeOrdinal];
        },
        
        /* does the datamatrix have the dataset already? */
        hasDataset: function(ordinalKey, cardinalKey) {
            return (cardinalKey in this.axisGraph && ordinalKey in this.axisGraph[cardinalKey]);
        },
        
        /* all the ordinal keys in the dataMatrix (removal) */
        ordinalKeys: function() {
            return _.keys(this.recordsets);
        },
        
        /* all the cardinal keys in the dataMatrix (matrix render and legend update) */
        cardinalKeys: function() {
            return _.keys(this.axisGraph);
         },
         
        /* returns all ordinal keys in the axisGraph.  These include those that don't 
         * yet have data.  This is for the ordinal labels so we can traverse to the  
         * same dataset, but different xaxis */
        ordinalLinkKeys: function() {
            return _(this.axisGraph).chain()
                .values()
                .reduce({}, function(t, e) { return _.extend(t, e); })
                .keys()
                .value();
        },

        /* returns the cardinal key given an ordinal key */
        cardinalLinkKeysOf: function(ordinalKey) {
            return _(Object.to_a(this.axisGraph)).chain()
                .select(function(keylist) { 
                    return _.include(_.keys(keylist[1]), ordinalKey); 
                })
                .map(function(keylist) { return keylist[0] })
                .value();
        },
        
        /* returns all ordinal values of the active Ordinal dimension (render xaxis) */
        activeOrdinalValues: function() {
            return _.keys(this.activeRecordset() || {});
        },
        
        // returns the number of datasets
        numDatasets: function() {
            return _(this.axisGraph).chain()
                .values()
                .map(function(axises) {
                    return _.filter(Object.to_a(axises), function(pair) { 
                        return pair[1];
                    }).length;
                })
                .reduce(0, function(t, e) { return t += e; })
                .value();
        },
        
        // returns the maximum length of a dataset
        maxDataLength: function() {
            return _.keys(this.activeRecordset()).length
        },
         
        // returns the maximum value in all active cardinal values (matrix)
        maxDataValue: function() {
            return matrixMax(this.matrix());
        },
        
        /* convert internal composite data stucture of the cardinal values of the 
         * dataset into an array of arrays, so it can be used by client code 
         * currently, it doesn't pad for gaps in year.
         *
         * By nomenclature, this is the same as activeCardinalValues
         * 
         */
        matrix: function() {
            if ( _.isEmpty(this.recordsets) )
                return [[]];
            
            // the function in map converts an object with padded nulls
            // if the key doesn't exist in this particular record.
            var to_padded_array = function(record) { 
                return _(this.cardinalKeys()).chain()
                    .map(function(key) {
                        return record[key] || null;
                    })
                    .map(function(d) { 
                        if (_.isString(d))
                            d = d.toLowerCase();
                        return nullify_t.none(nullify_t.nan(d));
                    }, this)
                    .value();
            };
            
            return _(this.activeRecordset()).chain()
                .values(_.identity)
                .map(to_padded_array, this)
                .value();
        }
    };
    // mixin Observer pattern in datamatrix
    // _(T.DataMatrix.prototype).extend(Observer);
    
    /* private calculation helper functions */
    var matrixMax = function(matrix) {
        return pv.max(_.map(matrix, function(arr) { 
            return pv.max(arr); 
        }));
    };
    
    // John Resig's Array remove
    Array.remove = function(array, from, to) {
        var rest = array.slice((to || from) + 1 || array.length);
        array.length = from < 0 ? array.length + from : from;
        return array.push.apply(array, rest);
    };
    
    Array.to_a = function(hash) {
        var array = [];
        for (var dimKey in hash) {
            array.push(Array.clone(hash[dimKey]));
        };
        return array;
    };
    
    Array.clone = function(array) {
        var cloned_array = [];
        for (var i in array) {
            cloned_array.push(array[i]);
        }
        return cloned_array;
    };
    
    /* Begat creates another child object for a given key.  If parentKey doesn't 
     * exist, it will create the key with the child object as the value.  If it 
     * does exist, it will extend the value with the object. If it's a 
     */
    Object.begat = function(hash, parentKey, child) {
        if ( _.isFunction(child) ) {
            // Should hash[parentKey] be cloned first before passing it in?
            hash[parentKey] = child.call(hash, hash[parentKey] || {});
        } else {
            hash[parentKey] = _.extend(hash[parentKey] || {}, child);
        }
        return hash;
    };
    
    Object.n = function(key, value) {
        var obj = {};
        obj[key] = value;
        return obj;
    };
    
    Object.to_a = function(object) {
        return _.zip(_.keys(object), _.values(object));
    };
    
    // return the Tuftee object to assign to global library name
    return T;
})();
