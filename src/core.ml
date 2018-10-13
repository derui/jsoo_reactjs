(* helper module helps to work easy with JavaScript's object *)
module Helper = struct
  module Option = struct
    let ( >|= ) v f = match v with None -> None | Some v -> Some (f v)
  end

  module Js_object = struct
    let assign : (< .. > as 'a) Js.t -> (< .. > as 'b) Js.t -> (< .. > as 'c) Js.t =
      fun dest source ->
        Js.Unsafe.(meth_call global##._Object "assign" [|inject dest; inject source|])

    let copy : (< .. > as 'a) Js.t -> 'a Js.t =
      fun obj ->
        let newobj = Js.Unsafe.(meth_call global##._Object "create" [|inject Js.null|]) in
        assign newobj obj
  end
end

(* module that contains low-level bindings for Reactjs *)
module React = struct
  type element
  type children

  (** binding for ref *)
  class type ref_ =
    object
      method current : Dom_html.element Js.t Js.optdef_prop
    end

  class type defined_props =
    object
      method children : children Js.t Js.readonly_prop
    end

  class type ['props, 'state, 'custom] stateful_component =
    object
      method props : 'props Js.readonly_prop

      method props_defined : defined_props Js.t Js.readonly_prop

      method state : 'state Js.prop

      method setState : 'state -> unit Js.meth

      method custom : 'custom Js.prop
    end

  type ('props, 'state, 'custom) component =
    | Stateful of ('props Js.t, 'state Js.t, 'custom Js.t) stateful_component Js.t
    | Stateless of ('props Js.t -> element Js.t)

  type 'props native_component

  module Fragment = struct
    class type props =
      object
        method key : Js.js_string Js.t Js.optdef Js.readonly_prop
      end

    type t = (props Js.t, unit, unit) stateful_component
  end

  (** binding for React.Children *)
  module Children = struct
    class type t =
      object
        method map :
          children Js.t
          -> (element Js.t, element Js.t) Js.meth_callback
          -> element Js.t Js.js_array Js.t Js.optdef Js.meth

        method forEach : children Js.t -> (element Js.t, unit) Js.meth_callback -> unit Js.meth

        method count : children Js.t -> int Js.meth

        method only : children Js.t -> element Js.t Js.meth

        method toArray : children Js.t -> element Js.t Js.js_array Js.t Js.meth
      end
  end

  class type react =
    object
      method createElement_stateful :
        ('a, _, _) stateful_component Js.t
        -> 'a Js.opt
        -> element Js.t Js.js_array Js.t Js.optdef
        -> element Js.t Js.meth

      method createElement_statefulWithChild :
        ('a, _, _) stateful_component Js.t
        -> 'a Js.opt
        -> element Js.t Js.optdef
        -> element Js.t Js.meth

      method createElement_stateless :
        ('a -> element Js.t)
        -> 'a Js.opt
        -> element Js.t Js.js_array Js.t Js.optdef
        -> element Js.t Js.meth

      method createElement_statelessWithChild :
        ('a -> element Js.t) -> 'a Js.opt -> element Js.t Js.optdef -> element Js.t Js.meth

      method createElement_tag :
        Js.js_string Js.t
        -> 'a Js.opt
        -> element Js.t Js.js_array Js.t Js.optdef
        -> element Js.t Js.meth

      method createElement_tagWithChild :
        Js.js_string Js.t -> 'a Js.opt -> element Js.t Js.optdef -> element Js.t Js.meth

      method createElement_component :
        'a native_component Js.t
        -> 'a Js.opt
        -> element Js.t Js.js_array Js.t Js.optdef
        -> element Js.t Js.meth

      method createElement_componentWithChild :
        'a native_component Js.t -> 'a Js.opt -> element Js.t Js.optdef -> element Js.t Js.meth

      method _Fragment : Fragment.t Js.t Js.readonly_prop

      method _Children : Children.t Js.t Js.readonly_prop

      method createRef : ref_ Js.t Js.meth
    end

  (* create component from spec. *)
  let t : react Js.t = Js.Unsafe.js_expr "require('react')"
end

(** binding for React.Children *)
module Children = struct
  let map ~f children =
    let c = React.t##._Children in
    let ret = c##map children Js.(wrap_meth_callback f) in
    Js.Optdef.map ret (fun v -> Js.to_array v |> Array.to_list) |> Js.Optdef.to_option

  let iter ~f children =
    let c = React.t##._Children in
    c##forEach children Js.(wrap_meth_callback f)

  let count children = React.t##._Children##count children
  let only children = try Some (React.t##._Children##only children) with Js.Error _ -> None

  let to_list children =
    let ary = React.t##._Children##toArray children in
    Js.to_array ary |> Array.to_list

  let to_element : React.children Js.t -> React.element Js.t =
    fun children -> Js.Unsafe.coerce children
end

module Ref = struct
  let create () = React.t##createRef
  let current r = Js.Optdef.to_option r##.current
end

module E = Jsoo_reactjs_event

module Element_spec = struct
  type ('a, 'element) t =
    { key : string option
    ; class_name : string option
    ; on_key_down : ('element E.Keyboard_event.t -> unit) option
    ; on_key_press : ('element E.Keyboard_event.t -> unit) option
    ; on_key_up : ('element E.Keyboard_event.t -> unit) option
    ; on_change : ('element E.Input_event.t -> unit) option
    ; on_input : ('element E.Input_event.t -> unit) option
    ; on_scroll : ('element E.Scroll_event.t -> unit) option
    ; on_focus : ('element E.Focus_event.t -> unit) option
    ; on_blur : ('element E.Focus_event.t -> unit) option
    ; default_value : string option
    ; others : (< .. > as 'a) Js.t option }

  let to_js t =
    let wrap_func f =
      match f with None -> Js.Optdef.empty | Some f -> Js.Optdef.return (Js.wrap_callback f)
    in
    object%js
      val key =
        let key = Js.Optdef.option t.key in
        Js.Optdef.map key Js.string

      val className =
        let class_name = Js.Optdef.option t.class_name in
        Js.Optdef.map class_name Js.string

      val onKeyDown = wrap_func t.on_key_down

      val onKeyPress = wrap_func t.on_key_press

      val onKeyUp = wrap_func t.on_key_up

      val onChange = wrap_func t.on_change

      val onInput = wrap_func t.on_input

      val onScroll = wrap_func t.on_scroll

      val onFocus = wrap_func t.on_focus

      val onBlur = wrap_func t.on_blur

      val defaultValue =
        let v = Js.Optdef.option t.default_value in
        Js.Optdef.map v Js.string

      val others = Js.Optdef.option t.others
    end
end

type ('a, 'element) element_spec = ('a, 'element) Element_spec.t

let element_spec ?key ?class_name ?on_key_down ?on_key_press ?on_key_up ?on_change ?on_input
    ?on_scroll ?on_focus ?on_blur ?default_value ?others () =
  Element_spec.
    { key
    ; class_name
    ; on_key_down
    ; on_key_press
    ; on_key_up
    ; on_change
    ; on_input
    ; on_scroll
    ; on_focus
    ; on_blur
    ; default_value
    ; others }

(* Providing type and function for spec of component created in OCaml *)
module Component_spec = struct
  type ('props, 'state, 'custom) constructor =
    ('props Js.t, 'state Js.t, 'custom Js.t) React.stateful_component Js.t -> 'props Js.t -> unit

  type ('props, 'state, 'custom) initial_custom =
    ('props Js.t, 'state Js.t, 'custom Js.t) React.stateful_component Js.t
    -> 'props Js.t
    -> 'custom Js.t

  type ('props, 'state, 'custom) initial_state =
    ('props Js.t, 'state Js.t, 'custom Js.t) React.stateful_component Js.t
    -> 'props Js.t
    -> 'state Js.t

  type ('props, 'state, 'custom) render =
    ('props Js.t, 'state Js.t, 'custom Js.t) React.stateful_component Js.t -> React.element Js.t

  type ('props, 'state, 'custom, 'result) component_update_handler =
    ('props Js.t, 'state Js.t, 'custom Js.t) React.stateful_component Js.t
    -> 'props Js.t
    -> 'state Js.t
    -> 'result

  type ('props, 'state, 'custom) component_will_receive_props =
    ('props Js.t, 'state Js.t, 'custom Js.t) React.stateful_component Js.t -> 'props Js.t -> unit

  type ('props, 'state, 'custom) lifecycle_handler =
    ('props Js.t, 'state Js.t, 'custom Js.t) React.stateful_component Js.t -> unit

  type ('props, 'state, 'custom) t =
    { constructor : ('props, 'state, 'custom) constructor option
    ; initial_state : ('props, 'state, 'custom) initial_state option
    ; initial_custom : ('props, 'state, 'custom) initial_custom option
    ; render : ('props, 'state, 'custom) render
    ; should_component_update : ('props, 'state, 'custom, bool) component_update_handler option
    ; component_will_receive_props : ('props, 'state, 'custom) component_will_receive_props option
    ; component_will_mount : ('props, 'state, 'custom) lifecycle_handler option
    ; component_will_unmount : ('props, 'state, 'custom) lifecycle_handler option
    ; component_did_mount : ('props, 'state, 'custom) lifecycle_handler option
    ; component_will_update : ('props, 'state, 'custom, unit) component_update_handler option
    ; component_did_update : ('props, 'state, 'custom, unit) component_update_handler option }

  let to_js_spec spec =
    let open Helper.Option in
    object%js
      val constructor = Js.Opt.option @@ (spec.constructor >|= Js.wrap_meth_callback)

      val initialState = Js.Opt.option @@ (spec.initial_state >|= Js.wrap_meth_callback)

      val initialCustom = Js.Opt.option @@ (spec.initial_custom >|= Js.wrap_meth_callback)

      val render = Js.wrap_meth_callback spec.render

      val shouldComponentUpdate =
        Js.Opt.option @@ (spec.should_component_update >|= Js.wrap_meth_callback)

      val componentWillUpdate =
        Js.Opt.option @@ (spec.component_will_update >|= Js.wrap_meth_callback)

      val componentDidUpdate =
        Js.Opt.option @@ (spec.component_did_update >|= Js.wrap_meth_callback)

      val componentWillReceiveProps =
        Js.Opt.option @@ (spec.component_will_receive_props >|= Js.wrap_meth_callback)

      val componentWillMount =
        Js.Opt.option @@ (spec.component_will_mount >|= Js.wrap_meth_callback)

      val componentWillUnmount =
        Js.Opt.option @@ (spec.component_will_unmount >|= Js.wrap_meth_callback)

      val componentDidMount = Js.Opt.option @@ (spec.component_did_mount >|= Js.wrap_meth_callback)
    end
end

let component_spec ?constructor ?initial_state ?initial_custom ?should_component_update
    ?component_will_receive_props ?component_will_mount ?component_will_unmount
    ?component_did_mount ?component_will_update ?component_did_update render =
  Component_spec.
    { constructor
    ; initial_state
    ; initial_custom
    ; should_component_update
    ; component_will_receive_props
    ; component_will_mount
    ; component_will_unmount
    ; component_did_mount
    ; component_will_update
    ; component_did_update
    ; render }

let _create_class_of_spec =
  let f = Js.Unsafe.js_expr Raw.react_create_class_raw in
  Js.Unsafe.fun_call f [||]

(* Create component from OCaml's component spec *)
let create_stateful_component spec =
  let spec = Component_spec.to_js_spec spec in
  React.Stateful Js.Unsafe.(fun_call _create_class_of_spec [|inject React.t; inject spec|])

let create_stateless_component spec =
  (* NOTE: ReactJS with functional component will check passed function to
     ReactDOM.render, so we can not wrap a ocaml function that will call in React.
  *)
  React.Stateless spec

(* alias function for React.createElement *)
let create_element ?key ?props ?(children = []) component =
  let common_props =
    object%js
      val key =
        let key = Js.Optdef.option key in
        Js.Optdef.map key Js.string
    end
  in
  let props =
    match props with
    | None ->
      (* Forcely convert type to send key prop to React without type error *)
      Js.Opt.return (Js.Unsafe.coerce common_props : 'a Js.t)
    | Some props ->
      let copied_props = Helper.Js_object.copy props in
      Helper.Js_object.assign copied_props common_props |> Js.Opt.return
  in
  match component with
  | React.Stateful component -> (
      match children with
      | [] -> React.t##createElement_stateful component props Js.Optdef.empty
      | [v] -> React.t##createElement_statefulWithChild component props (Js.Optdef.return v)
      | _ as v ->
        React.t##createElement_stateful component props
          (Js.Optdef.return @@ Js.array @@ Array.of_list v) )
  | React.Stateless component -> (
      match children with
      | [] -> React.t##createElement_stateless component props Js.Optdef.empty
      | [v] -> React.t##createElement_statelessWithChild component props (Js.Optdef.return v)
      | _ as v ->
        React.t##createElement_stateless component props
          (Js.Optdef.return @@ Js.array @@ Array.of_list v) )

module StringSet = Set.Make (struct
    type t = string

    let compare = Pervasives.compare
  end)

let merge_other_keys js =
  match Js.Optdef.to_option js##.others with
  | None -> js
  | Some others ->
    let merge_keys =
      Js.object_keys others |> Js.to_array |> Array.map Js.to_string |> Array.to_list
    and defined_props =
      Js.object_keys js
      |> Js.to_array
      |> Array.map Js.to_string
      |> Array.to_list
      |> List.filter (fun v -> v <> "others")
    in
    let merge_key_set = StringSet.of_list merge_keys
    and defined_prop_set = StringSet.of_list defined_props in
    let diff_keys = StringSet.(diff merge_key_set defined_prop_set |> elements) in
    let diff_keys = List.map Js.string diff_keys |> Array.of_list in
    Array.iter
      (fun key ->
         let v = Js.Unsafe.get others key in
         Js.Unsafe.set js key v )
      diff_keys ;
    Js.Unsafe.delete js (Js.string "others") ;
    js

type 'element tag = string

let tag_of_string v = v

let create_dom_element ?key ?_ref ?props ?(children = []) tag =
  let tag = Js.string tag in
  let common_props =
    object%js
      val key =
        let key = Js.Optdef.option key in
        Js.Optdef.map key Js.string

      val _ref = match _ref with None -> Js.undefined | Some v -> v
    end
  in
  let props =
    match props with
    | None -> Js.Opt.return common_props
    | Some props ->
      let js = Element_spec.to_js props in
      let js = merge_other_keys js in
      let copied_props = Helper.Js_object.copy js in
      Helper.Js_object.assign copied_props common_props |> Js.Opt.return
  in
  match children with
  | [] -> React.t##createElement_tag tag props Js.Optdef.empty
  | [v] -> React.t##createElement_tagWithChild tag props (Js.Optdef.return v)
  | _ as v -> React.t##createElement_tag tag props (Js.Optdef.return @@ Js.array @@ Array.of_list v)

let create_native_element ?key ?props ?(children = []) component =
  let common_props =
    object%js
      val key =
        let key = Js.Optdef.option key in
        Js.Optdef.map key Js.string
    end
  in
  let props =
    match props with
    | None -> Js.Unsafe.coerce common_props |> Js.Opt.return
    | Some props ->
      let copied_props = Helper.Js_object.copy props in
      Helper.Js_object.assign copied_props common_props |> Js.Opt.return
  in
  match children with
  | [] -> React.t##createElement_component component props Js.Optdef.empty
  | [v] -> React.t##createElement_componentWithChild component props (Js.Optdef.return v)
  | _ as v ->
    React.t##createElement_component component props
      (Array.of_list v |> Js.array |> Js.Optdef.return)

let fragment ?key children =
  let common_props =
    object%js
      val key =
        let key = Js.Optdef.option key in
        Js.Optdef.map key Js.string
    end
  in
  let children = Js.Optdef.return @@ Js.array @@ Array.of_list children in
  React.t##createElement_stateful React.t##._Fragment (Js.Opt.return common_props) children

let wrap f = Js.wrap_callback f |> Obj.magic
let wrap2 f = Js.wrap_callback f |> Obj.magic
let text v = Obj.magic @@ Js.string v
let empty () = Obj.magic @@ Js.null
