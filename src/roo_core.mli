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

  module Event : sig
    class type synthetic_event = object
      method bubbles: bool Js.t Js.readonly_prop
      method cancelable: bool Js.t Js.readonly_prop
      method currentTarget: 'a Js.t Js.readonly_prop
      method defaultPrevented: bool Js.t Js.readonly_prop
      method eventPhase: Js.number Js.t Js.readonly_prop
      method isTrusted: bool Js.t Js.readonly_prop
      method nativeEvent: 'a Dom.event Js.t Js.readonly_prop
      method preventDefault: unit -> unit Js.meth
      method isDefaultPrevented: unit -> bool Js.t Js.meth
      method stopPropagation: unit -> unit Js.meth
      method isPropagationStopped: unit -> bool Js.t Js.meth
      method target: 'a Js.t Js.readonly_prop
      method timeStamp: Js.number Js.t Js.readonly_prop
      method _type: Js.js_string Js.t Js.readonly_prop
    end

    class type keyboard_event = object
      inherit synthetic_event

      method altKey: bool Js.t Js.readonly_prop
      method charCode: Js.number Js.t Js.readonly_prop
      method ctrlKey: bool Js.t Js.readonly_prop
      method getModifierState: Js.js_string Js.t -> bool Js.t Js.meth
      method key: Js.js_string Js.t Js.readonly_prop
      method keyCode: Js.number Js.t Js.readonly_prop
      method locale: Js.js_string Js.t Js.readonly_prop
      method location: Js.number Js.t Js.readonly_prop
      method metaKey: bool Js.t Js.readonly_prop
      method repeat: bool Js.t Js.readonly_prop
      method shiftKey: bool Js.t Js.readonly_prop
      method which: Js.number Js.t Js.readonly_prop
    end
  end

  module Element_spec : sig
    type t = {
      key: string option;
      class_name: string option;
      on_key_down: (Event.keyboard_event Js.t -> unit) option;
      on_key_press: (Event.keyboard_event Js.t -> unit) option;
      on_key_up: (Event.keyboard_event Js.t -> unit) option;
    }

    val empty: unit -> t

  end

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

val create_element : ?props:'a -> ?children:React.element Js.t array ->
  ('a, 'b) React.component -> React.element Js.t
(* Create element with component *)

val create_dom_element: ?props:React.Element_spec.t -> ?children:React.element Js.t array ->
  string -> React.element Js.t
(* Create element with tag *)

val text: string -> React.element Js.t
(* Create element for text node *)

val dom : Dom.dom Js.t
(* Re-binding for convinience *)
