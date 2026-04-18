#!/bin/bash  -x

set  -ue


##########################################################################
##
##    メイン
##

function  chgcmt::main () {


##
##    変数定義
##

local  _script_file=$0
local  _script_real_file=$(readlink -f "${_script_file}")
local  _script_dir=$(dirname "${_script_real_file}")

source  "${_script_dir}/config"

local  _git=${GIT:-"${git_bin_default}"}

local  _user_email=${USER_EMAIL:-"${user_email_default}"}
local  _user_name=${USER_NAME:-"${user_name_default}"}

gitlab_hostname="gitlab.com${url_host_postname}"
bucket_hostname="bucket.org${url_host_postname}"


##########################################################################

"${_git}"  config --local  'user.email'  "${_user_email}"
"${_git}"  config --local  'user.name'   "${_user_name}"

"${_git}"  filter-repo  --email-callback "  return b'${_user_email}'"
"${_git}"  filter-repo  --name-callback  "  return b'${_user_name}'"

}


chgcmt::main  "$@"
