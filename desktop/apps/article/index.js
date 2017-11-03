import 'babel-core/register'
import * as routes from './routes'
import adminOnly from 'desktop/lib/admin_only.coffee'
import express from 'express'

const app = module.exports = express()

app.set('view engine', 'jade')
app.set('views', `${__dirname}/templates`)

app.get('/article/:slug/amp', adminOnly, routes.amp)
app.get('/article/:slug', adminOnly, routes.index)
app.post('/signup/editorial', routes.editorialSignup)
app.get('/post/:id', routes.redirectPost)
app.get('/:id/posts', routes.redirectPost)