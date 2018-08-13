const fs = require('fs');
const { execFileSync } = require('child_process');

if (require.main === module) {
  let cmdOptions = ['--config', 'webpack.dll.config.js'];

  let src = execFileSync('babel', ['src/raw.js']);

  fs.writeFileSync('src/raw.ml', `
let react_create_class_raw = {|\n(function () {
${src}
return _createClass;})|}
`);

}
