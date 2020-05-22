*** Settings ***
Documentation     These tests are related to checking Security functionality of Netapp.
...               It covers tests related to cluster show, status and nodes.
Library           SSHLibrary    30 seconds
Variables         ${CURDIR}/../config_data/config.yaml
#Library           ${CURDIR}/../lib/Customlib.py
Library           ${CURDIR}/../lib/Netapplib.py
#Library           ${CURDIR}/../lib/Readdata.py
Library           robot.libraries.Collections
Suite Setup       Run Keywords     Open Connection And Login    ${System.Cluster_IP}    ${System.Username}     ${System.Password}
...    AND        Check Version    ${System.Netapp_Release}
Suite Teardown    Close All Connections


*** Test Cases ***
TC_SECURITY_01
    [Documentation]    *Title* : Check System Health.
    ...    *Objective*: Command to check System health.
    ...    *Expected Output*: Return output should not contain System health status as OK.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Security
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ${stdout}=    Execute Command    system health status show
    Should contain    ${stdout}    ok
    [Teardown]    Close All Connections


TC_SECURITY_02
    [Documentation]    *Title* : Verify cluster configuration.
    ...    *Objective*: Command to check cluster configuration e.g HA.
    ...    *Expected Output*: Return output should contain expected fields e.g HA details.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) node should be configured.
    [Tags]    Netapp    Security    HA
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{Node_dict}=    Get Dict From Node    Node
    Verify Cluster Configuration    ${Node_dict}
    [Teardown]    Close All Connections
    

TC_SECURITY_03
    [Documentation]    *Title* : Check hw_assist on cluster (hwassist).
    ...    *Objective*: Command to check hw_assist on cluster.
    ...    *Expected Output*: Return output should contain hwassist partner nodes and status.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Security    HA
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ${stdout}=    Execute Command    hwassist show
    Should contain    ${stdout}    Hwassist Enabled : true
    Verify Hwassist Show    ${stdout}
    [Teardown]    Close All Connections


TC_SECURITY_04
    [Documentation]    *Title* : Check hw_assist on nodes (hwassist).
    ...    *Objective*: Command to check hw_assist on nodes.
    ...    *Expected Output*: Return output should contain Operation successful.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Security    HA
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{Node_dict}=    Get Dict From Node    Node
    : FOR    ${NODE}    IN    @{Node_dict.keys()}
    \    ${val}=    Get From Dictionary    ${node_dict}    ${NODE}
    \    Verify Hwassist Test   ${NODE}    ${val}
    [Teardown]    Close All Connections


#TC_SECURITY_05
#    [Documentation]    *Title* : Verify cluster failover is working correctly.
#    ...    *Objective*: Command to check cluster failover scenario.
#    ...    *Expected Output*: In this case, first nodeB takeover the aggr of nodeA and then give it back.
#    ...    *Prerequisite* :
#    ...    1.) cluster should be up and running.
#    ...    2.) HA should be configured.
#    [Tags]    Netapp    Security    HA
#    [Setup]    Open Connection And Log In    10.195.49.132    ${System.Username}    ${System.Password}
#    ${stdout}=    Execute Command    storage failover show
#    Should contain    ${stdout}    Connected to initenasnoine1b
#    Should contain    ${stdout}    Connected to initenasnoine1a
#    Set Client Configuration    prompt=:
#    write    storage failover takeover -ofnode initenasnoine1a
#    ${stdout}=     Read Until Prompt
#    Set Client Configuration    prompt=::>
#    write    y
#    ${stdout}=     Read Until Prompt
#    Close All Connections
#    sleep    420s
#    Open Connection And Log In    10.195.49.132    ${System.Username}    ${System.Password}
#    ${stdout}=    Execute Command    storage failover show
#    ${status}=    Check Multiple Should Contains    ${stdout}    Waiting for giveback    Unknown
#    Should Be True    ${status}
#    Should contain    ${stdout}    In takeover
#    ${stdout}=    Execute Command    storage failover giveback -ofnode initenasnoine1a
#    sleep    60s
#    ${stdout}=    Execute Command    storage failover show
#    Should contain    ${stdout}    Waiting for cluster applications
#    Should contain    ${stdout}    Partial giveback
#    sleep    420s
#    ${stdout}=    Execute Command    storage failover show
#    Should contain    ${stdout}    Connected to initenasnoine1b
#    Should contain    ${stdout}    Connected to initenasnoine1a
#    ${stdout}=    Execute Command    storage failover show-giveback -fields giveback-status
#    Should contain    ${stdout}    initenasnoine1a "No aggregates to give back"
#    Should contain    ${stdout}    initenasnoine1b "No aggregates to give back"
#    [Teardown]    Close All Connections


#TC_SECURITY_05
#    [Documentation]    *Title* : Verify cluster failover is working correctly.
#    ...    *Objective*: Command to check cluster failover scenario.
#    ...    *Expected Output*: In this case, first nodeB takeover the aggr of nodeA and then give it back.
#    ...    *Prerequisite* :
#    ...    1.) cluster should be up and running.
#    ...    2.) HA should be configured.
#    [Tags]    Netapp    Security    HA
#    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
#    ${stdout}=    Execute Command    storage failover show
#    Should contain    ${stdout}    Connected to ${Node.node2}
#    Should contain    ${stdout}    Connected to ${Node.node1}
#    Set Client Configuration    prompt=:
#    write    storage failover takeover -ofnode ${Node.node1}
#    ${stdout}=     Read Until Prompt
#    Set Client Configuration    prompt=::>
#    write    y
#    ${stdout}=     Read Until Prompt
#    Close All Connections
#    sleep    420s
#    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
#    ${stdout}=    Execute Command    storage failover show
#    ${status}=    Check Multiple Should Contains    ${stdout}    Waiting for giveback    Unknown
#    Should Be True    ${status}
#    Should contain    ${stdout}    In takeover
#    ${stdout}=    Execute Command    storage failover giveback -ofnode ${Node.node1}
#    sleep    60s
#    ${stdout}=    Execute Command    storage failover show
#    Should contain    ${stdout}    Waiting for cluster applications
#    Should contain    ${stdout}    Partial giveback
#    sleep    420s
#    ${stdout}=    Execute Command    storage failover show
#    Should contain    ${stdout}    Connected to ${Node.node2}
#    Should contain    ${stdout}    Connected to ${Node.node1}
#    ${stdout}=    Execute Command    storage failover show-giveback -fields giveback-status
#    Should contain    ${stdout}    ${Node.node1} "No aggregates to give back"
#    Should contain    ${stdout}    ${Node.node2} "No aggregates to give back"
#    [Teardown]    Close All Connections


TC_SECURITY_07
    [Documentation]    *Title* : Verify roles on cluster.
    ...    *Objective*: Command to check roles on cluster.
    ...    *Expected Output*: Return output should contain expected roles.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) node should be configured.
    [Tags]    Netapp    Security
    [Setup]    Run Keywords     Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ...    AND    Set Terminal    set -showallfields true
    ...    AND    Set Terminal    rows 0
    write    login role show -vserver ${System.Cluster_name} -fields role
    ${stdout}=     Read Until Prompt
    &{actual_dict}=    Get Dict Column Wise    ${stdout}    col_num=1    start_line=1    end_line=-3
    &{Role_dict}=    Get Dict From Node    Roles
    : FOR    ${ROLE}    IN    @{Role_dict.keys()}
    \    ${val}=    Get From Dictionary    ${Role_dict}    ${ROLE}
    \    @{expected_list}=    Create List    ${val}
    \    &{expected_dict}=    Create Dictionary    role=@{expected_list}
    \    ${status}=    Compare Dict Column Wise    ${expected_dict}    ${actual_dict}
    \    Should Be True    ${status}
    [Teardown]    Close All Connections


TC_SECURITY_08
    [Documentation]    *Title* : Verify Applications for admin account on cluster.
    ...    *Objective*: Command to check applications for admin account on cluster.
    ...    *Expected Output*: Return output should contain support applications for admin account.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) node should be configured.
    [Tags]    Netapp    Security
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{Applications_dict}=    Get Dict From Node    Applications
    : FOR    ${APP}    IN    @{Applications_dict.keys()}
    \    ${val}=    Get From Dictionary    ${Applications_dict}    ${APP}
    \    ${stdout}=    Execute Command     login show -vserver ${System.Cluster_name} -user-or-group-name admin -application ${val} -fields application,authmethod
    \    &{actual_dict}=    Get Dict Column Wise    ${stdout}    col_num=2    start_line=1    end_line=-1
    \    ${actual_value}=    Get Column Value By Index        ${actual_dict}    heading=application    index=0
    \    Should Be Equal As Strings    ${actual_value}      ${val}
    [Teardown]    Close All Connections


TC_SECURITY_09
    [Documentation]    *Title* : Verify Authentication method for applications on cluster with admin account.
    ...    *Objective*: Command to check applications auth method on cluster for admin account.
    ...    *Expected Output*: Return output should contain support applications auth method.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) node should be configured.
    [Tags]    Netapp    Security    DEMO
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{Applications_dict}=    Get Dict From Node    Applications
    : FOR    ${APP}    IN    @{Applications_dict.keys()}
    \    ${val}=    Get From Dictionary    ${Applications_dict}    ${APP}
    \    ${stdout}=    Execute Command     login show -vserver ${System.Cluster_name} -user-or-group-name admin -application ${val} -fields application,authmethod
    \    &{actual_dict}=    Get Dict Column Wise    ${stdout}    col_num=3    start_line=1    end_line=-1
    \    ${actual_value}=    Get Column Value By Index        ${actual_dict}    heading=authmethod    index=0
    \    Should Be Equal As Strings    ${actual_value}      ${admin_auth_method.method}
    [Teardown]    Close All Connections


TC_SECURITY_10
    [Documentation]    *Title* : Verify presence of special account.
    ...    *Objective*: Command to check presence of special account.
    ...    *Expected Output*: Return output should contain account username without any lock.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) node should be configured.
    [Tags]    Netapp    Security
    [Setup]    Run Keywords     Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ...    AND    Set Terminal    set -showallfields true
    ...    AND    Set Terminal    rows 0
    write    security login show -vserver ${System.Cluster_name} -username admin
    ${stdout}=     Read Until Prompt
    &{actual_dict}=    Get Dict Column Wise    ${stdout}    col_num=1    start_line=0    end_line=-3
    @{expected_list}=    Create List    admin
    &{expected_dict}=    Create Dictionary    user-or-group-name=@{expected_list}
    ${status}=    Compare Dict Column Wise    ${expected_dict}    ${actual_dict}
    Should Be True    ${status}
    &{actual_dict}=    Get Dict Column Wise    ${stdout}    col_num=5    start_line=0    end_line=-3
    @{expected_list}=    Create List    no
    &{expected_dict}=    Create Dictionary    acctlocked=@{expected_list}
    ${status}=    Compare Dict Column Wise    ${expected_dict}    ${actual_dict}
    Should Be True    ${status}
    @{expected_list}=    Create List    yes
    &{expected_dict}=    Create Dictionary    acctlocked=@{expected_list}
    ${status}=    Compare Dict Column Wise    ${expected_dict}    ${actual_dict}
    Should Not Be True    ${status}
    [Teardown]    Close All Connections


TC_SECURITY_06
    [Documentation]    *Title* : Verify changing standard user password.
    ...    *Objective*: Command to check change user password.
    ...    *Expected Output*: Return output should change user password successfully.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Security
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    Set Client Configuration    prompt=:
    write    login password -username ${System.Username} -vserver ${System.Cluster_name}
    ${stdout}=     Read Until prompt
    write    ${System.Password}
    ${stdout}=     Read Until prompt
    write    ${Password.password1}
    ${stdout}=     Read Until prompt
    write    ${Password.password1}
    Set Client Configuration    prompt=::>
    ${stdout}=     Read Until prompt
    Close All Connections
    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${Password.password1}
    Set Client Configuration    prompt=:
    write    login password -username ${System.Username} -vserver ${System.Cluster_name}
    ${stdout}=     Read Until prompt
    write    ${Password.password1}
    ${stdout}=     Read Until prompt
    write    ${Password.password2}
    ${stdout}=     Read Until prompt
    write    ${Password.password2}
    Set Client Configuration    prompt=::>
    ${stdout}=     Read Until prompt
    Close All Connections
    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${Password.password2}
    Set Client Configuration    prompt=:
    write    login password -username ${System.Username} -vserver ${System.Cluster_name}
    ${stdout}=     Read Until prompt
    write    ${Password.password2}
    ${stdout}=     Read Until prompt
    write    ${Password.password3}
    ${stdout}=     Read Until prompt
    write    ${Password.password3}
    Set Client Configuration    prompt=::>
    ${stdout}=     Read Until prompt
    Close All Connections
    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${Password.password3}
    Set Client Configuration    prompt=:
    write    login password -username ${System.Username} -vserver ${System.Cluster_name}
    ${stdout}=     Read Until prompt
    write    ${Password.password3}
    ${stdout}=     Read Until prompt
    write    ${Password.password4}
    ${stdout}=     Read Until prompt
    write    ${Password.password4}
    Set Client Configuration    prompt=::>
    ${stdout}=     Read Until prompt
    Close All Connections
    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${Password.password4}
    Set Client Configuration    prompt=:
    write    login password -username ${System.Username} -vserver ${System.Cluster_name}
    ${stdout}=     Read Until prompt
    write    ${Password.password4}
    ${stdout}=     Read Until prompt
    write    ${Password.password5}
    ${stdout}=     Read Until prompt
    write    ${Password.password5}
    Set Client Configuration    prompt=::>
    ${stdout}=     Read Until prompt
    Close All Connections
    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${Password.password5}
    Set Client Configuration    prompt=:
    write    login password -username ${System.Username} -vserver ${System.Cluster_name}
    ${stdout}=     Read Until prompt
    write    ${Password.password5}
    ${stdout}=     Read Until prompt
    write    ${Password.password6}
    ${stdout}=     Read Until prompt
    write    ${Password.password6}
    Set Client Configuration    prompt=::>
    ${stdout}=     Read Until prompt
    Close All Connections
    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${Password.password6}
    Set Client Configuration    prompt=:
    write    login password -username ${System.Username} -vserver ${System.Cluster_name}
    ${stdout}=     Read Until prompt
    write    ${Password.password6}
    ${stdout}=     Read Until prompt
    write    ${System.Password}
    ${stdout}=     Read Until prompt
    write    ${System.Password}
    Set Client Configuration    prompt=::>
    ${stdout}=     Read Until prompt
    [Teardown]    Close All Connections

