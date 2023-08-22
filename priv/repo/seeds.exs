# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Notifly.Repo.insert!(%Notifly.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# Create roles
# alias Notifly.Accounts.Role
# Role.create_role(%{name: "Default", slug: "default"})
# Role.create_role(%{name: "Admin", slug: "admin"})
# Role.create_role(%{name: "Super User", slug: "superuser"})

# # Create permissions
# alias Notifly.Accounts.Permission
# Permission.create_permission(%{code_name: "can_send_email",name: "Can send email"})
# Permission.create_permission(%{code_name: "can_view_email",name: "Can view email"})
# Permission.create_permission(%{code_name: "can_delete_email",name: "Can delete email"})
# Permission.create_permission(%{code_name: "can_add_contact",name: "Can add contact"})
# Permission.create_permission(%{code_name: "can_edit_contact",name: "Can edit contact"})
# Permission.create_permission(%{code_name: "can_delete_contact",name: "Can delete contact"})
# Permission.create_permission(%{code_name: "can_add_group",name: "Can add group"})
# Permission.create_permission(%{code_name: "can_edit_group",name: "Can edit group"})
# Permission.create_permission(%{code_name: "can_delete_group",name: "Can delete group"})

# Permission.create_permission(%{code_name: "can_retry_failed_emails",name: "Can retry failed emails"})
# Permission.create_permission(%{code_name: "can_send_email_to_group",name: "Can send email to group"})
# Permission.create_permission(%{code_name: "can_view_status_of_group_emails",name: "Can view status of group emails"})
# Permission.create_permission(%{code_name: "can_view_user_data",name: "Can view user data"})
# Permission.create_permission(%{code_name: "can_delete_user_data",name: "Can delete user data"})
# Permission.create_permission(%{code_name: "can_upgrade_user_plan",name: "Can upgrade user plan"})
# Permission.create_permission(%{code_name: "can_downgrade_user_plan",name: "Can downgrade user plan"})
# Permission.create_permission(%{code_name: "can_grant_admin_access",name: "Can grant admin access"})
# Permission.create_permission(%{code_name: "can_revoke_admin_access",name: "Can revoke admin access"})
# Permission.create_permission(%{code_name: "can_grant_superuser_access",name: "Can grant superuser access"})
# Permission.create_permission(%{code_name: "can_revoke_superuser_access",name: "Can revoke superuser access"})


# Create role permissions
alias Notifly.Accounts.RolePermissions
# Frontend User
RolePermissions.create_role_permission(%{role_id: 1,permission_id: 1})
RolePermissions.create_role_permission(%{role_id: 1,permission_id: 2})
RolePermissions.create_role_permission(%{role_id: 1,permission_id: 3})
RolePermissions.create_role_permission(%{role_id: 1,permission_id: 4})
RolePermissions.create_role_permission(%{role_id: 1,permission_id: 5})
RolePermissions.create_role_permission(%{role_id: 1,permission_id: 6})
# Admin
RolePermissions.create_role_permission(%{role_id: 2,permission_id: 1})
RolePermissions.create_role_permission(%{role_id: 2,permission_id: 2})
RolePermissions.create_role_permission(%{role_id: 2,permission_id: 3})
RolePermissions.create_role_permission(%{role_id: 2,permission_id: 4})
RolePermissions.create_role_permission(%{role_id: 2,permission_id: 5})
RolePermissions.create_role_permission(%{role_id: 2,permission_id: 6})
RolePermissions.create_role_permission(%{role_id: 2,permission_id: 13})
RolePermissions.create_role_permission(%{role_id: 2,permission_id: 14})
# Super User
RolePermissions.create_role_permission(%{role_id: 3,permission_id: 1})
RolePermissions.create_role_permission(%{role_id: 3,permission_id: 2})
RolePermissions.create_role_permission(%{role_id: 3,permission_id: 3})
RolePermissions.create_role_permission(%{role_id: 3,permission_id: 4})
RolePermissions.create_role_permission(%{role_id: 3,permission_id: 5})
RolePermissions.create_role_permission(%{role_id: 3,permission_id: 6})
RolePermissions.create_role_permission(%{role_id: 3,permission_id: 7})
RolePermissions.create_role_permission(%{role_id: 3,permission_id: 8})
RolePermissions.create_role_permission(%{role_id: 3,permission_id: 9})
RolePermissions.create_role_permission(%{role_id: 3,permission_id: 10})
RolePermissions.create_role_permission(%{role_id: 3,permission_id: 11})
RolePermissions.create_role_permission(%{role_id: 3,permission_id: 12})
RolePermissions.create_role_permission(%{role_id: 3,permission_id: 13})
RolePermissions.create_role_permission(%{role_id: 3,permission_id: 14})
RolePermissions.create_role_permission(%{role_id: 3,permission_id: 15})
RolePermissions.create_role_permission(%{role_id: 3,permission_id: 16})
RolePermissions.create_role_permission(%{role_id: 3,permission_id: 17})
RolePermissions.create_role_permission(%{role_id: 3,permission_id: 18})
RolePermissions.create_role_permission(%{role_id: 3,permission_id: 19})
RolePermissions.create_role_permission(%{role_id: 3,permission_id: 20})
