
module C = Roo_core

module type Prop = sig
  type t
end

module type State = sig
  type t
end

module type Stateless = sig
  type props
  type renderer = props Js.t -> C.React.element Js.t

  val make: renderer -> (props, unit) C.React.component
end

module Make_stateless(P:Prop) : Stateless with type props = P.t = struct
  type props = P.t
  type renderer = P.t Js.t -> C.React.element Js.t

  let make renderer = C.create_stateless_component renderer
end

module type Stateful = sig
  type props
  type state
  type spec = (props, state) C.Component_spec.t

  val make: spec -> (props, state) C.React.component
end

module Make_stateful(P:Prop)(S:State) : Stateful
  with type props = P.t
   and type state = S.t = struct
  type props = P.t
  type state = S.t
  type spec = (props, state) C.Component_spec.t

  let make spec = C.create_stateful_component spec
end
