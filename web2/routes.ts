import * as Router from '@koa/router'
import {getPolicies, HseError} from 'hse-web-server'
import {$MainController} from './controllers/MainController'
import {object, string, ValidationError} from 'yup'

export const getRouter = (
  policies: ReturnType<typeof getPolicies>,
  {mainController}: $MainController,
) => {
  const router = new Router()

  router.use((ctx, next) => {
    return next().catch((error) => {
      if (error instanceof ValidationError) {
        throw HseError(400, error.errors.join('\n')).throw()
      }
      throw error
    })
  })
  router.get('/me', policies.verify, async (ctx) => {
    ctx.body = await mainController.me(ctx.state.decoded.email, ctx.state.decoded.token)
  })

  router.post('/key', policies.verify, async (ctx) => {
    const schema = object({
      key: string().required(),
      voting_id: string().required(),
    })
    const body = await schema.validate(ctx.request.body)
    await mainController.saveKey(ctx.state.decoded.email, body.key, body.voting_id)
    ctx.status = 204
  })

  router.post('/users', policies.verify, async (ctx) => {
    const schema = object({
      voting_id: string().required(),
    })
    const body = await schema.validate(ctx.request.body)
    ctx.body = await mainController.getGroupmates(ctx.state.decoded.token, body.voting_id)
  })

  return router
}
