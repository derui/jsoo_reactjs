
class type synthetic_event = object
  method bubbles: bool Js.t Js.readonly_prop
  method cancelable: bool Js.t Js.readonly_prop
  method currentTarget: 'a Js.t Js.readonly_prop
  method defaultPrevented: bool Js.t Js.readonly_prop
  method eventPhase: Js.number Js.t Js.readonly_prop
  method isTrusted: bool Js.t Js.readonly_prop
  method nativeEvent: 'a Dom.event Js.t Js.readonly_prop
  method preventDefault:  unit Js.meth
  method isDefaultPrevented:  bool Js.t Js.meth
  method stopPropagation: unit Js.meth
  method isPropagationStopped: bool Js.t Js.meth
  method target: 'a Js.t Js.readonly_prop
  method timeStamp: Js.number Js.t Js.readonly_prop
  method _type: Js.js_string Js.t Js.readonly_prop
end

class type _keyboard_event = object
  inherit synthetic_event

  method altKey: bool Js.t Js.readonly_prop
  method charCode: Js.number Js.t Js.readonly_prop
  method ctrlKey: bool Js.t Js.readonly_prop
  method getModifierState: Js.js_string Js.t -> bool Js.t Js.meth
  method key: Js.js_string Js.t Js.readonly_prop
  method keyCode: Js.number Js.t Js.readonly_prop
  method locale: Js.js_string Js.t Js.readonly_prop
  method location: Js.number Js.t Js.readonly_prop
  method metaKey: bool Js.t Js.readonly_prop
  method repeat: bool Js.t Js.readonly_prop
  method shiftKey: bool Js.t Js.readonly_prop
  method which: Js.number Js.t Js.readonly_prop
end

type keyboard_event = _keyboard_event Js.t
