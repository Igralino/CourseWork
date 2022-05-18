import mongoose from 'mongoose'

import { oidc as OIDC } from 'hse-service-oidc'
import { createServer, getPolicies } from 'hse-web-server'
import { getConfig } from './config'
import { hseapp as Hseapp } from 'hse-lk-api'

import { getRouter } from './routes'
import { MainController } from './controllers/MainController'
import { AcademicGroupsRepo } from './repo/AcademicGroupsRepo'

export async function App() {
  const config = getConfig()

  const oidc = await OIDC(config.oidc)

  await mongoose.connect(config.mongo)

  const hseapp = Hseapp(config.hseapp)

  const policies = getPolicies({
    AUTH_SERVICE_URL: config.AUTH_SERVICE_URL,
    AUTH_SERVICE_TOKEN: process.env.AUTH_SERVICE_TOKEN || '',
    getOIDC: () => oidc,
  })

  const academicGroupsRepo = new AcademicGroupsRepo(config.hseapp.api)

  const mainController = new MainController(
    academicGroupsRepo,
    hseapp,
  )

  const router = getRouter(policies, {
    mainController,
  })

  const webServer = await createServer({
    prefix: config.service.prefix,
    port: config.service.port,
    router,
  }, {
    dsn: config.sentry.dsn,
    environment: process.env.NODE_ENV || 'development',
  })

  return {
    start: async () => {
      await webServer.start()
    },
  }
}
