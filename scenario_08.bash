#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_branch_was_created_and_switched_to ${2}
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
    touch b.txt 
    git add b.txt
    git commit -m 'Base commit'
    popd
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Create a branch called 'my_branch' and switch to this new branch.
The output of the command 'git branch' should show the new branch
'my_branch' as checked out (preceeded by an asterisk).
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 3.2 Git Branching - Basic Branching and Merging
EOF
}

check_that_branch_was_created_and_switched_to() {
    pushd ${1} &> /dev/null
    FACIT_FILE=$(mktemp /tmp/XXXXXXXX)
    ACTUAL_FILE=$(mktemp /tmp/XXXXXXXX)
    cat > ${FACIT_FILE} <<EOF
  master
* my_branch
EOF
    git branch &> ${ACTUAL_FILE}
    diff -E -b ${FACIT_FILE} ${ACTUAL_FILE} &> /dev/null
    if [[ $? == 0 ]]
    then
	RES="Verified - you are done"
    else
	RES="No - you are not done"
    fi
    rm -f ${FACIT_FILE} ${ACTUAL_FILE} &> /dev/null
    popd &> /dev/null
    echo ${RES}
}

main $@
