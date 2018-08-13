
class type simulate = object
  method keyDown: Dom_html.element Js.t -> 'a Js.t Js.optdef -> unit Js.meth
  method input: Dom_html.element Js.t -> 'a Js.t Js.optdef -> unit Js.meth
  method change: Dom_html.element Js.t -> 'a Js.t Js.optdef -> unit Js.meth
  method focus: Dom_html.element Js.t -> 'a Js.t Js.optdef -> unit Js.meth
  method blur: Dom_html.element Js.t -> 'a Js.t Js.optdef -> unit Js.meth
end

class type t = object
  method _Simulate: simulate Js.t Js.readonly_prop
end

let instance : t Js.t = Js.Unsafe.pure_js_expr "require('react-dom/test-utils')"
