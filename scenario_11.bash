#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_branch_rebased_on_top_of_latest_changes ${2}
    else
	setup_scenario &> /dev/null
	generate_description_file
	generate_help_file
	bash user_text.bash $0
    fi
}

setup_scenario() {
    SCENARIO_GIT_REPO=$(mktemp -d /tmp/GITPractice_Repo_XXXXXXXX)
    pushd ${SCENARIO_GIT_REPO}
    git init .
    touch {a,b}.txt
    git add {a,b}.txt
    git commit -m 'Initial commit'
    echo 'line one' >> a.txt && git commit -a -m 'A is modified'
    git checkout -b working_branch
    echo 'line one' >> b.txt && git commit -a -m 'B is modified'
    echo 'line two' >> b.txt && git commit -a -m 'B is modified again'
    git checkout master
    echo 'line two' >> a.txt && git commit -a -m 'A is modified again'
    popd
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Rebase the branch 'working_branch' on top of the latest changes 
in master. You can verify that this is done by visualizing the 
git repository commits with 'gitk --all'
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 3.6 Git Branching - Rebasing
EOF
}

check_that_branch_rebased_on_top_of_latest_changes() {
    pushd ${1} &> /dev/null
    FACIT_FILE_BRANCH=$(mktemp /tmp/XXXXXXXX)
    ACTUAL_FILE_BRANCH=$(mktemp /tmp/XXXXXXXX)
    FACIT_FILE_LOG=$(mktemp /tmp/XXXXXXXX)
    ACTUAL_FILE_LOG=$(mktemp /tmp/XXXXXXXX)
    cat > ${FACIT_FILE_BRANCH} <<EOF
  master
* working_branch
EOF
    cat > ${FACIT_FILE_LOG} <<EOF
* B is modified again
* B is modified
* A is modified again
* A is modified
* Initial commit
EOF
    git branch &> ${ACTUAL_FILE_BRANCH}
    git log --graph --format="%s" &> ${ACTUAL_FILE_LOG}

    diff -E -b ${FACIT_FILE_BRANCH} ${ACTUAL_FILE_BRANCH} &> /dev/null
    R1=$? 
    diff -E -b ${FACIT_FILE_LOG} ${ACTUAL_FILE_LOG} &> /dev/null
    R2=$?

    if [[ ${R1} == ${R2} && ${R2} == 0 ]]
    then
	RES="Verified - you are done"
    else
	RES="No - you are not done"
    fi
    rm -f ${FACIT_FILE_BRANCH} \
	  ${ACTUAL_FILE_BRANCH} \
	  ${FACIT_FILE_LOG} \
	  ${ACTUAL_FILE_LOG} &> /dev/null
    popd &> /dev/null
    echo ${RES}
}

main $@
