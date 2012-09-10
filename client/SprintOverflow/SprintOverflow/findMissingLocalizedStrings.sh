#!/bin/bash

result=$(find . -type f -exec grep -n @\" {} /dev/null  \; | egrep -v 'NSLocalizedString|NSLog|JSON/SBJ' | egrep -v "soConstants.[mh]") 2>/dev/null

if [ "$result" = "" ]; then
	echo No missing localized strings in source
else
	echo Found missing localized strings
	echo $result
fi
