import { Api } from '../types/api'
import { Votings, VotingStatus } from '../models/voting'
import { Keys } from '../models/keys'
import { AcademicGroupsRepo } from '../repo/AcademicGroupsRepo'
import { HseAppApi } from 'hse-lk-api'
import { HseError } from 'hse-web-server'

export class MainController {
  constructor(
    private academicGroupsRepo: AcademicGroupsRepo,
    private hseapp: HseAppApi,
  ) {
  }

  async me(email: string, token: string): Promise<Api.MeResponse | undefined> {
    const group = await this.academicGroupsRepo.getByToken(token)
    if (!group) {
      throw HseError(400, 'NoGroup').throw()
    }

    let voting = await Votings.findOne({
      group_id: group.id,
      start_date: { $gte: new Date() },
    }).sort({ start_date: 1 })
    if (!voting) {
      voting = await Votings.findOne({
        group_id: group.id,
      }).sort({ start_date: -1 })
    }

    if (!voting) {
      throw HseError(400, 'NoVoting').throw()
    }

    const userKey = await Keys.findOne({ email, voting_id: voting.id })

    return {
      voting_status: voting.status,
      voting_id: voting.id,
      start_date: voting.start_date,
      finish_date: voting.finish_date,
      title: voting.title,
      contract_tx: voting.contract_tx,
      group_id: group.id,
      group_title: group.caption,
      public_key: userKey?.key,
    }
  }

  async saveKey(email: string, key: string, voting_id: string) {
    await Keys.updateOne({ email, voting_id }, {
      $set: { key },
    }, { upsert: true })
  }

  async getGroupmates(token: string, voting_id: string) {
    const group = await this.academicGroupsRepo.getByToken(token)
    if (!group) {
      return []
    }
    const people = await this.hseapp.onBehalfOfFlow(token).dumpEmails(group.emails).then((v) => v.body) as any[]
    const keys = await Keys.find({
      voting_id,
      email: { $in: group.emails },
    }).then((data) => new Map(data.map((v) => [v.email, v.key])))
    return people.map((user) => {
      return {
        user,
        key: keys.get(user.email)
      }
    })
  }
}

export type $MainController = { mainController: MainController }
