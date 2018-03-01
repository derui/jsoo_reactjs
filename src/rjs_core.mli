(* the module for low-level binding for React *)
module React : sig
  type element
  class type defined_props = object
    method children: element Js.t Js.js_array Js.t Js.readonly_prop
  end

  class type ['props, 'state] stateful_component =
    object
      method props : 'props Js.readonly_prop
      method props_defined: defined_props Js.t Js.readonly_prop
      method setState : 'state -> unit Js.meth
      method state : 'state Js.prop
      method nodes : Dom_html.element Js.t Jstable.t Js.prop
    end

  type ('props, 'state) component

end

module E = Jsoo_reactjs_event

module Element_spec : sig
  type 'a t = {
    key: string option;
    class_name: string option;
    on_key_down: (E.Keyboard_event.t -> unit) option;
    on_key_press: (E.Keyboard_event.t -> unit) option;
    on_key_up: (E.Keyboard_event.t -> unit) option;
    on_input: (E.Input_event.t -> unit) option;
    value: string option;
    others: (< .. > as 'a) Js.t option;
  }

  val empty: 'a t
end

(* The module providing component spec to be able to create component via React API.
   Some of fields are optional and omit if you do not need their.
*)
module Component_spec : sig
  type ('props, 'state) t = {
    initialize : (('props Js.t, 'state Js.t) React.stateful_component Js.t -> 'props Js.t -> unit) option;
    render : ('props Js.t, 'state Js.t) React.stateful_component Js.t -> React.element Js.t;
    should_component_update :
      (('props Js.t, 'state Js.t) React.stateful_component Js.t -> 'props Js.t -> 'state Js.t -> bool)
        option;
    component_will_receive_props :
      (('props Js.t, 'state Js.t) React.stateful_component Js.t -> 'props Js.t -> unit) option;
    component_will_mount :
      (('props Js.t, 'state Js.t) React.stateful_component Js.t -> unit) option;
    component_will_unmount :
      (('props Js.t, 'state Js.t) React.stateful_component Js.t -> unit) option;
    component_did_mount :
      (('props Js.t, 'state Js.t) React.stateful_component Js.t -> unit) option;
    component_will_update :
      (('props Js.t, 'state Js.t) React.stateful_component Js.t -> 'props Js.t -> 'state Js.t -> unit)
        option;
    component_did_update :
      (('props Js.t, 'state Js.t) React.stateful_component Js.t -> 'props Js.t -> 'state Js.t -> unit)
        option;
  }

  val empty: ('props, 'state) t
end

(** Create stateful component with spec *)
val create_stateful_component : ('p, 's) Component_spec.t -> ('p, 's) React.component

(** Create stateless component with renderer *)
val create_stateless_component : ('p Js.t -> React.element Js.t) -> ('p, unit) React.component

(** Create element with component *)
val create_element : ?key:string ->
  ?props:(< .. > as 'a) Js.t -> ?children:React.element Js.t array ->
  ('a, 'b) React.component -> React.element Js.t

(** Create element with tag *)
val create_dom_element: ?key:string ->
  ?_ref:(Dom_html.element Js.t -> unit) ->
  ?props:'a Element_spec.t -> ?children:React.element Js.t array ->
  string -> React.element Js.t

(** Create Fragment component to wrap empty dom *)
val fragment: ?key:string -> React.element Js.t array -> React.element Js.t

(** Create element for text node *)
val text: string -> React.element Js.t

(** Create empty element when you want not to create any element. *)
val empty: unit -> React.element Js.t
