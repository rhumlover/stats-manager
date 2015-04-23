express = require 'express'
app = express()
port = 8080

app.use '/dist', express.static('dist')
app.use '/vendor', express.static('node_modules')
app.use express.static('test')

app.listen port
console.log 'Listening on port %s', port
