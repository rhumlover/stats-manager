module.exports = {
    entry: "./main.js",

    output: {
        filename: ".tmp/bundle.js"
    },

    module: {
        loaders: [
            { test: /\.coffee$/, loader: "coffee-loader" }
        ]
    }
};
