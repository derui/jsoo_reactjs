open Mocha_of_ocaml
module R = Jsoo_reactjs
open Snap_shot_it_of_ocaml

let () =
  "ppx tool" >::: [
    "can create element via ppx extension" >:: (fun () ->
        let module C = R.Component.Make_stateless(struct
            class type t = object end
          end)
        in
        let t = C.make (fun _ -> [%e span ["text"]]) in
        let renderer = new%js R.Test_renderer.shallow_ctor in
        renderer##render (R.create_element t);
        let output = renderer##getRenderOutput in
        snapshot(output);
        assert_ok true
      );

    "should be able to set class name as props" >:: (fun () ->
        let module C = R.Component.Make_stateless(struct
            class type t = object end
          end)
        in
        let t = C.make (fun _ -> [%e span ~key:"span" ~class_name:"foo" ["text"]]) in
        let renderer = new%js R.Test_renderer.shallow_ctor in
        renderer##render (R.create_element t);
        let output = renderer##getRenderOutput in
        snapshot(output);
        assert_ok true
      );
    "should be able to nest primitive elements" >:: (fun () ->
        let module C = R.Component.Make_stateless(struct
            class type t = object end
          end)
        in
        let t = C.make (fun _ -> [%e span ~class_name:"span"
                           [[%e a ~class_name:"a" ["text"]]]]) in
        let renderer = new%js R.Test_renderer.shallow_ctor in
        renderer##render (R.create_element t);
        let output = renderer##getRenderOutput in
        snapshot(output);
        assert_ok true
      );
    "should be able to create custom component" >:: (fun () ->
        let module C = R.Component.Make_stateless(struct
            class type t = object
              method sample: string Js.readonly_prop
            end
          end)
        in
        let t = C.make (fun props -> [%e span ~class_name:"span"
                           [[%e a ~class_name:"a" [props##.sample [@txt]]]]]) in
        let renderer = new%js R.Test_renderer.shallow_ctor in
        renderer##render [%c t ~sample:"foo"];
        let output = renderer##getRenderOutput in
        snapshot(output);
        assert_ok true
      )
  ]
