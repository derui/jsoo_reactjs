
let create_event: constr:string -> typ:string -> prop:< .. > Js.t Js.optdef -> Dom_html.event Js.t = fun ~constr ~typ ~prop ->
  let constr = Js.string constr in
  let event = Js.Unsafe.get Js.Unsafe.global constr in
  let typ = Js.string typ in
  Js.Unsafe.new_obj event [|Js.Unsafe.inject typ; Js.Unsafe.inject prop|]

let dispatch_event : element:Dom_html.element Js.t -> ev:Dom_html.event Js.t -> unit =
  fun ~element ~ev ->
  Js.Unsafe.meth_call element "dispatchEvent" [|Js.Unsafe.inject ev|]
