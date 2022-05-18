require('dotenv/config')

import {App} from './app'

void (async () => {
  let app = await App()

  await app.start()
})()
