#!/bin/bash  -x

set  -ue

##########################################################################
##
##    メイン
##

function  initrepo::main () {


##
##    変数定義
##

local  _script_file=$0
local  _script_real_file=$(readlink -f "${_script_file}")
local  _script_dir=$(dirname "${_script_real_file}")

source  "${_script_dir}/config"

_hg=${HG:-"${hg_bin_default}"}
_hg_opts=${HG_OPTS:-'--verbose'}
_git=${GIT:-"${git_bin_default}"}

_user_email=${USER_EMAIL:-"${user_email_default}"}
_user_name=${USER_NAME:-"${user_name_default}"}

_gitlab_hostname="gitlab.com${url_host_postname}"
_bucket_hostname="bucket.org${url_host_postname}"


##
##    引数解析
##

local  _repo_name=$1
local  _proj_name
local  _dir_name
local  _url_prefix

if [[ $# -ge 2 ]] ; then
    _proj_name=$2
    _url_prefix="${url_account_name}-${_proj_name}"
else
    _proj_name=''
    _url_prefix="${url_account_name}"
fi
local  _hg_url_root="${_url_prefix}-hggit"

if [[ $# -ge 3 ]] ; then
    _dir_name=$3
else
    _dir_name="${_repo_name}"
fi


##
##    クローンしてリポジトリの設定を行う
##

local  _gitlab_root="git+ssh://git@${_gitlab_hostname}:${_hg_url_root}"
local  _hg_clone_url="${_gitlab_root}/${_repo_name}.git"

if [[ ! -d ${_dir_name} ]] ; then
    "${_hg}"   clone  ${_hg_opts}  "${_hg_clone_url}"  "${_dir_name}"
    "${_git}"  init   "${_dir_name}"
fi

cat  "${_script_dir}/hgrc"  |  sed  \
    -e  "s/@REPOSITORY_NAME@/${_repo_name}/g"   \
    -e  "s/@URL_ROOT@/${_hg_url_root}/g"        \
    -e  "s/@DIRECTORY_NAME@/${_dir_name}/g"     \
  >  ${_dir_name}/.hg/hgrc

_gitlab_root="git@${_gitlab_hostname}:${_url_prefix}"
_bucket_root="git@${_bucket_hostname}:${_url_prefix}"

pushd  "${_dir_name}"   1>&2
git config --local user.email "${_user_email}"
git config --local user.name  "${_user_name}"
git remote add origin "${_gitlab_root}/${_repo_name}.git"
git remote add bit    "${_bucket_root}/${_repo_name}.git"
popd   1>&2

}


if [[ $# -lt 1 ]] ; then
    echo  "Usage: $0 (RepositoryName) [ProjName] [DirName]"  1>&2
    exit  1
fi

initrepo::main  "$@"
