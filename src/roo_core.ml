let require module_ : 'a Js.t =
  let require = Js.Unsafe.pure_js_expr "require" in
  let module_ = Js.string module_ in
  Js.Unsafe.(fun_call require [|inject module_|])

module Helper = struct
  module Option = struct
    let (>|=) v f = match v with
      | None -> None
      | Some v -> Some (f v)
  end
end

(* module that contains low-level bindings for Reactjs *)
module React = struct

  type element

  class type ['props, 'state] component = object
    method props: 'props Js.readonly_prop
    method state: 'state Js.prop
    method setState: 'state -> unit Js.meth
  end

  class type ['props, 'state] js_component_spec = object
    method constructor: ('props, 'state) component Js.t -> unit Js.meth Js.opt
    method componentWillMount: unit Js.meth Js.opt
    method componentDidMount: unit Js.meth Js.opt
    method render: element Js.meth
    method componentWillReceiveProps: 'props -> unit Js.meth Js.opt
    method shouldComponentUpdate: 'props -> 'state -> bool Js.t Js.meth Js.opt
    method componentWillUpdate: 'props -> 'state -> unit Js.meth Js.opt
    method componentDidUpdate: 'props -> 'state -> unit Js.meth Js.opt
    method componentWillUnmount: unit Js.meth Js.opt
  end

  class type react = object
    method createElement: (_, _) component Js.t -> element Js.t Js.meth
  end

  (* create component from spec. *)
  let t : react Js.t = require "react"

end

(* Providing type and function for spec of component created in OCaml *)
module Component_spec = struct
  type ('props, 'state) t = {
    initialize: (('props, 'state) React.component Js.t -> unit) option;
    render: ('props, 'state) React.component Js.t -> unit;
    should_component_update:
      (('props, 'state) React.component Js.t -> 'props -> 'state -> bool) option;
    component_will_receive_props: (('props, 'state) React.component Js.t -> 'props -> bool) option;
    component_will_mount: (('props, 'state) React.component Js.t -> unit) option;
    component_will_unmount: (('props, 'state) React.component Js.t -> unit) option;
    component_did_mount: (('props, 'state) React.component Js.t -> bool) option;
    component_will_update:
      (('props, 'state) React.component Js.t -> 'props -> 'state -> bool) option;
    component_did_update:
      (('props, 'state) React.component Js.t -> 'props -> 'state -> bool) option;
  }

  let to_js_spec spec =
    let open Helper.Option in 
    object%js
      val constructor = Js.Opt.option @@ (spec.initialize >|= Js.wrap_meth_callback)
      val render = Js.wrap_meth_callback spec.render
      val shouldComponentUpdate = Js.Opt.option @@ (
          spec.should_component_update >|=
          fun v -> Js.wrap_meth_callback @@ fun (this, props, state) -> v this props state)
      val componentWillUpdate = Js.Opt.option @@ (
          spec.component_will_update >|=
          fun v -> Js.wrap_meth_callback @@ fun (this, props, state) -> v this props state)
      val componentDidUpdate = Js.Opt.option @@ (
          spec.component_did_update >|=
          fun v -> Js.wrap_meth_callback @@ fun (this, props, state) -> v this props state)
      val componentWillReceiveProps = Js.Opt.option @@ (
          spec.component_will_receive_props >|=
          fun v -> Js.wrap_meth_callback @@ fun (this, props) -> v this props)

      val componentWillMount = Js.Opt.option @@ (spec.component_will_mount >|= Js.wrap_meth_callback)
      val componentWillUnmount = Js.Opt.option @@ (spec.component_will_unmount >|= Js.wrap_meth_callback)
      val componentDidMount = Js.Opt.option @@ (spec.component_did_mount >|= Js.wrap_meth_callback)
    end
end

(* Binding for react-dom module *)
module Dom = struct

  (* Not provide findDOMNode function now. *)
  class type dom = object
    method render: React.element Js.t -> Dom_html.element Js.t -> unit Js.meth
    method unmountComponentAtNode: Dom_html.element Js.t -> unit Js.meth
  end

  let t : dom Js.t = require "react-dom"
end

let _create_class_of_spec = Js.Unsafe.js_expr Roo_raw.react_create_class_raw

(* Create component from OCaml's component spec *)
let create_component : ('p, 's) Component_spec.t ->
  ('p, 's) React.component Js.t = fun spec ->
  let spec = Component_spec.to_js_spec spec in
  Js.Unsafe.(fun_call _create_class_of_spec [|inject React.t; inject spec|])

(* alias function for React.createElement *)
let create_element component = React.t##createElement component

(* Export ReactDOM API *)
let dom = Dom.t
