#!/bin/bash  -x

set  -ue

_current_script_file=$0
_script_dir=$(dirname  "${_current_script_file}")

if [[ $# -lt 1 ]] ; then
    echo  "Usage: $0 (RepositoryName) [ProjName] [DirName]"  1>&2
    exit  1
fi

source  "${_script_dir}/config"

hg=${HG:-"${hg_bin_default}"}
hg_opts=${HG_OPTS:-'--verbose'}
git=${GIT:-"${git_bin_default}"}

user_email=${USER_EMAIL:-"${user_email_default}"}
user_name=${USER_NAME:-"${user_name_default}"}

repo_name=$1

if [[ $# -ge 2 ]] ; then
    proj_name=$2
    url_prefix="takahiro-itou-${proj_name}"
else
    proj_name=''
    url_prefix='takahiro-itou'
fi
hg_url_root="${url_prefix}-hggit"

if [[ $# -ge 3 ]] ; then
    dir_name=$3
else
    dir_name=${repo_name}
fi

if [[ ! -d ${dir_name} ]] ; then
    gitlab_root="git+ssh://git@gitlab.com:${hg_url_root}"
    ${hg}   clone  ${hg_opts}  ${gitlab_root}/${repo_name}.git  ${dir_name}
    ${git}  init   ${dir_name}
fi

cat  "${_script_dir}/hgrc"  |  sed  \
    -e  "s/@REPOSITORY_NAME@/${repo_name}/g"    \
    -e  "s/@URL_ROOT@/${hg_url_root}/g"         \
    -e  "s/@DIRECTORY_NAME@/${dir_name}/g"      \
  >  ${dir_name}/.hg/hgrc

pushd
git config --local user.email "${user_email}"
git config --local user.name  "${user_name}"
git remote add origin "git@gitlab.com:${url_prefix}/${repo_name}.git"
git remote add bit    "git@bucket.org:${url_prefix}/${repo_name}.git"
popd
