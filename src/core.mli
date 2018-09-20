(* the module for low-level binding for React *)
module React : sig
  type element
  type children
  type ref_

  class type defined_props =
    object
      method children : children Js.t Js.readonly_prop
    end

  class type ['props, 'state, 'custom] stateful_component =
    object
      method props : 'props Js.readonly_prop

      method props_defined : defined_props Js.t Js.readonly_prop

      method setState : 'state -> unit Js.meth

      method state : 'state Js.prop

      method custom : 'custom Js.prop
    end

  type ('props, 'state, 'custom) component
end

module Children : sig
  val map :
    f:(React.element Js.t -> React.element Js.t)
    -> React.children Js.t
    -> React.element Js.t list option
  (** A binding of React.Children.map to be friendly for OCaml *)

  val iter : f:(React.element Js.t -> unit) -> React.children Js.t -> unit
  (** A binding of React.Children.forEach to be friendly for OCaml *)

  val count : React.children Js.t -> int
  (** A binding of React.Children.count *)

  val only : React.children Js.t -> React.element Js.t option
  (** A binding of React.Children.only to be friendly for OCaml *)

  val to_list : React.children Js.t -> React.element Js.t list
  (** A binding of React.Children.toArray to be friendly for OCaml *)

  val to_element : React.children Js.t -> React.element Js.t
  (** Convert children to element to be able to pass argument as create_element *)
end

(** A module mapped Refs in API of React.js . *)
module Ref : sig
  val create : unit -> React.ref_ Js.t
  (** [create ()] maps [React.createRef()]. *)

  val current : React.ref_ Js.t -> Dom_html.element Js.t option
  (** [current ref_] maps [ref_.current]. But this API forces to handle undefined by user. *)
end

module E = Jsoo_reactjs_event

type ('a, 'element) element_spec constraint 'a = < .. >

val element_spec :
  ?key:string
  -> ?class_name:string
  -> ?on_key_down:('element E.Keyboard_event.t -> unit)
  -> ?on_key_press:('element E.Keyboard_event.t -> unit)
  -> ?on_key_up:('element E.Keyboard_event.t -> unit)
  -> ?on_change:('element E.Input_event.t -> unit)
  -> ?on_input:('element E.Input_event.t -> unit)
  -> ?on_scroll:('element E.Scroll_event.t -> unit)
  -> ?on_focus:('element E.Focus_event.t -> unit)
  -> ?on_blur:('element E.Focus_event.t -> unit)
  -> ?default_value:string
  -> ?others:(< .. > as 'a) Js.t
  -> unit
  -> ('a, 'element) element_spec

(* The module providing component spec to be able to create component via React API.
   Some of fields are optional and omit if you do not need their.
*)
module Component_spec : sig
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

  type ('props, 'state, 'custom) t
end

val component_spec :
  ?constructor:('props, 'state, 'custom) Component_spec.constructor
  -> ?initial_state:('props, 'state, 'custom) Component_spec.initial_state
  -> ?initial_custom:('props, 'state, 'custom) Component_spec.initial_custom
  -> ?should_component_update:( 'props
                              , 'state
                              , 'custom
                              , bool )
    Component_spec.component_update_handler
  -> ?component_will_receive_props:( 'props
                                   , 'state
                                   , 'custom )
    Component_spec.component_will_receive_props
  -> ?component_will_mount:('props, 'state, 'custom) Component_spec.lifecycle_handler
  -> ?component_will_unmount:('props, 'state, 'custom) Component_spec.lifecycle_handler
  -> ?component_did_mount:('props, 'state, 'custom) Component_spec.lifecycle_handler
  -> ?component_will_update:('props, 'state, 'custom, unit) Component_spec.component_update_handler
  -> ?component_did_update:('props, 'state, 'custom, unit) Component_spec.component_update_handler
  -> ('props, 'state, 'custom) Component_spec.render
  -> ('props, 'state, 'custom) Component_spec.t
(** Define component spec with React.js handler functions. *)

val create_stateful_component : ('p, 's, 'c) Component_spec.t -> ('p, 's, 'c) React.component
(** Create stateful component with spec *)

val create_stateless_component :
  ('p Js.t -> React.element Js.t) -> ('p, unit, unit) React.component
(** Create stateless component with renderer *)

val create_element :
  ?key:string
  -> ?_ref:React.ref_ Js.t Js.optdef
  -> ?props:(< .. > as 'a) Js.t
  -> ?children:React.element Js.t list
  -> ('a, 'b, _) React.component
  -> React.element Js.t
(** Create element with component.*)

type 'a tag

val tag_of_string : string -> 'a tag
(** convert string to tag *)

val create_dom_element :
  ?key:string
  -> ?_ref:React.ref_ Js.t Js.optdef
  -> ?props:('a, 'element) element_spec
  -> ?children:React.element Js.t list
  -> 'element tag
  -> React.element Js.t
(** Create element with tag *)

val fragment : ?key:string -> React.element Js.t list -> React.element Js.t
(** Create Fragment component to wrap empty dom *)

val text : string -> React.element Js.t
(** Create element for text node *)

val empty : unit -> React.element Js.t
(** Create empty element when you want not to create any element. *)
