module Core = Rjs_core
module Dom = Rjs_dom
module Component = Rjs_component
module Test_util = Rjs_test_util
module Event = Jsoo_reactjs_event
module Ref_table = Rjs_ref_table
module Test_renderer = Rjs_test_renderer

(* re-binding useful functions *)
let dom = Dom.dom

include Core
