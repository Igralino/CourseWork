import { config } from 'hse-lk-api'

// todo fix typings here
import * as oidc from 'hse-service-oidc/lib/config'

function throwErr(name: string): never {
	throw new Error(`${name} env missing`)
}

export const getConfig = () => {
	// if (!process.env.ATTACHMENT_SERVICE_URL) {
	// 	throw new Error('ATTACHMENT_SERVICE_URL env is missing')
	// }
	// if (!process.env.ATTACHMENT_SERVICE_TOKEN) {
	// 	throw new Error('ATTACHMENT_SERVICE_TOKEN env is missing')
	// }
	
	return {
		// @ts-ignore
		oidc: oidc(),
		hseapp: config.hseapp(),
		mongo: process.env.MONGO || throwErr('MONGO'),
		service: {
			prefix: '/voting',
			port: Number(process.env.PORT),
		},
		// attachments: {
		// 	url: process.env.ATTACHMENT_SERVICE_URL,
		// 	token: process.env.ATTACHMENT_SERVICE_TOKEN,
		// },
		AUTH_SERVICE_URL: 'https://api.hseapp.ru/auth/credentials',
		sentry: {
			dsn: process.env.SENTRY_DSN,
		},
		// moodle: {
		// 	api: 'https://edu.hse.ru/webservice/adfsrest/',
		// },
	}
}
export type Config = ReturnType<typeof getConfig>
