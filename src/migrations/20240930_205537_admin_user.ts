import { reverseTransaction, transaction } from '@/utilities/migrations'
import { MigrateDownArgs, MigrateUpArgs } from '@payloadcms/db-mongodb'

interface MigrationContext {}

/**
 * Generates the initial admin account
 */
export async function up({ payload, req }: MigrateUpArgs): Promise<void> {
  await transaction(
    { payload, req },
    [
      async (ctx: MigrationContext) => {
        await payload.create({
          collection: 'users',
          data: {
            name: 'Admin',
            email: process.env.ADMIN_EMAIL?.toString() || 'admin@uxmachina.co',
            password: process.env.ADMIN_PASSWORD?.toString() || 'password',
          },
        })
      },
    ],
    down,
  )
}

/**
 * Deletes the initial admin account
 */
export async function down(
  { payload }: MigrateDownArgs,
  ctx: MigrationContext | undefined,
  successfulSteps: number | undefined,
): Promise<void> {
  return await reverseTransaction(
    [
      async (ctx: MigrationContext) => {
        await payload.delete({
          collection: 'users',
          where: {
            email: { equals: process.env.ADMIN_EMAIL?.toString() || 'admin@uxmachina.co' },
          },
        })
      },
    ],
    ctx,
    successfulSteps,
  )
}
