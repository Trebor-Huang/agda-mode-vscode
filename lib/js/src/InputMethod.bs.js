// Generated by BUCKLESCRIPT, PLEASE EDIT WITH CARE
'use strict';

var Curry = require("bs-platform/lib/js/curry.js");
var Belt_List = require("bs-platform/lib/js/belt_List.js");
var Belt_Array = require("bs-platform/lib/js/belt_Array.js");
var Belt_Option = require("bs-platform/lib/js/belt_Option.js");
var Caml_option = require("bs-platform/lib/js/caml_option.js");
var Caml_primitive = require("bs-platform/lib/js/caml_primitive.js");
var Caml_chrome_debugger = require("bs-platform/lib/js/caml_chrome_debugger.js");
var Event$AgdaModeVscode = require("./Util/Event.bs.js");

function Impl(Editor) {
  var make = function (editor, offset) {
    var point = Curry._2(Editor.pointAtOffset, editor, offset);
    return {
            range: /* tuple */[
              offset,
              offset
            ],
            decoration: Curry._2(Editor.Decoration.underlineText, editor, Curry._2(Editor.$$Range.make, point, point))
          };
  };
  var withIn = function (instance, offset) {
    var match = instance.range;
    if (match[0] <= offset) {
      return offset <= match[1];
    } else {
      return false;
    }
  };
  var destroy = function (instance) {
    console.log("KILLED");
    return Belt_Array.forEach(instance.decoration, Editor.Decoration.destroy);
  };
  var Instance = {
    make: make,
    withIn: withIn,
    destroy: destroy
  };
  var insertBackslash = function (editor) {
    return Belt_Array.forEach(Curry._1(Editor.getCursorPositions, editor), (function (point) {
                  Curry._3(Editor.insertText, editor, point, "\\");
                  
                }));
  };
  var activate = function (self, editor, offsets) {
    self.instances = Belt_Array.map(offsets.sort(), (function (param) {
            return make(editor, param);
          }));
    var editorChangeHandle = {
      contents: undefined
    };
    var cursorChangeHandle = {
      contents: undefined
    };
    var checkIfEveryoneIsStillAlive = function (param) {
      if (self.instances.length === 0) {
        console.log("ALL DEAD");
        Curry._1(self.onAction.emit, /* Deactivate */1);
        Belt_Option.forEach(editorChangeHandle.contents, Editor.Disposable.dispose);
        return Belt_Option.forEach(cursorChangeHandle.contents, Editor.Disposable.dispose);
      }
      
    };
    var cursorChangelistener = function (points) {
      var offsets = Belt_Array.map(points, Curry._1(Editor.offsetAtPoint, editor));
      self.instances = Belt_Array.keep(self.instances, (function (instance) {
              var survived = Belt_Array.some(offsets, (function (param) {
                      return withIn(instance, param);
                    }));
              if (!survived) {
                destroy(instance);
              }
              return survived;
            }));
      return checkIfEveryoneIsStillAlive(undefined);
    };
    editorChangeHandle.contents = Caml_option.some(Curry._1(Editor.onChange, (function (changes) {
                checkIfEveryoneIsStillAlive(undefined);
                var changes$1 = changes.sort((function (x, y) {
                        return Caml_primitive.caml_int_compare(x.offset, y.offset);
                      }));
                var scan = function (_accum, _param) {
                  while(true) {
                    var param = _param;
                    var accum = _accum;
                    var match = param[0];
                    if (match) {
                      var match$1 = param[1];
                      if (!match$1) {
                        return /* [] */0;
                      }
                      var is = match$1[1];
                      var instance = match$1[0];
                      var cs = match[1];
                      var change = match[0];
                      var match$2 = instance.range;
                      var end_ = match$2[1];
                      var start = match$2[0];
                      var delta = change.insertText.length - change.replaceLength | 0;
                      if (withIn(instance, change.offset)) {
                        instance.range = /* tuple */[
                          accum + start | 0,
                          (accum + end_ | 0) + delta | 0
                        ];
                        return /* :: */Caml_chrome_debugger.simpleVariant("::", [
                                  instance,
                                  scan(accum + delta | 0, /* tuple */[
                                        cs,
                                        is
                                      ])
                                ]);
                      }
                      if (change.offset < instance.range[0]) {
                        _param = /* tuple */[
                          cs,
                          /* :: */Caml_chrome_debugger.simpleVariant("::", [
                              instance,
                              is
                            ])
                        ];
                        _accum = accum + delta | 0;
                        continue ;
                      }
                      instance.range = /* tuple */[
                        accum + start | 0,
                        accum + end_ | 0
                      ];
                      return /* :: */Caml_chrome_debugger.simpleVariant("::", [
                                instance,
                                scan(accum, /* tuple */[
                                      /* :: */Caml_chrome_debugger.simpleVariant("::", [
                                          change,
                                          cs
                                        ]),
                                      is
                                    ])
                              ]);
                    }
                    var match$3 = param[1];
                    if (match$3) {
                      return /* :: */Caml_chrome_debugger.simpleVariant("::", [
                                match$3[0],
                                match$3[1]
                              ]);
                    } else {
                      return /* [] */0;
                    }
                  };
                };
                self.instances = Belt_List.toArray(scan(0, /* tuple */[
                          Belt_List.fromArray(changes$1),
                          Belt_List.fromArray(self.instances)
                        ]));
                
              })));
    cursorChangeHandle.contents = Caml_option.some(Curry._1(Editor.onChangeCursorPosition, cursorChangelistener));
    
  };
  var make$1 = function (param) {
    return {
            onAction: Event$AgdaModeVscode.make(undefined),
            instances: [],
            activated: false
          };
  };
  return {
          Instance: Instance,
          insertBackslash: insertBackslash,
          activate: activate,
          make: make$1
        };
}

exports.Impl = Impl;
/* Event-AgdaModeVscode Not a pure module */