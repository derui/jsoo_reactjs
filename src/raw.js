
function _createClass(React, spec) {

  return class extends React.Component {
    constructor(props) {
      super(props);

      if (spec.constructor) {
        spec.constructor.call(this, props);
      }

      if (spec.initialState) {
        this.state = spec.initialState.call(this, props);
      }

      if (spec.initialCustom) {
        this.custom = spec.initialCustom.call(this, props);
      }
    }

    componentWillMount() {
      if (spec.componentWillMount) {
        spec.componentWillMount.call(this);
      }
    }

    componentDidMount() {
      if (spec.componentDidMount) {
        spec.componentDidMount.call(this);
      }
    }

    render() {
      if (spec.render) {
        return spec.render.call(this);
      }

      throw new Error("render function must define in component spec");
    }

    componentWillReceiveProps(nextProps) {
      if (spec.componentWillReceiveProps) {
        spec.componentWillReceiveProps.call(this, nextProps);
      }
    }

    shouldComponentUpdate(newProps, newState) {
      if (spec.shouldComponentUpdate) {
        return spec.shouldComponentUpdate.call(this, newProps, newState);
      }
      return true;
    }

    componentWillUpdate(nextProps, nextState) {
      if (spec.componentWillUpdate) {
        spec.componentWillUpdate.call(this, nextProps, nextState);
      }
    }

    componentDidUpdate(prevProps, prevState) {
      if (spec.componentDidUpdate) {
        spec.componentDidUpdate.call(this, prevProps, prevState);
      }
    }

    componentWillUnmount() {
      if (spec.componentWillUnmount) {
        spec.componentWillUnmount.call(this);
      }
    }
  }
}
