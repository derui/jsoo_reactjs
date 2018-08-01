open Mocha_of_ocaml
module R = Jsoo_reactjs
open Snap_shot_it_of_ocaml

let presenter =
  let module C = R.Component.Make_stateless(struct
        class type t = object
          method text: Js.js_string Js.t Js.readonly_prop
        end
      end) in
  C.make (fun prop ->
      R.create_dom_element "div" ~children:[R.text @@ Js.to_string prop##.text]
    )

let nesting =
  let module C = R.Component.Make_stateless(struct
        class type t = object
          method list: Js.js_string Js.t Js.js_array Js.t Js.readonly_prop
        end
      end) in
  C.make (fun prop ->
      let children = Js.array_map (fun t -> R.create_element ~key:(Js.to_string t) ~props:(object%js
                                  val text = t
                                end) presenter)
          prop##.list
                     |> Js.to_array
                     |> Array.to_list
      in
      R.create_dom_element "div" ~children
    )

let () =
  "React test util" >::: [
    "should be able to shallow rendering" >:: (fun () ->
        let renderer = new%js R.Test_renderer.shallow_ctor in
        renderer##render (R.create_element ~props:(object%js
                            val text = Js.string "shallow"
                          end) presenter);
        let output = renderer##getRenderOutput in
        snapshot(output);
        assert_ok true
      );

    "should render only one-deep" >:: (fun () ->
        let renderer = new%js R.Test_renderer.shallow_ctor in
        let array = [|"foo";"bar";"baz"|] in
        renderer##render (R.create_element ~props:(object%js
                            val list = Js.array @@ Array.map Js.string array
                          end) nesting);
        let output = renderer##getRenderOutput in
        snapshot(output);
        assert_ok true
      )
  ]
