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

module type Custom = sig
  type t
end

module type Stateless = sig
  type props
  type renderer = props Js.t -> Rjs_core.React.element Js.t
  val make : renderer -> (props, unit, unit) Rjs_core.React.component
end

module Make_stateless(P: Prop) : Stateless with type props = P.t

module type Stateful = sig
  type props
  type state
  type spec = (props, state, unit) Rjs_core.Component_spec.t

  val make : spec -> (props, state, unit) Rjs_core.React.component
end

module Make_stateful(P:Prop)(S:State) : Stateful
  with type props = P.t and type state = S.t

module type Stateful_custom = sig
  type props
  type state
  type custom
  type spec = (props, state, custom) Rjs_core.Component_spec.t

  val make : spec -> (props, state, custom) Rjs_core.React.component
end

module Make_stateful_custom(P:Prop)(S:State)(C:Custom) : Stateful_custom
  with type props = P.t and type state = S.t and type custom = C.t
