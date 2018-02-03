module Helper = struct
  module Option = struct
    let (>|=) v f = match v with
      | None -> None
      | Some v -> Some (f v)
  end

  module Js_object = struct
    let assign : (< .. > as 'a) Js.t -> (< .. > as 'b) Js.t -> (< .. > as 'c) Js.t = fun dest source ->
      Js.Unsafe.(meth_call (global##._Object) "assign" [|inject dest;inject source|])

    let copy : (< .. > as 'a) Js.t -> 'a Js.t = fun obj ->
      let newobj = Js.Unsafe.(meth_call global##._Object "create" [|inject Js.null|]) in
      assign newobj obj
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

  class type react = object
    method createElement_stateful: ('a, _) stateful_component Js.t -> 'a Js.opt ->
      element Js.t Js.js_array Js.t -> element Js.t Js.meth
    method createElement_stateless: ('a -> element Js.t) -> 'a Js.opt ->
      element Js.t Js.js_array Js.t -> element Js.t Js.meth
    method createElement_tag: Js.js_string Js.t -> 'a Js.opt ->
      element Js.t Js.js_array Js.t -> element Js.t Js.meth
  end

  (* create component from spec. *)
  let t : react Js.t = Js.Unsafe.pure_js_expr "require('react')"

end

module E = Reactjscaml_event

module Element_spec = struct
  type 'a t = {
    key: string option;
    class_name: string option;
    on_key_down: (E.Keyboard_event.t -> unit) option;
    on_key_press: (E.Keyboard_event.t -> unit) option;
    on_key_up: (E.Keyboard_event.t -> unit) option;
    others: (< .. > as 'a) Js.t option;
  }

  let empty = {
    key = None;
    class_name = None;
    on_key_down = None;
    on_key_press = None;
    on_key_up = None;
    others = None;
  }

  let to_js t =
    let wrap_func f = match f with
      | None -> Js.Optdef.empty
      | Some f -> Js.Optdef.return (Js.wrap_callback f) in

    object%js
      val key = let key = Js.Optdef.option t.key in
        Js.Optdef.map key Js.string
      val className = let class_name = Js.Optdef.option t.class_name in
        Js.Optdef.map class_name Js.string
      val onKeyDown = wrap_func t.on_key_down
      val onKeyPress = wrap_func t.on_key_press
      val onKeyUp = wrap_func t.on_key_up
      val others = Js.Optdef.option t.others
    end
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
    component_did_mount: (('props, 'state) React.stateful_component Js.t -> unit) option;
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
          fun v -> Js.wrap_meth_callback @@ fun this props state -> v this props state)
      val componentWillUpdate = Js.Opt.option @@ (
          spec.component_will_update >|=
          fun v -> Js.wrap_meth_callback @@ fun this props state -> v this props state)
      val componentDidUpdate = Js.Opt.option @@ (
          spec.component_did_update >|=
          fun v -> Js.wrap_meth_callback @@ fun this props state -> v this props state)
      val componentWillReceiveProps = Js.Opt.option @@ (
          spec.component_will_receive_props >|=
          fun v -> Js.wrap_meth_callback @@ fun this props -> v this props)

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
let create_element : ?key:string -> ?props:(< .. > as 'a) Js.t -> ?children:React.element Js.t array ->
  ('a Js.t, 'b) React.component -> React.element Js.t = fun ?key ?props ?children component ->
  let open Helper.Option in
  let common_props = object%js
    val key = let key = Js.Optdef.option key in Js.Optdef.map key Js.string
  end in
  let props = match props with
    | None ->
      (* Forcely convert type to send key prop to React without type error *)
      Js.Opt.return (Js.Unsafe.coerce common_props : 'a Js.t)
    | Some props ->
      let copied_props = Helper.Js_object.copy props in
      Helper.Js_object.assign copied_props common_props |> Js.Opt.return
  in
  let children = match children with
    | None -> Js.array [||]
    | Some v -> Js.array v
  in
  match component with
  | React.Stateful component -> React.t##createElement_stateful component props children
  | React.Stateless component -> React.t##createElement_stateless component props children


module StringSet = Set.Make(struct
    type t = string
    let compare = Pervasives.compare
  end)

let merge_other_keys js =
  match Js.Optdef.to_option js##.others with
  | None -> js
  | Some others -> begin
      let merge_keys = Js.object_keys others |> Js.to_array |> Array.map Js.to_string
                       |> Array.to_list
      and defined_props = Js.object_keys js |> Js.to_array |> Array.map Js.to_string
                          |> Array.to_list |> List.filter (fun v -> v <> "others") in
      let merge_key_set = StringSet.of_list merge_keys
      and defined_prop_set = StringSet.of_list defined_props in
      let diff_keys = StringSet.(diff merge_key_set defined_prop_set |> elements) in
      let diff_keys = List.map Js.string diff_keys |> Array.of_list in

      Array.iter (fun key ->
          let v = Js.Unsafe.get others key in
          Js.Unsafe.set js key v
        ) diff_keys;
      Js.Unsafe.delete js (Js.string "others");
      js
    end

let create_dom_element ?key ?props ?children tag =
  let tag = Js.string tag in
  let common_props =
    object%js
      val key = let key = Js.Optdef.option key in Js.Optdef.map key Js.string
    end
  in
  let props = match props with
    | None -> Js.Opt.return common_props
    | Some props -> let js = Element_spec.to_js props in
      let js = merge_other_keys js in
      let copied_props = Helper.Js_object.copy js in
      Helper.Js_object.assign copied_props common_props
      |> Js.Opt.return
  in
  let children = match children with
    | None -> Js.array [||]
    | Some v -> Js.array v
  in
  React.t##createElement_tag tag props children

let text v = Obj.magic @@ Js.string v

(* Export ReactDOM API *)
let dom = Dom.t
