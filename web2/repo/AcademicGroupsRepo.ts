import got, {Got} from 'got'

const {catchGotError} = require('../lib/gotUtils')

export interface AcademicGroupResponse {
  PEOPLE_GROUP_ACADEMIC?: AcademicGroupResponseGroup
}

export interface AcademicGroupResponseGroup {
  id: string
  emails: string[]
  caption: string
  title: string
}

export class AcademicGroupsRepo {
  client: Got

  constructor(apiRoot: string) {
    console.log(apiRoot, 'hseapp api root')
    this.client = got.extend({
      prefixUrl: apiRoot,
    })
  }

  async getByToken(token: string): Promise<AcademicGroupResponseGroup | undefined> {
    console.log('getting academic group by token')
    const {body} = await this.client.get<AcademicGroupResponse>('v2/dump/people', {
      responseType: 'json',
      headers: {
        'Authorization': `Bearer ${token}`,
      },
    }).catch(catchGotError('Unable to call dump/people'))
    if (body.PEOPLE_GROUP_ACADEMIC) {
      return body.PEOPLE_GROUP_ACADEMIC
    }
  }
}
export type $AcademicGroupsRepo = {academicGroupsRepo: AcademicGroupsRepo}
