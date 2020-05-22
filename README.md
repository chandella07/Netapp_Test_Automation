
Netapp Test Automation
======================

This Framework contains automated test cases which can be performed on newly deployed Netapp cluster to check if the cluster is deployed as per requirements/expectation.

Technologies
============

Language: Python
Test automation: Robotframework
Libraries: SSHlibrary

Directory structure
===================

+-- artifacts
¦   +-- output.xml
+-- config_data
¦   +-- config.yaml
+-- Framework_ppt
¦   +-- Netapp_Test_Automation.pptx
+-- lib
¦   +-- __init__.py
¦   +-- Customlib.py
¦   +-- Keywords.py
¦   +-- Netapplib.py
¦   +-- Readdata.py
+-- testsuites
    +-- TS_NETAPP_ACCESS.robot
    +-- TS_NETAPP_CXN.robot
    +-- TS_NETAPP_SECURITY.robot
    +-- TS_NETAPP_STORAGE.robot
	

Execution
=========

To execute test cases use below commands:

go to netapp_automation directory

- Execution through tags
  - robot -i <tag_name> <robot_suite_file_name>
  example: robot -i DEMO *.robot
  
- Execution through testcase
  - robot -t <testcase_name> <robot_suite_file_name>
  example: robot -t TC_ACCESS_01 TS_NETAPP_ACCESS.robot
  
NOTE: Suite file name should be given with path, if not immediate directory.
  

	



	
