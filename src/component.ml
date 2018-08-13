
module type Props = sig
  type t
end

let make_stateless ~props:_ ~render = Core.create_stateless_component render

let make_stateful ~props:_ ~spec = Core.create_stateful_component spec

let make_stateful_with_custom ~props:_ ~spec = Core.create_stateful_component spec
