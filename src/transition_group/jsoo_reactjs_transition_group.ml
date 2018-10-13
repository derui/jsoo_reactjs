module R = Jsoo_reactjs

type class_name = string
type enter_callback = Dom_html.element Js.t -> unit
type exit_callback = Dom_html.element Js.t -> unit

module Css_transition = struct
  class type props =
    object
      method _in : bool Js.t Js.readonly_prop

      method timeout : int Js.readonly_prop

      method classNames : Js.js_string Js.t Js.readonly_prop

      method onEnter : enter_callback Js.callback Js.optdef Js.readonly_prop

      method onEntering : enter_callback Js.callback Js.optdef Js.readonly_prop

      method onEntered : enter_callback Js.callback Js.optdef Js.readonly_prop

      method onExit : exit_callback Js.callback Js.optdef Js.readonly_prop

      method onExiting : exit_callback Js.callback Js.optdef Js.readonly_prop

      method onExited : exit_callback Js.callback Js.optdef Js.readonly_prop
    end

  type t = props Js.t Jsoo_reactjs.Core.React.native_component Js.t
end

let css_transition : Css_transition.t =
  Js.Unsafe.js_expr "require('react-transition-group/CSSTransition')"

let css_transition ?key ?on_enter ?on_entering ?on_entered ?on_exit ?on_exiting ?on_exited ~_in
    ~timeout ~class_name renderer =
  let flip f x y = f y x in
  let props =
    object%js
      val _in = Js.bool _in

      val timeout = timeout

      val classNames = Js.string class_name

      val onEnter = Js.Optdef.option on_enter |> flip Js.Optdef.map Js.wrap_callback

      val onEntering = Js.Optdef.option on_entering |> flip Js.Optdef.map Js.wrap_callback

      val onEntered = Js.Optdef.option on_entered |> flip Js.Optdef.map Js.wrap_callback

      val onExit = Js.Optdef.option on_exit |> flip Js.Optdef.map Js.wrap_callback

      val onExiting = Js.Optdef.option on_exiting |> flip Js.Optdef.map Js.wrap_callback

      val onExited = Js.Optdef.option on_exited |> flip Js.Optdef.map Js.wrap_callback
    end
  in
  let renderer' state _ : R.React.element Js.t = renderer state in
  Jsoo_reactjs.create_native_element ?key ~props ~children:[R.wrap2 renderer'] css_transition
