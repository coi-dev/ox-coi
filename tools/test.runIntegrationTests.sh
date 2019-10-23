#!/bin/bash

LOG_FILE=test_driver/logs/log.txt
success=0
failed=0

if [[ -f "$LOG_FILE" ]]; then
    rm ${LOG_FILE}
fi
touch ${LOG_FILE}

for test in test_driver/*
do
    if [[ -f "$test" ]]; then
        echo "Running test: $test"
        flutter drive --target=test_driver/setup/app.dart --driver=${test} --flavor development >> $LOG_FILE 2>&1
        if [[ $? -eq 0 ]]; then
            echo "$test successfully finished"
            ((success++))
        else
            echo "$test failed - See more information in test_driver/log.txt"
            ((failed++))
        fi
    fi
done

echo
testCount=$((success + failed))
echo "Test suite finished"
echo "All tests: $testCount"
echo "Successful: $success"
echo "Failed: $failed"
