(* the module for low-level binding for React *)
module React : sig
  type element
  class type ['props, 'state] component =
    object
      method props : 'props Js.readonly_prop
      method setState : 'state -> unit Js.meth
      method state : 'state Js.prop
    end

  class type react =
    object
      method createElement :
        ('a, 'b) component Js.t -> element Js.t Js.meth
    end
  val t : react Js.t
end

(* The module providing component spec to be able to create component via React API.
   Some of fields are optional and omit if you do not need their.
*)
module Component_spec : sig
  type ('props, 'state) t = {
    initialize : (('props, 'state) React.component Js.t -> unit) option;
    render : ('props, 'state) React.component Js.t -> unit;
    should_component_update :
      (('props, 'state) React.component Js.t -> 'props -> 'state -> bool)
        option;
    component_will_receive_props :
      (('props, 'state) React.component Js.t -> 'props -> bool) option;
    component_will_mount :
      (('props, 'state) React.component Js.t -> unit) option;
    component_will_unmount :
      (('props, 'state) React.component Js.t -> unit) option;
    component_did_mount :
      (('props, 'state) React.component Js.t -> bool) option;
    component_will_update :
      (('props, 'state) React.component Js.t -> 'props -> 'state -> bool)
        option;
    component_did_update :
      (('props, 'state) React.component Js.t -> 'props -> 'state -> bool)
        option;
  }
end

(* The module providing ReactDOM API as easy as possible. *)
module Dom : sig
  class type dom =
    object
      method render :
        React.element Js.t -> Dom_html.element Js.t -> unit Js.meth
      method unmountComponentAtNode : Dom_html.element Js.t -> unit Js.meth
    end
  val t : dom Js.t
end

val create_component :
  ('p, 's) Component_spec.t -> ('p, 's) React.component Js.t

val create_element : ('a, 'b) React.component Js.t -> React.element Js.t

(* Create element for text node *)
val text: string -> React.element Js.t

val dom : Dom.dom Js.t
