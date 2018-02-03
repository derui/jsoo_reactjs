(* the module for low-level binding for React *)
module React : sig
  type element
  class type ['props, 'state] stateful_component =
    object
      method props : 'props Js.readonly_prop
      method setState : 'state -> unit Js.meth
      method state : 'state Js.prop
    end

  type ('props, 'state) component

end

module E = Reactjscaml_event

module Element_spec : sig
  type 'a t = {
    key: string option;
    class_name: string option;
    on_key_down: (E.Keyboard_event.t -> unit) option;
    on_key_press: (E.Keyboard_event.t -> unit) option;
    on_key_up: (E.Keyboard_event.t -> unit) option;
    others: (< .. > as 'a) Js.t option;
  }

  val empty: 'a t
end


(* The module providing component spec to be able to create component via React API.
   Some of fields are optional and omit if you do not need their.
*)
module Component_spec : sig
  type ('props, 'state) t = {
    initialize : (('props, 'state) React.stateful_component Js.t -> unit) option;
    render : ('props, 'state) React.stateful_component Js.t -> React.element Js.t;
    should_component_update :
      (('props, 'state) React.stateful_component Js.t -> 'props -> 'state -> bool)
        option;
    component_will_receive_props :
      (('props, 'state) React.stateful_component Js.t -> 'props -> bool) option;
    component_will_mount :
      (('props, 'state) React.stateful_component Js.t -> unit) option;
    component_will_unmount :
      (('props, 'state) React.stateful_component Js.t -> unit) option;
    component_did_mount :
      (('props, 'state) React.stateful_component Js.t -> unit) option;
    component_will_update :
      (('props, 'state) React.stateful_component Js.t -> 'props -> 'state -> bool)
        option;
    component_did_update :
      (('props, 'state) React.stateful_component Js.t -> 'props -> 'state -> bool)
        option;
  }

  val empty: ('props, 'state) t
end

(* The module providing ReactDOM API as easy as possible. *)
module Dom : sig
  class type dom =
    object
      method render : React.element Js.t -> Dom_html.element Js.t -> unit Js.meth
      method unmountComponentAtNode : Dom_html.element Js.t -> unit Js.meth
    end
  val t : dom Js.t
end

val create_stateful_component : ('p, 's) Component_spec.t -> ('p, 's) React.component
(* Create stateful component with spec *)

val create_stateless_component : ('p -> React.element Js.t) -> ('p, unit) React.component
(* Create stateless component with renderer *)

val create_element : ?key:string -> ?props:(< .. > as 'a) Js.t -> ?children:React.element Js.t array ->
  ('a Js.t, 'b) React.component -> React.element Js.t
(* Create element with component *)

val create_dom_element: ?key:string -> ?props:'a Element_spec.t -> ?children:React.element Js.t array ->
  string -> React.element Js.t
(* Create element with tag *)

val text: string -> React.element Js.t
(* Create element for text node *)

val dom : Dom.dom Js.t
(* Re-binding for convinience *)
