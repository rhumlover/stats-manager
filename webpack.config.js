var webpack = require('webpack'),
    ENV_DEV = process.env.ENV_DEV === '1',
    ENV_PROD = process.env.ENV_PROD === '1',
    BUILD_VAR = process.env.BUILD_VAR === '1',
    BUILD_UMD = process.env.BUILD_UMD === '1';

module.exports = {
    entry: "./main.js",

    output: {
        libraryTarget: BUILD_VAR ? 'var' : 'umd',
        library: BUILD_VAR ? 'StatsManager' : null,
        filename: "dist/stats-manager.js"
    },

    module: {
        loaders: [
            { test: /\.coffee$/, loader: "coffee-loader" }
        ]
    },

    plugins: ENV_DEV ? [] : [
        new webpack.optimize.UglifyJsPlugin({
            minimize: true,
            compress: {
                drop_console: true
            },
            output: {
                comments: false
            }
        })
    ]
};
