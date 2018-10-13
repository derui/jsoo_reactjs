(** type of class name *)
type class_name = string

(** type of callback for enter *)
type enter_callback = Dom_html.element Js.t -> unit

(** type of callback for exit *)
type exit_callback = Dom_html.element Js.t -> unit

val css_transition :
  ?key:string
  -> ?on_enter:enter_callback
  -> ?on_entering:enter_callback
  -> ?on_entered:enter_callback
  -> ?on_exit:exit_callback
  -> ?on_exiting:exit_callback
  -> ?on_exited:exit_callback
  -> _in:bool
  -> timeout:int
  -> class_name:class_name
  -> (Js.js_string Js.t -> Jsoo_reactjs.Core.React.element Js.t)
  -> Jsoo_reactjs.Core.React.element Js.t
(** [css_transition ~_in ~timeout ~class_names children] returns React element applied transition.
    All callbacks of CSSTransition provided are optional, so use labeled argument if you want use it.
*)
