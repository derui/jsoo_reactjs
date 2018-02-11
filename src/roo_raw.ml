(* The raw source to create react component with extending React.Component,
   therefore js_of_ocaml can not handling syntax after ES2015.
   This source converted from babel with env preset.
*)
let react_create_class_raw = {|
(function () {
"use strict";

var _createClass2 = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

  return function (React, spec) {

    return function (_React$Component) {
      _inherits(_class, _React$Component);

      function _class(props) {
        _classCallCheck(this, _class);

        var _this = _possibleConstructorReturn(this, (_class.__proto__ || Object.getPrototypeOf(_class)).call(this, props));

        if (spec.constructor) {
          spec.constructor.call(_this, props);
        }
        return _this;
      }

      _createClass2(_class, [{
        key: "componentWillMount",
        value: function componentWillMount() {
          if (spec.componentWillMount) {
            spec.componentWillMount.call(this);
          }
        }
      }, {
        key: "componentDidMount",
        value: function componentDidMount() {
          if (spec.componentDidMount) {
            spec.componentDidMount.call(this);
          }
        }
      }, {
        key: "render",
        value: function render() {
          if (spec.render) {
            return spec.render.call(this);
          }

          throw new Error("render function must define in component spec");
        }
      }, {
        key: "componentWillReceiveProps",
        value: function componentWillReceiveProps(nextProps) {
          if (spec.componentWillReceiveProps) {
            spec.componentWillReceiveProps.call(this, nextProps);
          }
        }
      }, {
        key: "shouldComponentUpdate",
        value: function shouldComponentUpdate(newProps, newState) {
          if (spec.shouldComponentUpdate) {
            return spec.shouldComponentUpdate.call(this, newProps, newState);
          }
          return true;
        }
      }, {
        key: "componentWillUpdate",
        value: function componentWillUpdate(nextProps, nextState) {
          if (spec.componentWillUpdate) {
            spec.componentWillUpdate.call(this, nextProps, nextState);
          }
        }
      }, {
        key: "componentDidUpdate",
        value: function componentDidUpdate(prevProps, prevState) {
          if (spec.componentDidUpdate) {
            spec.componentDidUpdate.call(this, prevProps, prevState);
          }
        }
      }, {
        key: "componentWillUnmount",
        value: function componentWillUnmount() {
          if (spec.componentWillUnmount) {
            spec.componentWillUnmount.call(this);
          }
        }
      }]);

      return _class;
    }(React.Component);
  };
})
|}
