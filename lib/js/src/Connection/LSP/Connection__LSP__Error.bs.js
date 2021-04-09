// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Json = require("@glennsl/bs-json/lib/js/src/Json.bs.js");
var Curry = require("bs-platform/lib/js/curry.js");
var Belt_Option = require("bs-platform/lib/js/belt_Option.js");
var Json_decode = require("@glennsl/bs-json/lib/js/src/Json_decode.bs.js");
var Util$AgdaModeVscode = require("../../Util/Util.bs.js");
var Parser$AgdaModeVscode = require("../../Parser.bs.js");
var Process$AgdaModeVscode = require("../../Process.bs.js");

function toString(x) {
  if (x.TAG === /* CannotDecodeJSON */0) {
    return "Cannot decode JSON: \n" + x._0;
  } else {
    return "Cannot read IOTCM: \n" + x._0;
  }
}

var decode = Util$AgdaModeVscode.Decode.sum(function (x) {
      switch (x) {
        case "CmdErrCannotDecodeJSON" :
            return {
                    TAG: 0,
                    _0: (function (param) {
                        return Json_decode.map((function (version) {
                                      return {
                                              TAG: 0,
                                              _0: version,
                                              [Symbol.for("name")]: "CannotDecodeJSON"
                                            };
                                    }), Json_decode.string, param);
                      }),
                    [Symbol.for("name")]: "Contents"
                  };
        case "CmdErrCannotParseCommand" :
            return {
                    TAG: 0,
                    _0: (function (param) {
                        return Json_decode.map((function (version) {
                                      return {
                                              TAG: 1,
                                              _0: version,
                                              [Symbol.for("name")]: "CannotParseCommand"
                                            };
                                    }), Json_decode.string, param);
                      }),
                    [Symbol.for("name")]: "Contents"
                  };
        default:
          throw {
                RE_EXN_ID: Json_decode.DecodeError,
                _1: "[LSP.CommandErr] Unknown constructor: " + x,
                Error: new Error()
              };
      }
    });

var CommandErr = {
  toString: toString,
  decode: decode
};

function toString$1(error) {
  if (typeof error === "number") {
    return [
            "[LSP] Cannot Initialize Connection",
            ""
          ];
  }
  switch (error.TAG | 0) {
    case /* PathSearch */0 :
        return Curry._1(Process$AgdaModeVscode.PathSearch.$$Error.toString, error._0);
    case /* PortSearch */1 :
        return [
                "Cannot connect with the dev server on port " + String(error._0),
                "Did you forget to enter \":main -d\" in ghci?\n" + Util$AgdaModeVscode.JsError.toString(error._1)
              ];
    case /* Connection */2 :
        var exn = error._0;
        var isECONNREFUSED = Belt_Option.mapWithDefault(exn.message, false, (function (param) {
                return param.startsWith("connect ECONNREFUSED");
              }));
        if (isECONNREFUSED) {
          return [
                  "[LSP] Connection Error",
                  "Please enter \":main -d\" in ghci"
                ];
        } else {
          return [
                  "[LSP] Client Internal Connection Error",
                  Belt_Option.getWithDefault(exn.message, "")
                ];
        }
    case /* SendCommand */3 :
        return [
                "[LSP] Cannot Send Command",
                toString(error._0)
              ];
    case /* CannotDecodeCommandRes */4 :
        return [
                "[LSP] Cannot Send Command",
                "Cannot decode the result after sending command" + error._0 + "\n" + Json.stringify(error._1)
              ];
    case /* CannotDecodeResponse */5 :
        return [
                "[LSP] Cannot Parse Response",
                "Cannot decode responses from the server" + error._0 + "\n" + Json.stringify(error._1)
              ];
    case /* ResponseParseError */6 :
        return [
                "Internal Parse Error",
                Parser$AgdaModeVscode.$$Error.toString(error._0)
              ];
    
  }
}

exports.CommandErr = CommandErr;
exports.toString = toString$1;
/* decode Not a pure module */