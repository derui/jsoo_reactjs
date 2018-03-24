
module Core = Rjs_core

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
  type renderer = props Js.t -> Core.React.element Js.t

  val make: renderer -> (props, unit, unit) Core.React.component
end

module Make_stateless(P:Prop) : Stateless with type props = P.t = struct
  type props = P.t
  type renderer = P.t Js.t -> Core.React.element Js.t

  let make renderer = Core.create_stateless_component renderer
end

module type Stateful = sig
  type props
  type state
  type spec = (props, state, unit) Core.Component_spec.t

  val make: spec -> (props, state, unit) Core.React.component
end

module Make_stateful(P:Prop)(S:State) : Stateful
  with type props = P.t
   and type state = S.t = struct
  type props = P.t
  type state = S.t
  type spec = (props, state, unit) Core.Component_spec.t

  let make spec = Core.create_stateful_component spec
end

module type Stateful_custom = sig
  type props
  type state
  type custom
  type spec = (props, state, custom) Core.Component_spec.t

  val make: spec -> (props, state, custom) Core.React.component
end

module Make_stateful_custom(P:Prop)(S:State)(C:Custom) : Stateful_custom
  with type props = P.t
   and type state = S.t
   and type custom = C.t = struct
  type props = P.t
  type state = S.t
  type custom = C.t
  type spec = (props, state, custom) Core.Component_spec.t

  let make spec = Core.create_stateful_component spec
end
