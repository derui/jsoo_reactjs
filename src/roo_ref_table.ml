(** The wrapper for Jstable *)

let add table ~key ~value = Jstable.add table (Js.string key) value
let keys table = Jstable.keys table |> List.map Js.to_string
let find table ~key = Jstable.find table (Js.string key) |> Js.Optdef.to_option
