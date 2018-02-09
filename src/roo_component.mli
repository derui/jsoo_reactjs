(* This module provides helper modules to create component as module.

   Usage:

   // Create stateless component
   module M = Make_stateless(struct
   class type _t = object
     method name: Js.js_string Js.t Js.readonly_prop
   end
   type t = _t Js.t
   end)

   let renderer prop = Dom.of_tag `span ~children:[|Core.text (prop##.name)|]
   let component = M.make renderer
*)

module type Prop = sig
  type t
end

module type State = sig
  type t
end

module type Stateless = sig
  type props
  type renderer = props Js.t -> Roo_core.React.element Js.t
  val make : renderer -> (props, unit) Roo_core.React.component
end

module Make_stateless(P: Prop) : Stateless with type props = P.t

module type Stateful = sig
  type props
  type state
  type spec = (props, state) Roo_core.Component_spec.t

  val make : spec -> (props, state) Roo_core.React.component
end

module Make_stateful(P:Prop)(S:State) : Stateful
  with type props = P.t and type state = S.t
