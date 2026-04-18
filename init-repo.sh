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

hg=${HG:-"${hg_bin_default}"}
hg_opts=${HG_OPTS:-'--verbose'}
git=${GIT:-"${git_bin_default}"}

user_email=${USER_EMAIL:-"${user_email_default}"}
user_name=${USER_NAME:-"${user_name_default}"}

gitlab_hostname="gitlab.com${url_host_postname}"
bucket_hostname="bucket.org${url_host_postname}"


##
##    引数解析
##

repo_name=$1

if [[ $# -ge 2 ]] ; then
    proj_name=$2
    url_prefix="${url_account_name}-${proj_name}"
else
    proj_name=''
    url_prefix="${url_account_name}"
fi
hg_url_root="${url_prefix}"

if [[ $# -ge 3 ]] ; then
    dir_name=$3
else
    dir_name=${repo_name}
fi


##
##    クローンしてリポジトリの設定を行う
##

if [[ ! -d ${dir_name} ]] ; then
    _gitlab_root="git+ssh://git@${gitlab_hostname}:${hg_url_root}"
    ${hg}   clone  ${hg_opts}  ${_gitlab_root}/${repo_name}.git  ${dir_name}
    ${git}  init   ${dir_name}
fi

cat  "${_script_dir}/hgrc"  |  sed  \
    -e  "s/@REPOSITORY_NAME@/${repo_name}/g"    \
    -e  "s/@URL_ROOT@/${hg_url_root}/g"         \
    -e  "s/@DIRECTORY_NAME@/${dir_name}/g"      \
  >  ${dir_name}/.hg/hgrc

_gitlab_root="git@${gitlab_hostname}:${url_prefix}"
_bucket_root="git@${bucket_hostname}:${url_prefix}"

pushd  "${dir_name}"    1>&2
git config --local user.email "${user_email}"
git config --local user.name  "${user_name}"
git remote add origin "${_gitlab_root}/${repo_name}.git"
git remote add bit    "${_bucket_root}/${repo_name}.git"
popd   1>&2

}


if [[ $# -lt 1 ]] ; then
    echo  "Usage: $0 (RepositoryName) [ProjName] [DirName]"  1>&2
    exit  1
fi

initrepo::main  "$@"
