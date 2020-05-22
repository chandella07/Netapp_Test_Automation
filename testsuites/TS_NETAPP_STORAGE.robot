*** Settings ***
Documentation     These tests are related to checking Access functionality of Netapp.
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
TC_STORAGE_01
    [Documentation]    *Title* : Verify the size of root volume.
    ...    *Objective*: Command to check size of root volume.
    ...    *Expected Output*: Return output should contain root volume size according to netapp model.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) node should be configured.
    [Tags]    Netapp    Storage
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{Node_dict}=    Get Dict From Node    Node
    : FOR    ${NODE}    IN    @{Node_dict.keys()}
    \    &{Node_val}=    Get Dict From Node    ${NODE}
    \    ${val}=    Get From Dictionary    ${node_dict}    ${NODE}
    \    ${stdout}=    Execute Command    volume show -node ${val} -volume ${Node_val.root_vol_name} -fields size,state
    \    &{actual_dict}=    Get Dict Column Wise    ${stdout}    col_num=3    start_line=0    end_line=-1
    \    ${actual_value}=    Get Column Value By Index        ${actual_dict}    heading=state    index=0
    \    Should Be Equal As Strings    ${actual_value}      online
    \    &{actual_dict}=    Get Dict Column Wise    ${stdout}    col_num=2    start_line=0    end_line=-1
    \    ${actual_value}=    Get Column Value By Index        ${actual_dict}    heading=size    index=0
    \    ${actual_value}=    Get Num    ${actual_value}
    \    ${expected_value}=     Get Num    ${Node_val.root_vol_size}
    \    Should Be True    ${actual_value} >= ${expected_value}
    [Teardown]    Close All Connections

    
TC_STORAGE_02
    [Documentation]    *Title* : Verify the snapreserve of the root volume. (with param snapshot-space-used)
    ...    *Objective*: Command to check snapreserve with snapshot-space-used param.
    ...    *Expected Output*: Return output should contain snapshot space used percentage.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) node should be configured.
    [Tags]    Netapp    Storage
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{Node_dict}=    Get Dict From Node    Node
    : FOR    ${NODE}    IN    @{Node_dict.keys()}
    \    &{Node_val}=    Get Dict From Node    ${NODE}
    \    ${val}=    Get From Dictionary    ${node_dict}    ${NODE}
    \    ${stdout}=    Execute Command    volume show -node ${val} -volume ${Node_val.root_vol_name} -fields snapshot-space-used
    \    &{actual_dict}=    Get Dict Column Wise    ${stdout}    col_num=2    start_line=0    end_line=-1
    \    ${actual_value}=    Get Column Value By Index        ${actual_dict}    heading=snapshot-space-used    index=0
    \    ${actual_value}=    Get Num    ${actual_value}
    \    ${expected_value}=     Get Num    ${Node_val.snapshot_space_used}
    \    Should Be True    ${actual_value} <= ${expected_value}
    [Teardown]    Close All Connections

TC_STORAGE_03
    [Documentation]    *Title* : Verify the snapreserve of the root volume. (with param percent-snapshot-space)
    ...    *Objective*: Command to check snapreserve with  percent-snapshot-space param.
    ...    *Expected Output*: Return output should contain  percent-snapshot-space.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) node should be configured.
    [Tags]    Netapp    Storage
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{Node_dict}=    Get Dict From Node    Node
    : FOR    ${NODE}    IN    @{Node_dict.keys()}
    \    &{Node_val}=    Get Dict From Node    ${NODE}
    \    ${val}=    Get From Dictionary    ${node_dict}    ${NODE}
    \    ${stdout}=    Execute Command    volume show -node ${val} -volume ${Node_val.root_vol_name} -fields percent-snapshot-space
    \    &{actual_dict}=    Get Dict Column Wise    ${stdout}    col_num=2    start_line=0    end_line=-1
    \    ${actual_value}=    Get Column Value By Index        ${actual_dict}    heading=percent-snapshot-space    index=0
    \    ${actual_value}=    Get Num    ${actual_value}
    \    ${expected_value}=     Get Num    ${Node_val.percent_snapshot_space}
    \    Should Be True    ${actual_value} <= ${expected_value}
    [Teardown]    Close All Connections

TC_STORAGE_04
    [Documentation]    *Title* : Verify the snapreserve of the root volume. (with param  show-space)
    ...    *Objective*: Command to check snapreserve with  show-space param.
    ...    *Expected Output*: Return output should contain snapreserve.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) node should be configured.
    [Tags]    Netapp    Storage
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{Node_dict}=    Get Dict From Node    Node
    : FOR    ${NODE}    IN    @{Node_dict.keys()}
    \    &{Node_val}=    Get Dict From Node    ${NODE}
    \    ${val}=    Get From Dictionary    ${node_dict}    ${NODE}
    \    ${stdout}=    Execute Command    volume show-space -vserver ${val} -volume ${Node_val.root_vol_name} -fields snapshot-reserve-percent
    \    &{actual_dict}=    Get Dict Column Wise    ${stdout}    col_num=2    start_line=0    end_line=-1
    \    ${actual_value}=    Get Column Value By Index        ${actual_dict}    heading=snapshot-reserve-percent    index=0
    \    ${actual_value}=    Get Num    ${actual_value}
    \    ${expected_value}=     Get Num    ${Node_val.snapshot_reserve_percent}
    \    Should Be True    ${actual_value} <= ${expected_value}
    [Teardown]    Close All Connections


TC_STORAGE_05
    [Documentation]    *Title* : Verify the aggregates.
    ...    *Objective*: Command to check aggregates on cluster.
    ...    *Expected Output*: Return output should contain all the aggregates.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Storage
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ${stdout}=    Execute Command    storage aggregate show -fields aggregate
    : FOR    ${aggr}    IN    @{Aggregate.values()}
    \    Should Contain    ${stdout}    ${aggr}
    [Teardown]    Close All Connections


TC_STORAGE_06
    [Documentation]    *Title* : Verify the configration of aggregates.
    ...    *Objective*: Command to check configration aggregates.
    ...    *Expected Output*: Return output should contain aggregate data as no. of disks, volumes and state of aggr.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Storage
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{Aggr_dict}=    Get Dict From Node    Aggregate
    : FOR    ${aggr}    IN    @{Aggr_dict.keys()}
    \    &{Aggr_val}=    Get Dict From Node    ${aggr}
    \    ${val}=    Get From Dictionary    ${Aggr_dict}    ${aggr}
    \    ${stdout}=    Execute Command    storage aggregate show -aggregate ${val}
    \    Should contain    ${stdout}    Aggregate: ${val}
    \    Should contain    ${stdout}    Number Of Disks: ${Aggr_val.number_of_disks}
    \    Should contain    ${stdout}    Number Of Volumes: ${Aggr_val.number_of_volumes}
    \    Should contain    ${stdout}    State: online
    [Teardown]    Close All Connections

TC_STORAGE_07
    [Documentation]    *Title* : Verify the raid type of aggregates.
    ...    *Objective*: Command to check raid type of aggregates.
    ...    *Expected Output*: Return output should contain aggregate raidtypes.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Storage
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{Aggr_dict}=    Get Dict From Node    Aggregate
    : FOR    ${aggr}    IN    @{Aggr_dict.keys()}
    \    &{Aggr_val}=    Get Dict From Node    ${aggr}
    \    ${val}=    Get From Dictionary    ${Aggr_dict}    ${aggr}
    \    ${stdout}=    Execute Command    storage aggregate show -aggregate ${val} -fields raidtype
    \    Should contain    ${stdout}    ${Aggr_val.raid_type}
    [Teardown]    Close All Connections

TC_STORAGE_08
    [Documentation]    *Title* : Verify the percent used space for aggregates
    ...    *Objective*: Command to check percentage used space for aggregates
    ...    *Expected Output*: Return output should contain  percent-used space as expected.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) node should be configured.
    [Tags]    Netapp    Storage    DEMO
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{Aggr_dict}=    Get Dict From Node    Aggregate
    : FOR    ${aggr}    IN    @{Aggr_dict.keys()}
    \    &{Aggr_val}=    Get Dict From Node    ${aggr}
    \    ${val}=    Get From Dictionary    ${Aggr_dict}    ${aggr}
    \    ${stdout}=    Execute Command    storage aggregate show -aggregate ${val} -fields percent-used
    \    &{actual_dict}=    Get Dict Column Wise    ${stdout}    col_num=1    start_line=0    end_line=-1
    \    ${actual_value}=    Get Column Value By Index        ${actual_dict}    heading=percent-used    index=0
    \    ${actual_value}=    Get Num    ${actual_value}
    \    ${expected_value}=     Get Num    ${Aggr_val.percent_space_used}
    \    Should Be True    ${actual_value} <= ${expected_value}
    [Teardown]    Close All Connections


TC_STORAGE_09
    [Documentation]    *Title* : Verify the state of aggregates.
    ...    *Objective*: Command to check state of aggregates.
    ...    *Expected Output*: Return output should contain aggregate state.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Storage
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{Aggr_dict}=    Get Dict From Node    Aggregate
    : FOR    ${aggr}    IN    @{Aggr_dict.keys()}
    \    &{Aggr_val}=    Get Dict From Node    ${aggr}
    \    ${val}=    Get From Dictionary    ${Aggr_dict}    ${aggr}
    \    ${stdout}=    Execute Command    storage aggregate show -aggregate ${val} -fields state
    \    Should contain    ${stdout}    online
    [Teardown]    Close All Connections


TC_STORAGE_10
    [Documentation]    *Title* : Check failover-groups.
    ...    *Objective*: Command to check failover-groups.
    ...    *Expected Output*: Return output should contain failover-groups names.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Storage    HA
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ${stdout}=    Execute Command    network interface failover-groups show -fields failover-group
    : FOR    ${fg}    IN    @{failover_groups.values()}
    \    Should Contain    ${stdout}    ${fg} 
    [Teardown]    Close All Connections


TC_STORAGE_11
    [Documentation]    *Title* : Verify SVM's names.
    ...    *Objective*: Command to check vservers names.
    ...    *Expected Output*: Return output should contain SVM's.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Storage
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    ${stdout}=    Execute Command    vserver show -fields vserver
    : FOR    ${svm}    IN    @{SVM.values()}
    \    Should Contain    ${stdout}    ${svm}
    [Teardown]    Close All Connections


TC_STORAGE_12
    [Documentation]    *Title* : Verify SVM configuration.
    ...    *Objective*: Command to check vservers SVM configuration.
    ...    *Expected Output*: Return output should contain svm configuration data as language,root volume.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Storage
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{SVM_dict}=    Get Dict From Node    SVM
    : FOR    ${svm}    IN    @{SVM_dict.keys()}
    \    &{SVM_val}=    Get Dict From Node    ${svm}
    \    ${val}=    Get From Dictionary    ${SVM_dict}    ${svm}
    \    ${stdout}=    Execute Command    vserver show -vserver ${val}
    \    Should contain    ${stdout}    Default Volume Language Code: ${SVM_val.language}
    \    Should contain    ${stdout}    Root Volume: ${SVM_val.root_vol_name}
    [Teardown]    Close All Connections


TC_STORAGE_13
    [Documentation]    *Title* : Verify SVM configuration for admin state and opertaional state.
    ...    *Objective*: Command to check vservers SVM configuration(admin and op. state).
    ...    *Expected Output*: Return output should contain svm configuration as admin state and oper state.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Storage
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{SVM_dict}=    Get Dict From Node    SVM
    : FOR    ${svm}    IN    @{SVM_dict.keys()}
    \    &{SVM_val}=    Get Dict From Node    ${svm}
    \    ${val}=    Get From Dictionary    ${SVM_dict}    ${svm}
    \    ${stdout}=    Execute Command    vserver show -vserver ${val}
    \    Should contain    ${stdout}    Vserver Admin State: running
    \    Should contain    ${stdout}    Vserver Operational State: running
    [Teardown]    Close All Connections


TC_STORAGE_14
    [Documentation]    *Title* : Verify SVM configuration for allowed protocols.
    ...    *Objective*: Command to check vservers SVM configuration for allowed protocols.
    ...    *Expected Output*: Return output should contain svm configuration data allowed protocols names.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Storage
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{SVM_dict}=    Get Dict From Node    SVM
    : FOR    ${svm}    IN    @{SVM_dict.keys()}
    \    ${val}=    Get From Dictionary    ${SVM_dict}    ${svm}
    \    Verify Protocols    ${svm}    ${val}    allowed
    [Teardown]    Close All Connections

TC_STORAGE_15
    [Documentation]    *Title* : Verify SVM configuration for disallowed protocols.
    ...    *Objective*: Command to check vservers SVM configuration for disallowed protocols.
    ...    *Expected Output*: Return output should contain svm configuration data disallowed protocols names.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Storage
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{SVM_dict}=    Get Dict From Node    SVM
    : FOR    ${svm}    IN    @{SVM_dict.keys()}
    \    ${val}=    Get From Dictionary    ${SVM_dict}    ${svm}
    \    Verify Protocols    ${svm}    ${val}    disallowed
    [Teardown]    Close All Connections


#TC_STORAGE_14
#    [Documentation]    *Title* : Verify SVM's root volumes details.
#    ...    *Objective*: Command to check vservers SVM volumes details.
#    ...    *Expected Output*: Return output should contain svm's volume details.
#    ...    *Prerequisite* :
#    ...    1.) cluster should be up and running.
#    ...    2.) cluster should be configured.
#    [Tags]    Netapp    Storage
#    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
#    &{SVM_dict}=    Get Dict From Node    SVM
#    : FOR    ${svm}    IN    @{SVM_dict.keys()}
#    \    ${val}=    Get From Dictionary    ${SVM_dict}    ${svm}
#    \    Verify SVM Volumes Details    ${svm}    ${val}
#    [Teardown]    Close All Connections


TC_STORAGE_16
    [Documentation]    *Title* : Verify SVM's LIF configuration.
    ...    *Objective*: Command to check vservers SVM's LIF configuration.
    ...    *Expected Output*: Return output should contain SVM's LIF details as in lif name, role, op. state and network address.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) svm lif should be configured.
    [Tags]    Netapp    Storage
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{SVM_dict}=    Get Dict From Node    SVM
    : FOR    ${svm}    IN    @{SVM_dict.keys()}
    \    ${val}=    Get From Dictionary    ${SVM_dict}    ${svm}
    \    Verify SVM LIF    ${svm}    ${val}
    [Teardown]    Close All Connections


TC_STORAGE_17
    [Documentation]    *Title* : Verify SVM's Routing groups.
    ...    *Objective*: Command to check vservers routing groups.
    ...    *Expected Output*: Return output should contain SVM's routing group.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) routing groups should be configured.
    [Tags]    Netapp    Storage
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{SVM_dict}=    Get Dict From Node    SVM
    : FOR    ${svm}    IN    @{SVM_dict.keys()}
    \    ${val}=    Get From Dictionary    ${SVM_dict}    ${svm}
    \    Verify SVM Routing Groups    ${svm}    ${val}
    [Teardown]    Close All Connections


TC_STORAGE_18
    [Documentation]    *Title* : Verify SVM's export policy.
    ...    *Objective*: Command to check vservers SVM export policy.
    ...    *Expected Output*: Return output should contain svm's policy names.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Storage
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{SVM_dict}=    Get Dict From Node    SVM
    : FOR    ${svm}    IN    @{SVM_dict.keys()}
    \    ${val}=    Get From Dictionary    ${SVM_dict}    ${svm}
    \    Verify SVM Export Policy    ${svm}    ${val}
    [Teardown]    Close All Connections


TC_STORAGE_19
    [Documentation]    *Title* : Verify SVM's volumes.
    ...    *Objective*: Command to check vservers SVM volumes.
    ...    *Expected Output*: Return output should contain svm's volume names.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Storage
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{SVM_dict}=    Get Dict From Node    SVM
    : FOR    ${svm}    IN    @{SVM_dict.keys()}
    \    ${val}=    Get From Dictionary    ${SVM_dict}    ${svm}
    \    Verify SVM Volumes    ${svm}    ${val}
    [Teardown]    Close All Connections


TC_STORAGE_20
    [Documentation]    *Title* : Verify percent used space for svm's root volume.
    ...    *Objective*: Command to check svm root volume percentage used space.
    ...    *Expected Output*: Return output should contain percentage used space for svm root volume.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Storage
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{SVM_dict}=    Get Dict From Node    SVM
    : FOR    ${svm}    IN    @{SVM_dict.keys()}
    \    &{SVM_val}=    Get Dict From Node    ${svm}
    \    ${val}=    Get From Dictionary    ${SVM_dict}    ${svm}
    \    ${stdout}=    Execute Command    volume show -vserver ${val} -volume ${SVM_val.root_vol_name} -fields percent-used
    \    &{actual_dict}=    Get Dict Column Wise    ${stdout}    col_num=2    start_line=0    end_line=-1
    \    ${actual_value}=    Get Column Value By Index        ${actual_dict}    heading=percent-used    index=0
    \    ${actual_value}=    Get Num    ${actual_value}
    \    ${expected_value}=     Get Num    ${SVM_val.root_vol_used_percentage}
    \    Should Be True    ${actual_value} <= ${expected_value}
    [Teardown]    Close All Connections


TC_STORAGE_21
    [Documentation]    *Title* : Verify SVM's root volume detail.
    ...    *Objective*: Command to check vservers SVM volumes details.
    ...    *Expected Output*: Return output should contain svm's volume details.
    ...    *Prerequisite* :
    ...    1.) cluster should be up and running.
    ...    2.) cluster should be configured.
    [Tags]    Netapp    Storage
    [Setup]    Open Connection And Log In    ${System.Cluster_IP}    ${System.Username}    ${System.Password}
    &{SVM_dict}=    Get Dict From Node    SVM
    : FOR    ${svm}    IN    @{SVM_dict.keys()}
    \    ${val}=    Get From Dictionary    ${SVM_dict}    ${svm}
    \    &{root_dict}=    Get Dict From Node    ${svm}
    \    Log     ${root_dict}
    \    ${root_vol_name}=    Get From Dictionary    ${root_dict}     root_vol_name
    \    ${root_vol_state}=    Get From Dictionary    ${root_dict}     root_vol_state
    \    ${root_vol_type}=    Get From Dictionary    ${root_dict}     root_vol_type
    \    ${root_vol_junction_path}=    Get From Dictionary    ${root_dict}     root_vol_junction_path
    \    ${stdout}=    Execute Command     volume show -vserver ${val} -volume ${root_vol_name} -fields state,type,language,junction-path

    \    Should contain    ${stdout}    ${root_vol_name}
    \    Should contain    ${stdout}    ${root_vol_type}
    \    Should contain    ${stdout}    ${root_vol_state}
    \    Should contain    ${stdout}    ${root_vol_junction_path}
    [Teardown]    Close All Connections



