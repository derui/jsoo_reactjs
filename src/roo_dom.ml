module Core = Roo_core

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
  class type dom = object
    method render: Core.React.element Js.t -> Dom_html.element Js.t -> unit Js.meth
    method unmountComponentAtNode: Dom_html.element Js.t -> unit Js.meth
  end

  let t : dom Js.t = Js.Unsafe.pure_js_expr "require('react-dom')"
end

(* Export ReactDOM API *)
let dom = Dom.t

type tags = [
  | `span
  | `div
  | `ul
  | `li
  | `section
  | `header
  | `footer
  | `table
  | `tbody
  | `thead
  | `td
  | `th
  | `colgroup
  | `col
  | `tfoot
] [@@deriving variants]

let of_tag ?key ?_ref ?props ?(children=[||]) tag = Core.create_dom_element
    ?key ?_ref ?props ~children @@ Variants_of_tags.to_name tag
