exports['ppx tool can create element via ppx extension 1'] = {
  "type": "span",
  "key": null,
  "ref": null,
  "props": {
    "children": "text"
  },
  "_owner": null,
  "_store": {}
}

exports['ppx tool should be able to set class name as props 1'] = {
  "type": "span",
  "key": "span",
  "ref": null,
  "props": {
    "className": "foo",
    "children": "text"
  },
  "_owner": null,
  "_store": {}
}

exports['ppx tool should be able to nest primitive elements 1'] = {
  "type": "span",
  "key": null,
  "ref": null,
  "props": {
    "className": "span",
    "children": {
      "type": "a",
      "key": null,
      "ref": null,
      "props": {
        "className": "a",
        "children": "text"
      },
      "_owner": null,
      "_store": {}
    }
  },
  "_owner": null,
  "_store": {}
}

exports['ppx tool should be able to create custom component 1'] = {
  "type": "span",
  "key": null,
  "ref": null,
  "props": {
    "className": "span",
    "children": {
      "type": "a",
      "key": null,
      "ref": null,
      "props": {
        "className": "a",
        "children": "foo"
      },
      "_owner": null,
      "_store": {}
    }
  },
  "_owner": null,
  "_store": {}
}
