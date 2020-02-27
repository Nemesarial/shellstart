#!/bin/bash
CWD=`pwd`
PROJECT=$1
PORT=${2-3000}





if [ -z $PROJECT ] ; then
	echo "No project name specified" && exit 1
fi

ROOT="${CWD}/${PROJECT}"

echo "Working Dir: ${CWD}"
echo "Project: ${ROOT}"
echo "Port: ${PORT}"

mkdir -p "$ROOT/src/components"

cd $ROOT
if [ "$ROOT" != "$(pwd)" ]; then
	echo "could change into ${ROOT} ($(pwd))"
fi

git init 

echo -e "$(awk '{printf "%s\\n", $0}' <<EOF
{
  "name": "${PROJECT}",
  "version": "1.0.0",
  "description": "Vue-Webpack webpack-dev-server ready project",
  "main": "index.js",
  "scripts": {
    "start": "webpack-dev-server"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
EOF
)" > "${ROOT}/package.json"


########################## Writing to file src/index.html
echo -e "$(awk '{printf "%s\n", $0}' <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta http-equiv="X-UA-Compatible" content="ie=edge">
	<title><%= htmlWebpackPlugin.options.title %></title>
</head>
<body>
	<div id="app"></div>
	
</body>
</html>
EOF
)" > "$ROOT/src/index.html"
###


########################## Writing to file src/components/Main.vue
echo -e "$(awk '{printf "%s\n", $0}' <<EOF
<template>
  <div>Hello $PROJECT</div>
</template>

<script>
export default {
	name: 'Main'
}
</script>

<style>

</style>
EOF
)" > "$ROOT/src/components/Main.vue"
###



########################## Writing to file src/app.js
echo -e "$(awk '{printf "%s\n", $0}' <<EOF
import Vue from 'vue'
import Main from './components/Main.vue'

new Vue({
	render: h => h(Main)
}).\$mount('#app')
EOF
)" > "$ROOT/src/app.js"
###



########################## Writing to file webpack.config.js
echo -e "$(awk '{printf "%s\n", $0}' <<EOF
const HTMLWebpackPlugin = require('html-webpack-plugin')
const { join } = require('path')
const { VueLoaderPlugin } = require('vue-loader')
const { HotModuleReplacementPlugin } = require('webpack')

const config = {
	mode: 'development',
	entry: join(__dirname, 'src/app.js'),
	output:{
		path: join(__dirname, 'dist'),
		filename: 'bundle.js'
	},
	devServer:{
		port: $PORT,
		open: true,
		historyApiFallback: true
	},
	module:{
		rules:[
			{
				test: /\.js$/,
				loader: 'babel-loader',
				options: {
					presets: ['@babel/preset-env']
				}
			},
			{
				test: /\.vue$/,
				loader: 'vue-loader'
			},
			{
				test: /\.css$/,
				use: [
					'vue-style-loader',
					'css-loader'
				]
			}
		]
	},
	plugins:[
		new HotModuleReplacementPlugin(),
		new VueLoaderPlugin(),
		new HTMLWebpackPlugin({
			showErrors: true,
			cache: true,
			title: 'Vue with Webpack Start Project',
			template: join(__dirname, 'src/index.html')
		})
	]
}

module.exports = config
EOF
)" > "$ROOT/webpack.config.js"
###



npm i -D @babel/cli @babel/core @babel/preset-env babel-loader webpack webpack-cli webpack-dev-server html-webpack-plugin vue-loader vue-template-compiler css-loader vue-style-loader
npm i -P vue
