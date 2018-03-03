module R = Jsoo_reactjs
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
            class type t = object
              method name: Js.js_string Js.t Js.readonly_prop
            end
          end) in
        let component = M.make (fun props ->
            R.Dom.of_tag `span ~children:[|
              R.text @@ Js.to_string props##.name
            |]
          ) in
        let index = Dom_html.getElementById "js" in
        let element = R.create_element component ~props:(object%js
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
            class type t = object
              method name: Js.js_string Js.t Js.readonly_prop
            end
          end)
            (struct
              class type t = object
                method real_name: Js.js_string Js.t Js.prop
              end
            end) in
        let component = M.make R.(component_spec
            ~constructor:(fun this props ->
                let name = Js.to_string props##.name in
                this##.state := object%js
                  val mutable real_name = Js.string ("Hello " ^ name)
                end)
            (fun this ->
                R.Dom.of_tag `span ~children:[|R.text @@ Js.to_string this##.state##.real_name|]
              )
          ) in
        let index = Dom_html.getElementById "js" in
        let element = R.create_element component ~props:(object%js
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
            class type t = object
              method name: Js.js_string Js.t Js.readonly_prop
            end
          end)
            (struct
              class type t = object
                method events: Js.js_string Js.t Js.js_array Js.t Js.prop
              end
            end) in

        let component = M.make R.(component_spec
            ~constructor:(fun this props ->
                let name = props##.name in
                this##.state := object%js
                  val mutable events = Js.array [|name|]
                end)
            ~component_did_mount:(fun this ->
                let event = Js.array [|Js.string "did_mount"|] in
                this##setState (object%js
                  val mutable events = this##.state##.events##concat event
                end)
              )
            (fun this ->
                let children = Js.to_array this##.state##.events in
                let children = Array.map (fun v ->
                    let v = (Js.to_string v) ^ "\n" in R.text v
                  ) children in
                R.Dom.of_tag `span ~children
              )
          ) in
        let index = Dom_html.getElementById "js" in
        let element = R.create_element component ~props:(object%js
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
        let element = R.Dom.of_tag `span ~props:(R.element_spec ~class_name:"test_class" ()) in
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
        let element = R.Dom.of_tag `span ~props:(
            R.element_spec ()
            ~class_name:"test_class"
            ~on_key_down:(fun e ->
                let key = Js.to_string e##.key in
                Lwt.wakeup waker (assert_ok (key = "w")))
          ) in
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

    "can create element with undeclared properties" >:- (fun () ->
        prepare ();

        let index = Dom_html.getElementById "js" in
        let element = R.Dom.of_tag `span ~props:(
            R.element_spec ()
            ~class_name:"test_class"
            ~others:(object%js
                val tabIndex = "0"
              end)
          ) in
        R.dom##render element index;

        let open Lwt.Infix in
        Lwt_js.sleep 0.0 >>= (fun () ->
            let selector = Js.string "test_class" in
            let dom = Dom_html.document##getElementsByClassName selector in
            let cls = dom##item 0 in
            let cls = Js.Opt.get cls (fun () -> failwith "Can not find element") in
            let attr = cls##.attributes##getNamedItem (Js.string "tabIndex") in
            let attr = match Js.Opt.to_option attr with
              | None -> failwith ""
              | Some attr -> Js.to_string attr##.value in
            let others = cls##.attributes##getNamedItem (Js.string "others") in
            Lwt.return @@ assert_ok ("0" = attr && not (Js.Opt.test others))
          )
      );

    "should not override declared properties from in others property" >:- (fun () ->
        prepare ();

        let index = Dom_html.getElementById "js" in
        let element = R.Dom.of_tag `span ~props:(
            R.element_spec ()
            ~class_name:"test_class"
            ~others:(object%js
                val className = "override"
              end)
          ) in
        R.dom##render element index;

        let open Lwt.Infix in
        Lwt_js.sleep 0.0 >>= (fun () ->
            let selector = Js.string "test_class" in
            let dom = Dom_html.document##getElementsByClassName selector in
            let cls = dom##item 0 in
            let cls = Js.Opt.get cls (fun () -> failwith "Can not find element") in
            let cls = cls##.className in
            Lwt.return @@ assert_eq (Js.string "test_class") cls
          )
      );

    "can specify key to components in children that are DOM element" >:- (fun () ->
        prepare ();

        let index = Dom_html.getElementById "js" in
        let element = R.Dom.of_tag `div ~props:(R.element_spec ~class_name:"test_class" ())
            ~children:[|
              R.Dom.of_tag `span ~key:"foo" ~children:[|R.text "foo"|];
              R.Dom.of_tag `span ~key:"bar" ~children:[|R.text "bar"|];
              R.Dom.of_tag `span ~key:"baz" ~children:[|R.text "baz"|];
            |]in
        R.dom##render element index;

        let open Lwt.Infix in
        Lwt_js.sleep 0.0 >>= (fun () ->
            let selector = Js.string "test_class" in
            let dom = Dom_html.document##getElementsByClassName selector in
            let cls = dom##item 0 in
            let cls = Js.Opt.get cls (fun () -> failwith "Can not find element") in
            let nodes = cls##.childNodes##.length in
            Lwt.return @@ assert_eq 3 nodes
          )
      );

    "can specify key to original components in children" >:- (fun () ->
        prepare ();
        let module M = R.Component.Make_stateless(struct
            class type t = object
              method name: Js.js_string Js.t Js.readonly_prop
            end
          end) in
        let component = M.make (fun props ->
            R.Dom.of_tag `span ~children:[|
              R.text @@ Js.to_string props##.name
            |]
          ) in

        let index = Dom_html.getElementById "js" in
        let element = R.Dom.of_tag `div ~props:(R.element_spec ~class_name:"test_class" ())
            ~children:[|
              R.create_element ~key:"foo" ~props:(object%js val name = Js.string "foo" end) component;
              R.create_element ~key:"bar" ~props:(object%js val name = Js.string "bar" end) component;
              R.create_element ~key:"baz" ~props:(object%js val name = Js.string "baz" end) component;
            |]in
        R.dom##render element index;

        let open Lwt.Infix in
        Lwt_js.sleep 0.0 >>= (fun () ->
            let selector = Js.string "test_class" in
            let dom = Dom_html.document##getElementsByClassName selector in
            let cls = dom##item 0 in
            let cls = Js.Opt.get cls (fun () -> failwith "Can not find element") in
            let nodes = cls##.childNodes##.length in
            Lwt.return @@ assert_eq 3 nodes
          )
      );
    "can wrap elements by fragment component" >:- (fun () ->
        prepare ();
        let module M = R.Component.Make_stateless(struct
            class type t = object
              method name: Js.js_string Js.t Js.readonly_prop
            end
          end) in
        let component = M.make (fun props ->
            R.Core.fragment [|
              R.text @@ Js.to_string props##.name;
              R.text @@ Js.to_string props##.name;
              R.text @@ Js.to_string props##.name;
            |]
          ) in

        let index = Dom_html.getElementById "js" in
        let element = R.Dom.of_tag `div ~props:(R.element_spec ~class_name:"test_class" ())
            ~children:[|
              R.create_element ~key:"foo" ~props:(object%js val name = Js.string "foo" end) component;
              R.create_element ~key:"bar" ~props:(object%js val name = Js.string "bar" end) component;
              R.create_element ~key:"baz" ~props:(object%js val name = Js.string "baz" end) component;
            |]in
        R.dom##render element index;

        let open Lwt.Infix in
        Lwt_js.sleep 0.0 >>= (fun () ->
            let selector = Js.string "test_class" in
            let dom = Dom_html.document##getElementsByClassName selector in
            let cls = dom##item 0 in
            let cls = Js.Opt.get cls (fun () -> failwith "Can not find element") in
            let nodes = cls##.childNodes##.length in
            Lwt.return @@ assert_eq 9 nodes
          )
      );
    "can fetch reference of DOM element" >:- (fun () ->
        prepare ();
        let module M = R.Component.Make_stateful(struct
            class type t = object
              method name: Js.js_string Js.t Js.readonly_prop
            end
          end)(struct
            class type t = object
              method node: Dom_html.element Js.t Js.readonly_prop
            end
          end) in

        let component = M.make R.(component_spec
            ~constructor:(fun this props -> this##.nodes := Jstable.create ())
            ~component_did_mount:(fun this ->
                let open R.Ref_table in
                match find this##.nodes "node" with
                | None -> ()
                | Some e -> begin
                    e##setAttribute (Js.string "data-test") (Js.string "value");
                    e##setAttribute (Js.string "id") (Js.string "value");
                  end
              )
            (fun this ->
                let props = this##.props in
                R.Dom.of_tag `span ~_ref:(fun e ->
                    R.Ref_table.(add this##.nodes ~key:"node" ~value:e);
                  )
                  ~children:[|
                    R.text @@ Js.to_string props##.name
                  |]
              )
          ) in
        let index = Dom_html.getElementById "js" in
        let element = R.create_element component ~props:(object%js
            val name = Js.string "bar"
          end) in
        R.dom##render element index;

        let open Lwt.Infix in
        Lwt_js.sleep 0.0 >>= (fun () ->
            let index = Dom_html.getElementById "value" in
            let option () = Js.string "" in
            let text = Js.Opt.get (index##getAttribute (Js.string "data-test")) option |> Js.to_string in
            Lwt.return @@ assert_ok ("value" = text)
          )
      );

    "can get children in component" >:- (fun () ->
        prepare ();
        let module M = R.Component.Make_stateful(struct
            class type t = object
              method name: Js.js_string Js.t Js.readonly_prop
            end
          end)(struct type t = unit end) in

        let component = M.make R.(component_spec
            (fun this ->
                let children = this##.props_defined##.children in
                let count = children##.length |> string_of_int in
                R.Dom.of_tag `span ~children:[| R.text count |]
              )
          ) in
        let index = Dom_html.getElementById "js" in
        let element = R.create_element component ~props:(object%js
            val name = Js.string "bar"
          end) ~children:(Array.init 3 (fun i -> R.Dom.of_tag ~key:(string_of_int i) `span)) in
        R.dom##render element index;

        let open Lwt.Infix in
        Lwt_js.sleep 0.0 >>= (fun () ->
            let option () = Js.string "" in
            let text = Js.Opt.get (index##.textContent) option |> Js.to_string in
            Lwt.return @@ assert_ok ("3" = text)
          )
      );
  ];

  Test_jsoo_dom_input.suite ()
