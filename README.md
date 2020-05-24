
Netapp Test Automation
======================

This Framework contains automated test cases written in robotframework supported by custom python libraries.

These tests can be performed on newly deployed Netapp cluster to check if the cluster is deployed as per requirements/expectation.

Current testcases are based on netapp cli and supported with NetApp Release 8.3.2,
It can support further releases as well, based on cli changes the test verifications need to be modified.

Technologies
============

> Language: **Python**

> Test automation framework: **Robotframework** 

> Libraries: **SSHlibrary**

Directory structure
===================
```
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
```
	
Pre-requisite
=============

> Before executing test cases please fill the parameter details in config.yaml file.

> Install the required framework libraries, defined in requirement.txt using below command.

  `pip install -r requirements.txt`

> Below python packages are used in this framework:
```
robotframework
SSHlibrary
Process
pyyaml
sphinx
```


Execution
=========

To execute test cases use below commands:

go to netapp_automation directory

- Execution through tags
  - robot -i <tag_name> -P . -d artifacts <robot_suite_file_name>
    
    **example: robot -i DEMO -P . -d artifacts \testsuites\\*.robot**
  
- Execution through testcase
  - robot -t <testcase_name> -P . -d artifacts <robot_suite_file_name>
    
    **example: robot -t TC_ACCESS_01 -P . -d artifacts testsuites\TS_NETAPP_ACCESS.robot**
  
NOTE: go to Netapp_test_automation dir and execute above cmds.
      
      ```
      -i option is for include tag
      -t option is for testcase
      -p option is to add robot current path to pythonpath.
      -d option is to provide results dir
      ```
      
  
Conclusion
==========

This is basically a reference framework to create any test automation framework (specifically based on robot). Modular architecture approach has been followed in this framework, wherein lib, testdata, artifacts and testsuites are separated. To make the framework generic config data is maintained in config.yaml file.  
	



	
