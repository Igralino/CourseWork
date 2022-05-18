import {prop, getModelForClass, mongoose, modelOptions, Severity} from '@typegoose/typegoose'

// @modelOptions({options: {allowMixed: Severity.ALLOW}})
export class Key {
  @prop()
  public email!: string

  @prop()
  public voting_id!: string

  @prop()
  public key!: string
}

export const Keys = getModelForClass(Key, {
  schemaOptions: {
    timestamps: {
      createdAt: 'created_at',
      updatedAt: 'updated_at',
    },
    versionKey: false,
  },
})
export type Keys = typeof Keys
