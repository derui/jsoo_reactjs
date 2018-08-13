open Mocha_of_ocaml
module R = Jsoo_reactjs
open Snap_shot_it_of_ocaml

let () =
  "ppx tool" >::: [
    "can create element via ppx extension" >:: (fun () ->
        let t = R.Component.make_stateless
            ~props:(module struct
                     class type t = object end
                   end)
            ~render:(fun _ -> [%e span ["text"]]) in
        let renderer = new%js R.Test_renderer.shallow_ctor in
        renderer##render (R.create_element t);
        let output = renderer##getRenderOutput in
        snapshot(output);
        assert_ok true
      );

    "should be able to set class name as props" >:: (fun () ->
        let t = R.Component.make_stateless
            ~props:(module struct
            class type t = object end
          end)
            ~render:(fun _ -> [%e span ~key:"span" ~class_name:"foo" ["text"]]) in
        let renderer = new%js R.Test_renderer.shallow_ctor in
        renderer##render (R.create_element t);
        let output = renderer##getRenderOutput in
        snapshot(output);
        assert_ok true
      );
    "should be able to nest primitive elements" >:: (fun () ->
        let t = R.Component.make_stateless
            ~props:(module struct
            class type t = object end
          end)
            ~render:(fun _ -> [%e span ~class_name:"span"
                    [[%e a ~class_name:"a" ["text"]]]]) in
        let renderer = new%js R.Test_renderer.shallow_ctor in
        renderer##render (R.create_element t);
        let output = renderer##getRenderOutput in
        snapshot(output);
        assert_ok true
      );
    "should be able to create custom component" >:: (fun () ->
        let t = R.Component.make_stateless
            ~props:(module struct
            class type t = object
              method sample: string Js.readonly_prop
            end
          end)
            ~render:(fun props -> [%e span ~class_name:"span"
                        [[%e a ~class_name:"a" [props##.sample [@txt]]]]]) in
        let renderer = new%js R.Test_renderer.shallow_ctor in
        renderer##render ([%c t ~props:(object%js val sample = "foo" end)]);
        let output = renderer##getRenderOutput in
        snapshot(output);
        assert_ok true
      );
    "should be able to use variable as children" >:: (fun () ->
        let t = R.Component.make_stateless
            ~props:(module struct
                     class type t = object
                       method sample: string Js.readonly_prop
                     end
                   end)
            ~render:(fun props ->
                let children = [R.text props##.sample] in
                [%e span ~class_name:"span" [[%e a ~class_name:"a" children]]]) in
        let renderer = new%js R.Test_renderer.shallow_ctor in
        renderer##render ([%c t ~props:(object%js val sample = "foo" end)]);
        let output = renderer##getRenderOutput in
        snapshot(output);
        assert_ok true
      );
  ]
