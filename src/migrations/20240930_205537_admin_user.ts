import { MigrateDownArgs, MigrateUpArgs } from '@payloadcms/db-mongodb'

/**
 * Generates the initial admin account
 */
export async function up({ payload }: MigrateUpArgs): Promise<void> {
  await payload.create({
    collection: 'users',
    data: {
      name: 'Admin',
      email: process.env.ADMIN_EMAIL?.toString() || 'admin@uxmachina.co',
      password: process.env.ADMIN_PASSWORD?.toString() || 'password',
    },
  })
}

/**
 * Deletes the initial admin account
 */
export async function down({ payload }: MigrateDownArgs): Promise<void> {
  await payload.delete({
    collection: 'users',
    where: {
      email: { equals: process.env.ADMIN_EMAIL?.toString() || 'admin@uxmachina.co' },
    },
  })
}
