class type props = object
  method children: Rjs_core.React.element Js.t Js.js_array Js.t Js.readonly_prop
end

class type shallow = object
  method _type: Js.js_string Js.t Js.readonly_prop
  method props: props Js.t Js.readonly_prop
end

class type t = object
  method render: Rjs_core.React.element Js.t -> unit Js.meth
  method getRenderOutput: shallow Js.t Js.meth
end

let shallow_ctor : t Js.t Js.constr = Js.Unsafe.pure_js_expr "require('react-test-renderer/shallow')"
