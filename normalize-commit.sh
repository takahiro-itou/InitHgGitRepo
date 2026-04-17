#!/bin/bash  -x

set  -ue

_current_script_file=$0
_script_dir=$(dirname  "${_current_script_file}")

source  "${_script_dir}/config"

user_email=${USER_EMAIL:-"${user_email_default}"}
user_name=${USER_NAME:-"${user_name_default}"}

gitlab_hostname="gitlab.com${url_host_postname}"
bucket_hostname="bucket.org${url_host_postname}"


##########################################################################

git config --local  'user.email'  "${user_email}"
git config --local  'user.name'   "${user_name}"

git filter-repo --email-callback "  return b'${user_email}'"
git filter-repo --name-callback  "  return b'${user_name}'"
