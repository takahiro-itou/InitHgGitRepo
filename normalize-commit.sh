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

local  _gitlab_hostname="gitlab.com${url_host_postname}"
local  _bucket_hostname="bucket.org${url_host_postname}"


##
##    引数解析
##

local  _repo_name
local  _proj_name
local  _url_prefix

if [[ $# -ge 1 ]] ; then
    _repo_name=$1
else
    _repo_name=''
fi

if [[ $# -ge 2 ]] ; then
    _proj_name=$2
    _url_prefix="${url_account_name}-${_proj_name}"
else
    _proj_name=''
    _url_prefix="${url_account_name}"
fi


##
##    リポジトリにフィルタを適用
##

_gitlab_root="git@${_gitlab_hostname}:${_url_prefix}"
_bucket_root="git@${_bucket_hostname}:${_url_prefix}"

"${_git}"  config --local  'user.email'  "${_user_email}"
"${_git}"  config --local  'user.name'   "${_user_name}"

"${_git}"  filter-repo  --email-callback "  return b'${_user_email}'"
"${_git}"  filter-repo  --name-callback  "  return b'${_user_name}'"


# 解除されるリモートを再設定

if [[ "X${_repo_name}Y" != 'XY' ]] ; then
    "${_git}"  remote add  origin "${_gitlab_root}/${_repo_name}.git"
    "${_git}"  remote add  bit    "${_bucket_root}/${_repo_name}.git"
fi

}


chgcmt::main  "$@"
