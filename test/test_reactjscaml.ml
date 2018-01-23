module R = Reactjscaml
open Mocha_of_ocaml

let prepare () =
  let div = Dom_html.createDiv Dom_html.document in
  div##setAttribute (Js.string "id") (Js.string "js");

  match Dom_html.getElementById_opt "test" with
  | Some v -> ignore @@ Dom.removeChild Dom_html.document v
  | None -> ();

    let body =
      let nl = Dom_html.document##getElementsByTagName (Js.string "body") in
      match nl##item 0 |> Js.Opt.to_option with
      | None -> failwith "Not found body tag"
      | Some v -> v
    in
    Dom.appendChild body div

let _ =
  "React element" >::: [
    "can create most simple text element" >:- (fun () ->
        prepare ();
        let span = R.Dom.of_tag `span ~children:[| R.text "foo" |] in
        let index = Dom_html.getElementById "js" in
        R.dom##render span index;

        let open Lwt.Infix in
        Lwt_js.sleep 0.0 >>= (fun () ->
            let option () = Js.string "" in
            let text = Js.Opt.get (index##.textContent) option |> Js.to_string in
            Lwt.return @@ assert_ok ("foo" = text)
          )
      );

    "can create original stateless component" >:- (fun () ->
        prepare ();
        let module M = R.Component.Make_stateless(struct
            class type _t = object
              method name: Js.js_string Js.t Js.readonly_prop
            end
            type t = _t Js.t
          end) in
        let component = M.make (fun props ->
            R.Dom.of_tag `span ~children:[|
              R.text @@ Js.to_string props##.name
            |]
          ) in
        let index = Dom_html.getElementById "js" in
        let element = R.element component ~props:(object%js
            val name = Js.string "bar"
          end) in
        R.dom##render element index;

        let open Lwt.Infix in
        Lwt_js.sleep 0.0 >>= (fun () ->
            let option () = Js.string "" in
            let text = Js.Opt.get (index##.textContent) option |> Js.to_string in
            Lwt.return @@ assert_ok ("bar" = text)
          )
      );

    "can create original stateful component" >:- (fun () ->
        prepare ();
        let module M = R.Component.Make_stateful(struct
            class type _t = object
              method name: Js.js_string Js.t Js.readonly_prop
            end
            type t = _t Js.t
          end)
            (struct
              class type _t = object
                method real_name: Js.js_string Js.t Js.prop
              end
              type t = _t Js.t
            end) in
        let component = M.make { R.Core.Component_spec.empty with
                                 R.Core.Component_spec.initialize = Some (fun this ->
                                     let name = Js.to_string this##.props##.name in
                                     this##.state := object%js
                                       val mutable real_name = Js.string ("Hello " ^ name)
                                     end);
                                 render = (fun this ->
                                     R.Dom.of_tag `span ~children:[|R.text @@ Js.to_string this##.state##.real_name|]
                                   );
                               } in
        let index = Dom_html.getElementById "js" in
        let element = R.element component ~props:(object%js
            val name = Js.string "bar"
          end) in
        R.dom##render element index;

        let open Lwt.Infix in
        Lwt_js.sleep 0.0 >>= (fun () ->
            let option () = Js.string "" in
            let text = Js.Opt.get (index##.textContent) option |> Js.to_string in
            Lwt.return @@ assert_ok ("Hello bar" = text)
          )
      );

    "can handle some event for stateful component" >:- (fun () ->
        prepare ();

        let module M = R.Component.Make_stateful(struct
            class type _t = object
              method name: Js.js_string Js.t Js.readonly_prop
            end
            type t = _t Js.t
          end)
            (struct
              class type _t = object
                method events: Js.js_string Js.t Js.js_array Js.t Js.prop
              end
              type t = _t Js.t
            end) in

        let component = M.make { R.Core.Component_spec.empty with
                                 R.Core.Component_spec.initialize = Some (fun this ->
                                     let name = this##.props##.name in
                                     this##.state := object%js
                                       val mutable events = Js.array [|name|]
                                     end);
                                 render = (fun this ->
                                     let children = Js.to_array this##.state##.events in
                                     let children = Array.map (fun v ->
                                         let v = (Js.to_string v) ^ "\n" in R.text v
                                       ) children in
                                     R.Dom.of_tag `span ~children
                                   );
                                 component_did_mount = Some (fun this ->
                                     let event = Js.array [|Js.string "did_mount"|] in
                                     this##setState (object%js
                                       val mutable events = this##.state##.events##concat event
                                     end)
                                   );
                               } in
        let index = Dom_html.getElementById "js" in
        let element = R.element component ~props:(object%js
            val name = Js.string "bar"
          end) in
        R.dom##render element index;

        let open Lwt.Infix in
        Lwt_js.sleep 0.0 >>= (fun () ->
            let option () = Js.string "" in
            let text = Js.Opt.get (index##.textContent) option |> Js.to_string in
            let v = String.split_on_char '\n' text
                    |> List.filter (fun v -> v <> "")
                    |> Array.of_list in
            Lwt.return @@ assert_ok ([|"bar"; "did_mount"|] = v)
          )
      );

    "can create element from tag with properties" >:- (fun () ->
        prepare ();

        let index = Dom_html.getElementById "js" in
        let element = R.Dom.of_tag `span ~props:({
            (R.Core.Element_spec.empty ()) with
            class_name = Some "test_class";
          }) in
        R.dom##render element index;

        let open Lwt.Infix in
        Lwt_js.sleep 0.0 >>= (fun () ->
            let selector = Js.string "test_class" in
            let dom = Dom_html.document##getElementsByClassName selector in
            let cls = dom##item 0 in
            let cls = Js.Opt.get cls (fun () -> failwith "Can not find element") in
            let name = cls##.className |> Js.to_string in
            Lwt.return @@ assert_ok ("test_class" = name)
          )
      );

    "can handle an event given from properties" >:- (fun () ->
        prepare ();

        let wait, waker = Lwt.wait () in
        let index = Dom_html.getElementById "js" in
        let element = R.Dom.of_tag `span ~props:({
            (R.Core.Element_spec.empty ()) with
            class_name = Some "test_class";
            on_key_down = Some (fun e ->
                let key = Js.to_string e##.key in
                Lwt.wakeup waker (assert_ok (key = "w")))
          }) in
        R.dom##render element index;

        let open Lwt.Infix in
        Lwt_js.sleep 0.0 >>= (fun () ->
            let selector = Js.string "test_class" in
            let dom = Dom_html.document##getElementsByClassName selector in
            let cls = dom##item 0 in
            let cls = Js.Opt.get cls (fun () -> failwith "Can not find element") in
            let module T = R.Test_util in
            T.instance##._Simulate##keyDown cls
                (Js.Optdef.return (object%js
                   val key = Js.string "w"
                 end)
                );
            Lwt_js.sleep 0.1
          ) >>= (fun () -> wait)
      );
  ];
