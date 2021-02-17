#!/bin/bash

 repo manifest --suppress-upstream-revision -r -o default_tmp.xml
 cp default_tmp.xml default.xml
 cp default_tmp.xml head-default.xml 
 rm default_tmp.xml
