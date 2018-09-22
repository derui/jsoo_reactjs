(* The module providing ReactDOM API as easy as possible. *)
module Dom : sig
  class type dom =
    object
      method render : Core.React.element Js.t -> Dom_html.element Js.t -> unit Js.meth

      method unmountComponentAtNode : Dom_html.element Js.t -> unit Js.meth
    end

  val t : dom Js.t
end = struct
  (* Not provide findDOMNode function now. *)
  class type dom =
    object
      method render : Core.React.element Js.t -> Dom_html.element Js.t -> unit Js.meth

      method unmountComponentAtNode : Dom_html.element Js.t -> unit Js.meth
    end

  let t : dom Js.t = Js.Unsafe.js_expr "require('react-dom')"
end

(* Export ReactDOM API *)
let dom = Dom.t
