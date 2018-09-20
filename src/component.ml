module type Props = sig
  type t
end

let make_stateless (type p) ~props:(_ : (module Props with type t = p)) ~render :
    (p, unit, unit) Core.React.component =
  Core.create_stateless_component render

let make_stateful (type p s c) ~props:(_ : (module Props with type t = p))
    ~(spec : (p, s, c) Core.Component_spec.t) : (p, s, c) Core.React.component =
  Core.create_stateful_component spec
