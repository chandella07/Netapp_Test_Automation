*** Settings ***
Documentation     These tests are related to checking Access    New functionality of Netapp.
...               It covers tests related to cluster show, status and nodes.
Library           SSHLibrary    30 seconds
Variables         ../config_data/config.yaml
Library           ../lib/Netapplib.py
Library           Process
Library           robot.libraries.Collections
Suite Setup       Run Keywords     Open Connection And Login    ${System.Cluster_IP}    ${System.Username}     ${System.Password}
...    AND        Check Version    ${System.Netapp_Release}
Suite Teardown    Close All Connections


*** Test Cases ***
TC_ACCESS_01
    [Documentation]    *Title* : Check SSH login fuctionality to cluster. 
    ...    *Objective*: Command to check the cluster SSH login.
    ...    *Expected Output*: Return output should contain Application name as ssh.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.	
    [Tags]    Netapp    Access
    [Setup]    Run Keywords     Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ...    AND    Set Terminal    set -showallfields true
    ...    AND    Set Terminal    rows 0
    write    login show -vserver ${System.Cluster_name} -user-or-group-name ${System.Username} -application ${Applications.app_ssh}
    ${stdout}=     Read Until Prompt
    &{actual_dict}=    Get Dict Column Wise    ${stdout}    col_num=2    start_line=1    end_line=-2
    ${actual_value}=    Get Column Value By Index        ${actual_dict}    heading=application    index=0
    Should Be Equal As Strings    ${actual_value}      ${Applications.app_ssh}
    [Teardown]    Close All Connections


TC_ACCESS_02
    [Documentation]    *Title* : Check Console login fuctionality to cluster.
    ...    *Objective*: Command to check the cluster Console login.
    ...    *Expected Output*: Return output should contain Application name as console.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Access
    [Setup]    Run Keywords     Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ...    AND    Set Terminal    set -showallfields true
    ...    AND    Set Terminal    rows 0
    write    login show -vserver ${System.Cluster_name} -user-or-group-name ${System.Username} -application ${Applications.app_console}
    ${stdout}=     Read Until Prompt
    &{actual_dict}=    Get Dict Column Wise    ${stdout}    col_num=2    start_line=1    end_line=-2
    ${actual_value}=    Get Column Value By Index        ${actual_dict}    heading=application    index=0
    Should Be Equal As Strings    ${actual_value}      ${Applications.app_console}
    [Teardown]    Close All Connections


TC_ACCESS_03
    [Documentation]    *Title* : Check service-processor login fuctionality to cluster.
    ...    *Objective*: Command to check the cluster service-processor login.
    ...    *Expected Output*: Return output should contain Application name as service-processor.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Access
    [Setup]    Run Keywords     Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ...    AND    Set Terminal    set -showallfields true
    ...    AND    Set Terminal    rows 0
    write    login show -vserver ${System.Cluster_name} -user-or-group-name ${System.Username} -application ${Applications.app_sp}
    ${stdout}=     Read Until Prompt
    &{actual_dict}=    Get Dict Column Wise    ${stdout}    col_num=2    start_line=1    end_line=-2
    ${actual_value}=    Get Column Value By Index        ${actual_dict}    heading=application    index=0
    Should Be Equal As Strings    ${actual_value}      ${Applications.app_sp}
    [Teardown]    Close All Connections


TC_ACCESS_04
    [Documentation]    *Title* : Check login user identity.
    ...    *Objective*: Command to check login user identitiy.
    ...    *Expected Output*: Return output should contain login user name.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Access
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ${stdout}=    Execute Command    login whoami
    Should contain    ${stdout}    User: ${System.Username}
    [Teardown]    Close All Connections


TC_ACCESS_05
    [Documentation]    *Title* : Check System timeout.
    ...    *Objective*: Command to check system timeout after SSH login.
    ...    *Expected Output*: Return output should contain system timeout as 30 minutes.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Access
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ${stdout}=    Execute Command    system timeout show
    Should contain    ${stdout}    ${Access.Timeout}
    [Teardown]    Close All Connections


TC_ACCESS_06
    [Documentation]    *Title* : Verify physical characteristics and options of the system.
    ...    *Objective*: Command to check OS version, Node serial num., Filer model, Firmware version, no. of disks and their capacity, Network cards, Capacity of NVRam.
    ...    *Expected Output*: Return output should contain above params as expectations.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) node should be configured.
    [Tags]    Netapp    Access
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{Node_dict}=    Get Dict From Node    Node
    : FOR    ${NODE}    IN    @{Node_dict.keys()}
    \    &{Node_val}=    Get Dict From Node    ${NODE}
    \    ${val}=    Get From Dictionary    ${Node_dict}    ${NODE}
    \    ${stdout}=    Execute Command    system node run -node ${val} -command sysconfig -v
    \    Should contain    ${stdout}    ${System.Netapp_Release}
    \    should contain    ${stdout}    System Serial Number: ${Node_val.serial_number}
    \    should contain    ${stdout}    Model Name:         ${Node_val.filer_model}
    \    should contain    ${stdout}    Firmware Version:   ${Node_val.firmware_version}
    \    should contain    ${stdout}    Memory Size:        ${Node_val.disk_capacity}
    \    should contain    ${stdout}    NVMEM Size:         ${Node_val.capacity_of_NVRam}
    [Teardown]    Close All Connections


TC_ACCESS_07
    [Documentation]    *Title* : Verify if any conflicts or configuration errors on nodes.
    ...    *Objective*: Command to check for any configuration errors on nodes.
    ...    *Expected Output*: Return output should not contain any errors.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) node should be configured.
    [Tags]    Netapp    Access
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    : FOR    ${NODE}    IN    @{Node.values()}
    \    ${stdout}=    Execute Command    system node run -node ${NODE} -command sysconfig -c
    \    Should contain    ${stdout}    There are no configuration errors
    [Teardown]    Close All Connections


TC_ACCESS_08
    [Documentation]    *Title* : Verifying the status of license.
    ...    *Objective*: Checking the license status.
    ...    *Expected Output*: Return output should contain license.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Access
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    : FOR    ${val}    IN    @{license.values()}
    \    ${stdout}=    Execute Command    system license status show -package ${val}
    \    Should contain    ${stdout}    Package Name: ${val}
    \    Should contain    ${stdout}    Licensed Method: license
    [Teardown]    Close All Connections


TC_ACCESS_09
    [Documentation]    *Title* : Verify takeover option with storage failover show command.
    ...    *Objective*: Command to check failover status.
    ...    *Expected Output*: Return output should contain partner node and takeover state.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) node should be configured.
    [Tags]    Netapp    Access    HA
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{Node_dict}=    Get Dict From Node    Node
    : FOR    ${NODE}    IN    @{Node_dict.keys()}
    \    ${val}=    Get From Dictionary    ${node_dict}    ${NODE}
    \    Verify Takeover Option    ${NODE}    ${val}
    [Teardown]    Close All Connections


TC_ACCESS_10
    [Documentation]    *Title* : Verify ACP status on nodes.
    ...    *Objective*: Command to check for ACP status on nodes.
    ...    *Expected Output*: Return output should not contain ACP enabled and status as Full Connectivity.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) node should be configured.
    [Tags]    Netapp    Access
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    : FOR    ${NODE}    IN    @{Node.values()}
    \    ${stdout}=    Execute Command    system node run -node ${NODE} storage show acp
    \    Should contain    ${stdout}    Alternate Control Path:          Enabled
    \    Should contain    ${stdout}    ACP Connectivity Status:         Full Connectivity
    [Teardown]    Close All Connections


TC_ACCESS_11
    [Documentation]    *Title* : Verify the state of the disk on node.
    ...    *Objective*: Command to check state of the disk on node.
    ...    *Expected Output*: Return output should not contain any broken disk.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) node should be configured.
    [Tags]    Netapp    Access    DEMO
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    : FOR    ${NODE}    IN    @{Node.values()} 
    \    ${stdout}=    Execute Command    system node run -node ${NODE} vol status -f
    \    Should contain    ${stdout}    Broken disks (empty)
    [Teardown]    Close All Connections


TC_ACCESS_12
    [Documentation]    *Title* : Verify assignation of disks.
    ...    *Objective*: Command to check disk assignment.
    ...    *Expected Output*: Return output should not contain any unassigned disk.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Access
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    : FOR    ${NODE}    IN    @{Node.values()}
    \    ${stdout}=    Execute Command    storage disk show -nodelist ${NODE} -container-type unassigned
    \    Should contain    ${stdout}    There are no entries matching your query
    [Teardown]    Close All Connections


TC_ACCESS_13
    [Documentation]    *Title* : Verify event logs with severity : EMERGENCY.
    ...    *Objective*: Command to check event logs with severity : EMERGENCY.
    ...    *Expected Output*: Return output should not contain any errors in logs.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Access
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ${stdout}=    Execute Command    event log show -severity EMERGENCY
    Should contain    ${stdout}    There are no entries matching your query
    [Teardown]    Close All Connections


TC_ACCESS_14
    [Documentation]    *Title* : Verify event logs with severity : ALERT.
    ...    *Objective*: Command to check event logs with severity : ALERT.
    ...    *Expected Output*: Return output should not contain any errors in logs.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Access
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ${stdout}=    Execute Command    event log show -severity ALERT
    Should contain    ${stdout}    There are no entries matching your query
    [Teardown]    Close All Connections


TC_ACCESS_15
    [Documentation]    *Title* : Verify event logs with severity : CRITICAL.
    ...    *Objective*: Command to check event logs with severity : CRITICAL.
    ...    *Expected Output*: Return output should not contain any errors in logs.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Access
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ${stdout}=    Execute Command    event log show -severity CRITICAL
    Should contain    ${stdout}    There are no entries matching your query
    [Teardown]    Close All Connections


TC_ACCESS_16
    [Documentation]    *Title* : Verify event logs with severity : ERROR.
    ...    *Objective*: Command to check event logs with severity : ERROR.
    ...    *Expected Output*: Return output should contain no error.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Access
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ${stdout}=    Execute Command    event log show -severity ERROR
    Should Contain    ${stdout}    There are no entries matching your query
    [Teardown]    Close All Connections


TC_ACCESS_17
    [Documentation]    *Title* : Verify that event logs are getting generated.
    ...    *Objective*: Command to check event logs.
    ...    *Expected Output*: Return output should not contain event logs.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Access
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ${stdout}=    Execute Command    event log show
    Should contain    ${stdout}    Severity
    Should contain    ${stdout}    Event
    [Teardown]    Close All Connections


TC_ACCESS_18
    [Documentation]    *Title* : Verify Network ports.
    ...    *Objective*: Command to check network ports and their status.
    ...    *Expected Output*: Return output should contain node ports and their status as UP.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) node should be configured.
    [Tags]    Netapp    Access
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{Node_dict}=    Get Dict From Node    Node
    : FOR    ${NODE}    IN    @{Node_dict.keys()}
    \    ${val}=    Get From Dictionary    ${node_dict}    ${NODE}
    \    Verify Network Interface    ${NODE}    ${val}
    [Teardown]    Close All Connections


TC_ACCESS_19
    [Documentation]    *Title* : Verify Network interface properties.
    ...    *Objective*: Command to check network ports and their properties.
    ...    *Expected Output*: Return output should contain node ports and their properties.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) node should be configured.
    [Tags]    Netapp    Access
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{Node_dict}=    Get Dict From Node    Node
    : FOR    ${NODE}    IN    @{Node_dict.keys()}
    \    ${val}=    Get From Dictionary    ${node_dict}    ${NODE}
    \    Verify Network Interface Properties    ${NODE}    ${val}    
    [Teardown]    Close All Connections


TC_ACCESS_20
    [Documentation]    *Title* : Verify assignment of IP address to each network interface.
    ...    *Objective*: Command to check IP address to each network interface.
    ...    *Expected Output*: Return output should contain IP address of each interface.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Access
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{Node_dict}=    Get Dict From Node    Node
    : FOR    ${NODE}    IN    @{Node_dict.keys()}
    \    ${val}=    Get From Dictionary    ${node_dict}    ${NODE}
    \    Verify Interface IP    ${NODE}    ${val}
    [Teardown]    Close All Connections


TC_ACCESS_21
    [Documentation]    *Title* : Verify the VLAN.
    ...    *Objective*: Command to check VLAN.
    ...    *Expected Output*: Return output should contain VLAN name and id.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) VLAN should be configured.
    [Tags]    Netapp    Access
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{Node_dict}=    Get Dict From Node    Node
    : FOR    ${NODE}    IN    @{Node_dict.keys()}
    \    ${val}=    Get From Dictionary    ${node_dict}    ${NODE}
    \    Verify Network VLAN    ${NODE}    ${val}
    [Teardown]    Close All Connections


TC_ACCESS_22
    [Documentation]    *Title* : Verify Routing groups on cluster.
    ...    *Objective*: Command to check routing groups.
    ...    *Expected Output*: Return output should not contain routing groups.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) NTP should be configured.
    [Tags]    Netapp    Access
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ${stdout}=    Execute Command    network routing-groups show -vserver ${System.Cluster_name} -fields routing-group
    &{route_dict}=    Get Dict From Node    Cluster_routing_groups
    : FOR    ${ROUTE}    IN    @{route_dict.keys()}
    \    ${val}=    Get From Dictionary    ${route_dict}    ${ROUTE}
    \    Should contain    ${stdout}    ${val}
    [Teardown]    Close All Connections


TC_ACCESS_23
    [Documentation]    *Title* : Verify the DNS.
    ...    *Objective*: Command to check DNS.
    ...    *Expected Output*: Return output should show DNS as alive.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) DNS should be configured.
    [Tags]    Netapp    Access
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    : FOR    ${NODE}    IN    @{Node.values()}
    \    ${stdout}=    Execute Command    network ping -node ${NODE} -destination ${DNS.DNS_address} 
    \    Should contain    ${stdout}    ${DNS.DNS_address} is alive
    [Teardown]    Close All Connections


TC_ACCESS_24
    [Documentation]    *Title* : Verify NTP config.
    ...    *Objective*: Command to check the NTP config status.
    ...    *Expected Output*: Return output should contain NTP config status.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) NTP should be configured.
    [Tags]    Netapp    Access
    [Setup]    Run Keywords     Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ...    AND    Set Diag Mode
    #Set Client Configuration    prompt=::*>
    write    system services ntp config show
    ${stdout}=     Read Until prompt
    Should Contain    ${stdout}    NTP Enabled: true
    [Teardown]    Close All Connections


TC_ACCESS_25
    [Documentation]    *Title* : Verify NTP server.
    ...    *Objective*: Command to check NTP server details.
    ...    *Expected Output*: Return output should not contain NTP server info.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) NTP should be configured.
    [Tags]    Netapp    Access
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ${stdout}=    Execute Command    cluster time-service ntp server show -fields server
    Should contain    ${stdout}    ${NTP.SERVER_IP}
    [Teardown]    Close All Connections


TC_ACCESS_26
    [Documentation]    *Title* : Verify date and time.
    ...    *Objective*: Command to check date and time.
    ...    *Expected Output*: Return output should contain date and time as on NTP server.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) nodes should be configured.
    [Tags]    Netapp    Access
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ${set_date}=     Run Process    ntpdate     -u     ${NTP.SERVER_IP}    stderr=STDOUT    timeout=15s
    Log    ${set_date.stdout} 
    ${datestamp}=     Run Process    date    -u    stderr=STDOUT    timeout=15s
    Log    ${datestamp.stdout}
    ${date}=    Get Date From Timestamp    ${datestamp.stdout}
    ${time}=    Get Time From Timestamp    ${datestamp.stdout}
    &{Node_dict}=    Get Dict From Node    Node
    : FOR    ${NODE}    IN    @{Node_dict.keys()}
    \    &{Node_val}=    Get Dict From Node    ${NODE}
    \    ${val}=    Get From Dictionary    ${node_dict}    ${NODE}
    \    ${stdout}=    Execute Command    cluster date show -node ${val} -fields utcdateandtime
    \    ${node_date}=    Get Date From Timestamp    ${stdout}
    \    ${node_time}=    Get Time From Timestamp    ${stdout}
    \    Should Be Equal    ${date}    ${node_date}
    \    ${status}=    Compare Time    ${time}    ${node_time}
    \    Should Be True    ${status}
    [Teardown]    Close All Connections


TC_ACCESS_27
    [Documentation]    *Title* : Verify timezone.
    ...    *Objective*: Command to check timezone.
    ...    *Expected Output*: Return output should contain timezone info.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) timezone should be configured.
    [Tags]    Netapp    Access
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{Node_dict}=    Get Dict From Node    Node
    : FOR    ${NODE}    IN    @{Node_dict.keys()}
    \    &{Node_val}=    Get Dict From Node    ${NODE}
    \    ${val}=    Get From Dictionary    ${node_dict}    ${NODE}
    \    ${stdout}=    Execute Command    node run -node ${val} timezone
    \    Should contain    ${stdout}    Current time zone is ${Node_val.timezone}
    [Teardown]    Close All Connections


