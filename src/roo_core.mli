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

  class type element_spec = object
    method key: Js.js_string Js.t Js.optdef_prop
    method className: Js.js_string Js.t Js.optdef_prop
  end

end

(* The module providing component spec to be able to create component via React API.
   Some of fields are optional and omit if you do not need their.
*)
module Component_spec : sig
  type ('props, 'state) t = {
    initialize : (('props, 'state) React.stateful_component Js.t -> unit) option;
    render : ('props, 'state) React.stateful_component Js.t -> unit;
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
      (('props, 'state) React.stateful_component Js.t -> bool) option;
    component_will_update :
      (('props, 'state) React.stateful_component Js.t -> 'props -> 'state -> bool)
        option;
    component_did_update :
      (('props, 'state) React.stateful_component Js.t -> 'props -> 'state -> bool)
        option;
  }
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

val create_element : ?props:'a -> ?children:React.element Js.t array ->
  ('a, 'b) React.component -> React.element Js.t
(* Create element with component *)
val create_dom_element: ?props:React.element_spec Js.t -> ?children:React.element Js.t array ->
  string -> React.element Js.t
(* Create element with tag *)

val text: string -> React.element Js.t
(* Create element for text node *)

val dom : Dom.dom Js.t
(* Re-binding for convinience *)
