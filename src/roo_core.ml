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

  class type ['props, 'state] stateful_component = object
    method props: 'props Js.readonly_prop
    method state: 'state Js.prop
    method setState: 'state -> unit Js.meth
  end

  type ('props, 'state) component =
    | Stateful of ('props, 'state) stateful_component Js.t
    | Stateless of ('props -> element Js.t)

  class type ['props, 'state] js_component_spec = object
    method constructor: ('props, 'state) stateful_component Js.t -> unit Js.meth Js.opt
    method componentWillMount: unit Js.meth Js.opt
    method componentDidMount: unit Js.meth Js.opt
    method render: element Js.meth
    method componentWillReceiveProps: 'props -> unit Js.meth Js.opt
    method shouldComponentUpdate: 'props -> 'state -> bool Js.t Js.meth Js.opt
    method componentWillUpdate: 'props -> 'state -> unit Js.meth Js.opt
    method componentDidUpdate: 'props -> 'state -> unit Js.meth Js.opt
    method componentWillUnmount: unit Js.meth Js.opt
  end

  class type element_spec = object
    method key: Js.js_string Js.t Js.optdef_prop
    method className: Js.js_string Js.t Js.optdef_prop
  end

  class type react = object
    method createElement_stateful: ('a, _) stateful_component Js.t -> 'a Js.opt ->
      element Js.t Js.js_array Js.t -> element Js.t Js.meth
    method createElement_stateless: ('a -> element Js.t) -> 'a Js.opt ->
      element Js.t Js.js_array Js.t -> element Js.t Js.meth
    method createElement_tag: Js.js_string Js.t -> element_spec Js.t Js.opt ->
      element Js.t Js.js_array Js.t -> element Js.t Js.meth
  end

  (* create component from spec. *)
  let t : react Js.t = Js.Unsafe.pure_js_expr "require('react')"

end

(* Providing type and function for spec of component created in OCaml *)
module Component_spec = struct
  type ('props, 'state) t = {
    initialize: (('props, 'state) React.stateful_component Js.t -> unit) option;
    render: ('props, 'state) React.stateful_component Js.t -> React.element Js.t;
    should_component_update:
      (('props, 'state) React.stateful_component Js.t -> 'props -> 'state -> bool) option;
    component_will_receive_props: (('props, 'state) React.stateful_component Js.t -> 'props -> bool) option;
    component_will_mount: (('props, 'state) React.stateful_component Js.t -> unit) option;
    component_will_unmount: (('props, 'state) React.stateful_component Js.t -> unit) option;
    component_did_mount: (('props, 'state) React.stateful_component Js.t -> bool) option;
    component_will_update:
      (('props, 'state) React.stateful_component Js.t -> 'props -> 'state -> bool) option;
    component_did_update:
      (('props, 'state) React.stateful_component Js.t -> 'props -> 'state -> bool) option;
  }

  let empty = {
    initialize = None;
    render = (fun _ -> Obj.magic Js.null);
    should_component_update = None;
    component_will_receive_props = None;
    component_will_mount = None;
    component_will_unmount = None;
    component_did_mount = None;
    component_will_update = None;
    component_did_update = None
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

  let t : dom Js.t = Js.Unsafe.pure_js_expr "require('react-dom')"
end

let _create_class_of_spec =
  let f = Js.Unsafe.js_expr Roo_raw.react_create_class_raw in
  Js.Unsafe.fun_call f [||]

(* Create component from OCaml's component spec *)
let create_stateful_component : ('p, 's) Component_spec.t ->
  ('p, 's) React.component = fun spec ->
  let spec = Component_spec.to_js_spec spec in
  React.Stateful (Js.Unsafe.(fun_call _create_class_of_spec [|inject React.t; inject spec|]))

let create_stateless_component : ('p -> React.element Js.t) ->
  ('p, unit) React.component = fun spec ->
  (* NOTE: ReactJS with functional component will check passed function to
     ReactDOM.render, so we can not wrap a ocaml function that will call in React.
  *)
  React.Stateless spec

(* alias function for React.createElement *)
let create_element ?props ?children component =
  let props = Js.Opt.option props in
  let children = match children with
    | None -> Js.array [||]
    | Some v -> Js.array v
  in
  match component with
  | React.Stateful component -> React.t##createElement_stateful component props children
  | React.Stateless component -> React.t##createElement_stateless component props children

let create_dom_element ?props ?children tag =
  let tag = Js.string tag in
  let props = Js.Opt.option props in
  let children = match children with
    | None -> Js.array [||]
    | Some v -> Js.array v
  in
  React.t##createElement_tag tag props children

let text v = Obj.magic @@ Js.string v

(* Export ReactDOM API *)
let dom = Dom.t
