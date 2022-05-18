import {prop, getModelForClass, mongoose, modelOptions, Severity} from '@typegoose/typegoose'

export enum VotingStatus {
  REGISTER = 'REGISTER',
  PREPARE = 'PREPARE',
  ACTIVE = 'ACTIVE',
  FINISHED = 'FINISHED',
}

// @modelOptions({options: {allowMixed: Severity.ALLOW}})
export class Voting {
  @prop({enum: VotingStatus})
  public status!: VotingStatus

  @prop()
  public group_id!: string

  @prop()
  public id!: string

  @prop()
  public title!: string

  @prop()
  public contract_tx!: string

  @prop()
  public start_date!: Date

  @prop()
  public finish_date!: Date
}

export const Votings = getModelForClass(Voting, {
  schemaOptions: {
    timestamps: {
      createdAt: 'created_at',
      updatedAt: 'updated_at',
    },
    versionKey: false,
  },
})
export type Votings = typeof Votings
