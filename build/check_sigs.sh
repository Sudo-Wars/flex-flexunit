#!/bin/sh -e

################################################################################
##
##  Licensed to the Apache Software Foundation (ASF) under one or more
##  contributor license agreements.  See the NOTICE file distributed with
##  this work for additional information regarding copyright ownership.
##  The ASF licenses this file to You under the Apache License, Version 2.0
##  (the "License"); you may not use this file except in compliance with
##  the License.  You may obtain a copy of the License at
##
##      http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
##
################################################################################

if [ $# -ne 3 ]
then
    echo "Usage: check_sigs flexunit_version ([0-99].[0-99].[0-999]) flex_version ([0-99].[0-99].[0-999]) release_candidate ([0-100])"
    exit 1
fi

FLEXUNIT_VERSION="$1"
CHECK=`echo "$FLEXUNIT_VERSION" | grep -q -E '[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,3}$'`

if [ $? -ne 0 ]
then
	echo "Apache FlexUnit version  needs to be in the form [0-99].[0-99].[0-999]"
	exit 1
fi

FLEX_VERSION="$2"
CHECK=`echo "$FLEX_VERSION" | grep -q -E '[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,3}$'`

if [ $? -ne 0 ]
then
	echo "Apache Flex version  needs to be in the form [0-99].[0-99].[0-999]"
	exit 1
fi

RELEASE_CANDIDATE="$3"
CHECK=`echo "$RELEASE_CANDIDATE" | grep -q -E '[0-9]{1,2}'`

if [ $? -ne 0 ]
then
	echo "Apache FlexiUnit release candidate to be in the range 1-99"
	exit 1;
fi

# Assumes FLEXUNIT_DEV_AREA has been set up and point to SVN checked out dev area

VERSION_DIR="${FLEXUNIT_DEV_AREA}/flexunit/${FLEXUNIT_VERSION}"
RC_DIR="${FLEXUNIT_DEV_AREA}/flexunit/${FLEXUNIT_VERSION}/rc${RELEASE_CANDIDATE}"
BIN_DIR="${FLEXUNIT_DEV_AREA}/flexunit/${FLEXUNIT_VERSION}/rc${RELEASE_CANDIDATE}/binaries"

function checkFile() {
	FILE="$1"
	
	HASH=`md5 -q "${FILE}"`
	CHECK=`cat "${FILE}.md5"`

	if [ "$HASH" != "$CHECK" ]
	then
		echo "${FILE} MD5 incorrect"
		exit 1;
	else
	   echo "${FILE} MD5 OK";
	fi

	gpg --verify "${FILE}.asc"

}

checkFile "${RC_DIR}/apache-flexunit-${FLEXUNIT_VERSION}-${FLEX_VERSION}-src.tar.gz"
checkFile "${RC_DIR}/apache-flexunit-${FLEXUNIT_VERSION}-${FLEX_VERSION}-src.zip"

checkFile "${BIN_DIR}/apache-flexunit-${FLEXUNIT_VERSION}-${FLEX_VERSION}-bin.tar.gz"
checkFile "${BIN_DIR}/apache-flexunit-${FLEXUNIT_VERSION}-${FLEX_VERSION}-bin.zip"

