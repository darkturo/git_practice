#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_if_files_are_properly_ignored_at $2
    else
	setup_scenario
	generate_description_file
	generate_help_file
	show_scenario_text
    fi
}

show_scenario_text() {
    cat <<EOF
=================================================================
Your scenario GIT repository is in ${SCENARIO_GIT_REPO}
=================================================================
EOF
cat description.txt
cat <<EOF
=================================================================
Recommended reading in Pro Git            http://git-scm.com/book
EOF
cat help.txt
cat <<EOF
=================================================================
Run this script as
       bash $0 --verify ${SCENARIO_GIT_REPO}
when you think you are done
=================================================================
You can always read 
    description.txt To know what you need to do
    help.txt        To get Pointers on what to read
    repository.txt  To see where the scenario GIT repository is
=================================================================
EOF
}

setup_scenario() {
    SCENARIO_GIT_REPO=$(mktemp -d)
    pushd ${SCENARIO_GIT_REPO} &> /dev/null
    for i in {1..100}; do touch ${i}.txt; done
    git init . &> /dev/null
    popd &> /dev/null
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Ensure that all *.txt files are properly ignored in the git repo.
Thus, when issuing the commang 'git status' you should not get
a listing of all the *.txt files.
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 2.2 Git Basisc - Recording Changes to the Repository
subchapter Ignoring Files.
EOF
}

check_if_files_are_properly_ignored_at() {
    pushd ${1} &> /dev/null
    FACIT_FILE=$(mktemp)
    ACTUAL_FILE=$(mktemp)
    cat > ${FACIT_FILE} <<EOF
# On branch master
#
# Initial commit
#
# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
#       .gitignore
nothing added to commit but untracked files present (use "git add" to track)
EOF
    git status &> ${ACTUAL_FILE}
    diff -E -b ${FACIT_FILE} ${ACTUAL_FILE} &>/dev/null
    if [[ $? == 0 ]]
    then
	RES="Verified - you are done"
    else
	RES="No - you are not done"
    fi
    rm ${FACIT_FILE} ${ACTUAL_FILE} &> /dev/null
    echo ${RES}
    popd &> /dev/null
}

main $@
