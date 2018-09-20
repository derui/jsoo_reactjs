(** The wrapper for Jstable *)

type t = Core.React.ref_ Js.t Jstable.t

let create () = Jstable.create ()

let define ~key table =
  let value = Core.Ref.create () in
  Jstable.add table (Js.string key) value

let use ~key table = Jstable.find table (Js.string key)

let find ~key table =
  match Jstable.find table (Js.string key) |> Js.Optdef.to_option with
  | None -> None
  | Some r -> Core.Ref.current r
