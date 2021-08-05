// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var React = require("react");

function Header(Props) {
  var header = Props.header;
  var status = Props.status;
  var status$1 = React.createElement("div", {
        className: "agda-mode-header-status"
      }, status);
  switch (header.TAG | 0) {
    case /* Plain */0 :
        return React.createElement("div", {
                    className: "agda-mode-header"
                  }, header._0, status$1);
    case /* Success */1 :
        return React.createElement("div", {
                    className: "agda-mode-header success"
                  }, header._0, status$1);
    case /* Warning */2 :
        return React.createElement("div", {
                    className: "agda-mode-header warning"
                  }, header._0, status$1);
    case /* Error */3 :
        return React.createElement("div", {
                    className: "agda-mode-header error"
                  }, header._0, status$1);
    
  }
}

var make = Header;

exports.make = make;
/* react Not a pure module */