import {VotingStatus} from '../models/voting'

export namespace Api {
  export interface MeResponse {
    voting_status: VotingStatus
    voting_id: string
    start_date: Date
    finish_date: Date
    title: string
    contract_tx: string
    group_id: string
    group_title: string
    public_key: string | undefined
  }

  export interface User {

  }
}
