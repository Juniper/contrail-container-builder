#!/bin/bash -x

function usage {
    cat <<EOF
Usage: $0 [OPTIONS]

Run contrail-test in container

  -h  Print help
  -t  Testbed file, Default: /opt/contrail/utils/fabfile/testbeds/testbed.py
  -p  contrail fab utils path. Default: /opt/contrail/utils
  -f  features to test. Default: sanity
      Valid options:
        sanity, quick_sanity, ci_sanity, ci_sanity_WIP, ci_svc_sanity,
        upgrade, webui_sanity, ci_webui_sanity, devstack_sanity, upgrade_only
  -T  test tags to run tests. If not provided, try $TEST_TAGS variable
  -l  path where contrail-test can be found. Default: /contrail-test

EOF
}

while getopts ":T:t:p:f:h" opt; do
  case $opt in
    h)
      usage
      exit
      ;;
    t)
      testbed_input=$OPTARG
      ;;
    p)
      contrail_fabpath_input=$OPTARG
      ;;
    f)
      feature_input=$OPTARG
      ;;
    T)
      test_tags=$OPTARG
      ;;
    l)
      contrail_test_folder=$OPTARG
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

TESTBED=${testbed_input:-${TESTBED:-'/opt/contrail/utils/fabfile/testbeds/testbed.py'}}
CONTRAIL_FABPATH=${contrail_fabpath_input:-${CONTRAIL_FABPATH:-'/opt/contrail/utils'}}
CONTRAIL_TEST_FOLDER=${contrail_test_folder:-${CONTRAIL_TEST_FOLDER:-'/contrail-test'}}
FEATURE=${feature_input:-${FEATURE:-'sanity'}}
TEST_TAGS=${test_tags:-$TEST_TAGS}

if [[ ( ! -f ${CONTRAIL_TEST_FOLDER}/sanity_params.ini || ! -f ${CONTRAIL_TEST_FOLDER}/sanity_testbed.json ) && ! -f $TESTBED ]]; then
    echo "ERROR! Either testbed file or sanity_params.ini or sanity_testbed.json under /contrail-test is required.
          you probably forgot to attach them as volumes"
    exit 100
fi

if [ ! $TESTBED -ef ${CONTRAIL_FABPATH}/fabfile/testbeds/testbed.py ]; then
    mkdir -p ${CONTRAIL_FABPATH}/fabfile/testbeds/
    cp $TESTBED ${CONTRAIL_FABPATH}/fabfile/testbeds/testbed.py
fi

cd ${CONTRAIL_TEST_FOLDER}
run_tests="./run_tests.sh --contrail-fab-path $CONTRAIL_FABPATH "
if [[ -n $TEST_RUN_CMD ]]; then
    $TEST_RUN_CMD $EXTRA_RUN_TEST_ARGS
    rv_run_test=$?
elif [[ -n $TEST_TAGS ]]; then
    $run_tests -T $TEST_TAGS $EXTRA_RUN_TEST_ARGS
    rv_run_test=$?
else
    case $FEATURE in
        sanity)
            $run_tests --sanity --send-mail -U $EXTRA_RUN_TEST_ARGS
            rv_run_test=$?
            ;;
        quick_sanity)
            $run_tests -T quick_sanity --send-mail -t $EXTRA_RUN_TEST_ARGS
            rv_run_test=$?
            ;;
        ci_sanity)
            export ci_image=${CI_IMAGE:-'cirros'}
            $run_tests -T ci_sanity --send-mail -U $EXTRA_RUN_TEST_ARGS
            rv_run_test=$?
            ;;
        ci_sanity_WIP)
            export ci_image=${CI_IMAGE:-'cirros'}
            $run_tests -T ci_sanity_WIP --send-mail -U $EXTRA_RUN_TEST_ARGS
            rv_run_test=$?
            ;;
        ci_svc_sanity)
            python ci_svc_sanity_suite.py
            rv_run_test=$?
            ;;
        upgrade)
            $run_tests -T upgrade --send-mail -U $EXTRA_RUN_TEST_ARGS
            rv_run_test=$?
            ;;
        webui_sanity)
            python webui_tests_suite.py
            rv_run_test=$?
            ;;
        ci_webui_sanity)
            python ci_webui_sanity.py
            rv_run_test=$?
            ;;
        devstack_sanity)
            python devstack_sanity_tests_with_setup.py
            rv_run_test=$?
            ;;
        upgrade_only)
            python upgrade/upgrade_only.py
            rv_run_test=$?
            ;;
        *)
            echo "Unknown FEATURE - ${FEATURE}"
            exit 1
            ;;
    esac
fi


if [ -d ${CONTRAIL_TEST_FOLDER}.save ]; then
    cp -f ${CONTRAIL_FABPATH}/fabfile/testbeds/testbed.py ${CONTRAIL_TEST_FOLDER}.save/
    rsync -L -a --exclude logs/ --exclude report/ ${CONTRAIL_TEST_FOLDER} ${CONTRAIL_TEST_FOLDER}.save/
fi

exit $rv_run_test
