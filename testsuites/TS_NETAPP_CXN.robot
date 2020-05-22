*** Settings ***
Documentation     These tests are related to checking Interconnection functionality of Netapp.
...               It covers tests related to cluster, vserver, status and nodes.
Library           SSHLibrary    30 seconds
Variables         ${CURDIR}/../config_data/config.yaml
Library           ${CURDIR}/../lib/Netapplib.py
Library           robot.libraries.Collections
Suite Setup       Run Keywords     Open Connection And Login    ${System.Cluster_IP}    ${System.Username}     ${System.Password}
...    AND        Check Version    ${System.Netapp_Release}
Suite Teardown    Close All Connections


*** Test Cases ***
TC_CXN_01
    [Documentation]    *Title* : Verify cluster identity. 
    ...    *Objective*: Command to check cluster identity.
    ...    *Expected Output*: Return output should contain cluster name, UUID and serial number.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.	
    [Tags]    Netapp    Interconnection
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ${stdout}=    Execute Command    cluster identity show
    Should contain    ${stdout}    ${System.Cluster_name}
    Should contain    ${stdout}    ${System.Cluster_UUID}
    Should contain    ${stdout}    ${System.Cluster_Serial_Number}
    [Teardown]    Close All Connections


TC_CXN_02
    [Documentation]    *Title* : Verify Snapmirror relationship and initialization job phase.
    ...    *Objective*: Command to check snapmirror relationship and initialization job phase.
    ...    *Expected Output*: Return output should contain state as snapmirrored or no entry if early.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) snapmirror should be configured.
    [Tags]    Netapp    Interconnection
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ${stdout}=    Execute Command    job schedule show -name 5min
    Should contain    ${stdout}    Schedule Name: 5min
    Should contain    ${stdout}    Schedule Type: cron
    &{SVM_dict}=    Get Dict From Node    SVM
    : FOR    ${svm}    IN    @{SVM_dict.keys()}
    \    &{SVM_val}=    Get Dict From Node    ${svm}
    \    ${val}=    Get From Dictionary    ${SVM_dict}    ${svm}
    \    ${stdout}=    Execute Command    snapmirror show -vserver ${val}
    \    ${status}=    Check Multiple Should Contains    ${stdout}    There are no entries matching your query    Snapmirrored
    \    Should Be True    ${status}
    [Teardown]    Close All Connections


TC_CXN_03
    [Documentation]    *Title* : Verify Snapmirror Activation.
    ...    *Objective*: Command to check Snapmirror Activation.
    ...    *Expected Output*: Return output should contain Snapmirror Activation license.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) snapmirror should be configured.
    [Tags]    Netapp    Interconnection
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ${stdout}=    Execute Command    system license status show -package snapmirror
    Should contain    ${stdout}    Package Name: SnapMirror
    Should contain    ${stdout}    Licensed Method: license
    Should contain    ${stdout}    Expiration Date: -
    [Teardown]    Close All Connections


TC_CXN_04
    [Documentation]    *Title* : Check dashboard health status.
    ...    *Objective*: Command to check dashboard health status.
    ...    *Expected Output*: Return output should contain vserver health as OK and should not contain any error or issue.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) vservers should be configured.
    [Tags]    Netapp    Interconnection
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ${stdout}=    Execute Command    dashboard health vserver show
    Should Not Contain    ${stdout}    Issues:
    Should Not Contain    ${stdout}    Errors:
    &{SVM_dict}=    Get Dict From Node    SVM
    : FOR    ${svm}    IN    @{SVM_dict.keys()}
    \    &{SVM_val}=    Get Dict From Node    ${svm}
    \    ${val}=    Get From Dictionary    ${SVM_dict}    ${svm}
    \    ${stdout}=    Execute Command    dashboard health vserver show -vserver ${val} -fields vstatus,vhealth
    \    Should contain    ${stdout}    ok
    \    Should contain    ${stdout}    online
    [Teardown]    Close All Connections


TC_CXN_05
    [Documentation]    *Title* : Verify SNMP traps.
    ...    *Objective*: Command to check SNMP traps in event logs.
    ...    *Expected Output*: Return output should contain SNMP trap in event error logs.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Interconnection    DEMO
    [Setup]    Run Keywords    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ...    AND    Set Diag Mode
    write    event generate -messagename wafl.dir.link.warning -values "This is SNMP trap for automation"
    ${stdout}=     Read Until prompt
    sleep    4
    ${stdout}=    Execute Command     event log show -severity WARNING -fields time,messagename,event
    Should contain    ${stdout}    wafl.dir.link.warning
    Should contain    ${stdout}    This is SNMP trap for automation
    [Teardown]    Close All Connections


TC_CXN_10
    [Documentation]    *Title* : Verify SVM peering.
    ...    *Objective*: Command to check vservers SVM peering.
    ...    *Expected Output*: Return output should contain svm peer name and state as peered.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) svm peering should be configured.
    [Tags]    Netapp    Interconnection
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{SVM_dict}=    Get Dict From Node    SVM
    : FOR    ${svm}    IN    @{SVM_dict.keys()}
    \    ${val}=    Get From Dictionary    ${SVM_dict}    ${svm}
    \    Verify SVM Peering    ${svm}    ${val}
    [Teardown]    Close All Connections


TC_CXN_11
    [Documentation]    *Title* : Verify the activation and  configuration of NFS protocol.
    ...    *Objective*: Command to check SVM's NFS configuration.
    ...    *Expected Output*: Return output should contain NFS configuration if enabled else no entries should be there.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) NFS should be configured.
    [Tags]    Netapp    Interconnection
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{SVM_dict}=    Get Dict From Node    SVM
    : FOR    ${svm}    IN    @{SVM_dict.keys()}
    \    ${val}=    Get From Dictionary    ${SVM_dict}    ${svm}
    \    Verify NFS Configuration    ${svm}    ${val}
    [Teardown]    Close All Connections

TC_CXN_12
    [Documentation]    *Title* : Verify the activation and  configuration of CIFS protocol.
    ...    *Objective*: Command to check SVM's CIFS configuration.
    ...    *Expected Output*: Return output should contain CIFS configuration if enabled else no entries should be there.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) CIFS should be configured.
    [Tags]    Netapp    Interconnection
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{SVM_dict}=    Get Dict From Node    SVM
    : FOR    ${svm}    IN    @{SVM_dict.keys()}
    \    ${val}=    Get From Dictionary    ${SVM_dict}    ${svm}
    \    Verify CIFS Configuration    ${svm}    ${val}
    [Teardown]    Close All Connections


TC_CXN_13
    [Documentation]    *Title* : Verify the activation and  configuration of ISCSI protocol.
    ...    *Objective*: Command to check SVM's ISCSI configuration.
    ...    *Expected Output*: Return output should contain ISCSI configuration if enabled else no entries should be there.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) ISCSI should be configured.
    [Tags]    Netapp    Interconnection
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{SVM_dict}=    Get Dict From Node    SVM
    : FOR    ${svm}    IN    @{SVM_dict.keys()}
    \    ${val}=    Get From Dictionary    ${SVM_dict}    ${svm}
    \    Verify ISCSI Configuration    ${svm}    ${val}
    [Teardown]    Close All Connections


TC_CXN_14
    [Documentation]    *Title* : Verify the activation and  configuration of NDMP protocol.
    ...    *Objective*: Command to check SVM's NDMP configuration.
    ...    *Expected Output*: Return output should contain NDMP configuration if enabled else no entries should be there.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) NDMP should be configured.
    [Tags]    Netapp    Interconnection
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{SVM_dict}=    Get Dict From Node    SVM
    : FOR    ${svm}    IN    @{SVM_dict.keys()}
    \    ${val}=    Get From Dictionary    ${SVM_dict}    ${svm}
    \    Verify NDMP Configuration    ${svm}    ${val}
    [Teardown]    Close All Connections
