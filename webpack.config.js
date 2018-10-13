const path = require("path");

module.exports = {
  // どのファイルをビルドするのかを指定。複数可。
  mode: 'development',
  entry: [
    './_build/default/test/test_jsoo_reactjs.bc.js',
    './_build/default/test/transition_group/css_transition_group_test.bc.js'
  ],
  // 出力するファイル名と出力先パス

  output: {
    path: path.join(__dirname, '_build/default/test/'),
    filename: 'test_bundle.js'
  },
  node: {
    fs: "empty",
    child_process: "empty"
  },
  devtool: 'eval',
  // requireで読み込むときのrootのpathを指定
  resolve: {
    extensions: ['.js'],
  },
  cache: true
}
