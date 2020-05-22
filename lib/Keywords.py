from robot.libraries.BuiltIn import BuiltIn
from collections import OrderedDict
from Readdata import Readdata
from Customlib import Customlib
import re,sys

class Keywords(Readdata,Customlib):
    ''' Keyword class to implement various test keywords defined in robot test suites '''
 
    sshlib = BuiltIn().get_library_instance('SSHLibrary')

    
    def verify_network_interface(self,node,val):
        '''This method is used to verify network interface of nodes'''

        interface_name = node+"_interface"
        interface_list = Readdata().get_keys_from_node(interface_name)
        self.sshlib._log("Interface list is : %s" % interface_list)
        
        cmd = "network port show -node "+val+" -fields port"
        output = self.sshlib.execute_command(cmd)

        for interface in interface_list:
            BuiltIn().should_contain(output, "%s" % interface)
            self.sshlib._log("Found interface : %s" % interface)

    def verify_network_interface_properties(self,node,val):
        '''This method is used to verify network interface properties of nodes'''

        interface_name = node+"_interface"
        interface_list = Readdata().get_keys_from_node(interface_name)
        self.sshlib._log("Interface list is : %s" % interface_list)

        for interface in interface_list:
            cmd = "network port show -node "+val+" -port "+interface
            output = self.sshlib.execute_command(cmd)
            BuiltIn().should_contain(output, "Node: %s" % val)
            BuiltIn().should_contain(output, "Port: %s" % interface)
            BuiltIn().should_contain(output, "Link: up")
            self.sshlib._log("Found Port : %s with Link status : up" %interface)

    def verify_network_vlan(self,node,val):
        '''This method is used to verify network VLAN of nodes'''

        vlan_name = node+"_vlan"
        vlan_list = Readdata().get_dict_from_node(vlan_name)
        self.sshlib._log("vlan list is : %s" % vlan_list)
  
        cmd = "network port vlan show -node "+val+" -fields vlan-name,vlan-id"
        output = self.sshlib.execute_command(cmd)

        for vlan_name,vlan_id in vlan_list.items():
            BuiltIn().should_contain(output, val)
            BuiltIn().should_contain(output, vlan_name)
            BuiltIn().should_contain(output, vlan_id)
            self.sshlib._log("Found vlan_name : %s and vlan_id : %s" % (vlan_name,vlan_id))

    def verify_interface_ip(self,node,val):
        '''This method is used to verify network interface IP's of nodes'''

        interface_name = node+"_interface"
        interface_list = Readdata().get_dict_from_node(interface_name)
        self.sshlib._log("Interface list is : %s" % interface_list)
        
        for interface,ip in interface_list.items():
            cmd = "network interface show -curr-node "+val+" -curr-port "+interface+" -fields address"
            output = self.sshlib.execute_command(cmd)
            BuiltIn().should_contain(output, ip)
            self.sshlib._log("Found IP : %s" % ip)

    def verify_protocols(self,svm,val,flag):
        '''This method is used to verify protocols on svm'''

        protocol_name = svm+"_"+flag+"_protocols"
        protocols_list = Readdata().get_values_from_node(protocol_name)
        if protocols_list == ['']:
            self.sshlib._log("No Protocol found in yaml for '%s' category" %flag)
        else:
            self.sshlib._log("Protocols list is : %s" % protocols_list)
            if flag=='allowed':
                cmd = "vserver show -vserver "+val+" -fields allowed-protocols"
            else:
                cmd = "vserver show -vserver "+val+" -fields disallowed-protocols"
            output = self.sshlib.execute_command(cmd)

            for protocol in protocols_list:
                BuiltIn().should_contain(output, protocol)
                self.sshlib._log("Protocol found : %s" % protocol)


    def verify_svm_volumes(self,svm,val):
        '''This method is used to verify svm's volumes'''

        volume_name = svm+"_volumes"
        volume_list = Readdata().get_values_from_node(volume_name)
        self.sshlib._log("Volume list is : %s" % volume_list)
        cmd = "volume show -vserver "+val
        output = self.sshlib.execute_command(cmd)

        for volume in volume_list:
            BuiltIn().should_contain(output, volume)
            self.sshlib._log("Volume found : %s" % volume)

    def verify_svm_routing_groups(self,svm,val):
        '''This method is used to verify svm's routing groups'''

        route_name = svm+"_routing_groups"
        route_list = Readdata().get_values_from_node(route_name)
        self.sshlib._log("Expected Routing Groups : %s" % route_list)
        cmd = "network routing-groups show -vserver "+val+" -fields routing-group"
        output = self.sshlib.execute_command(cmd)

        for route in route_list:
            BuiltIn().should_contain(output, route)
            self.sshlib._log("routing group found : %s" % route)

    def verify_svm_lif(self,svm,val):
        '''This method is used to verify svm's lif'''
        
        lif_name = svm+"_lif"
        lif_dict = Readdata().get_dict_from_node(lif_name)
        self.sshlib._log("Expected lif's on svm '%s' is : '%s'" % (val,lif_dict))

        for lif_name,lif_IP in lif_dict.items():
            cmd = "network interface show -vserver "+val+" -lif "+lif_name
            output = self.sshlib.execute_command(cmd)
            BuiltIn().should_contain(output, lif_name)
            self.sshlib._log("lif name found : %s" % lif_name)
            BuiltIn().should_contain(output, lif_IP)
            self.sshlib._log("lif IP found : %s" % lif_IP)
            BuiltIn().should_contain(output, "Operational Status: up")
            self.sshlib._log("lif operational state found as 'UP'")

    def verify_svm_export_policy(self,svm,val):
        '''This method is used to verify svm's export policy names'''

        svm_details = Readdata().get_dict_from_node(svm)
        if svm_details["export_policy"].lower() == "yes":
            self.sshlib._log("Export policy status True in yaml")

            policy_name = svm+"_export-policy"
            policy_list = Readdata().get_values_from_node(policy_name)
            self.sshlib._log("Policy list is : %s" % policy_list)
            cmd = "vserver export-policy rule show -vserver "+val+" -fields policyname"
            output = self.sshlib.execute_command(cmd)

            for policy in policy_list:
                BuiltIn().should_contain(output, policy)
                self.sshlib._log("Policy found : %s" % policy)
        else:
            self.sshlib._log("Export policy status False in yaml")

    def verify_svm_peering(self,svm,val):
        '''This method is used to verify svm peering'''

        svm_details = Readdata().get_dict_from_node(svm)
        if svm_details["peering"].lower() == "yes":
            self.sshlib._log("Peering status True in yaml")
            
            peer_name = svm+"_peering"
            peer_list = Readdata().get_values_from_node(peer_name)
            self.sshlib._log("Peer is : %s" % peer_list)
            cmd = "vserver peer show -vserver "+val
            output = self.sshlib.execute_command(cmd)

            for peer in peer_list:
                BuiltIn().should_contain(output, peer)
                self.sshlib._log("Peer found : %s" % peer)
                BuiltIn().should_contain(output, "peered")
        else:
            self.sshlib._log("Peering status False in yaml")

    def verify_svm_volumes_details(self,svm,val):
        '''This method is used to verify svm's volumes'''
	
	volumes_name = svm+"_volumes"
        volumes_dict = Readdata().get_dict_from_node(volumes_name)
        self.sshlib._log("Volumes dict is : %s" % volumes_dict)
        for vol_key,vol_val in volumes_dict.items():
            vol_name = svm+"_"+vol_key+"_details"
            vol_details= Readdata().get_dict_from_node(vol_name)
            self.sshlib._log("Volume details for '%s' volume is  :- %s" % (vol_val,vol_details))
            cmd = "volume show -vserver "+val+" -volume "+vol_val+" -fields state,type,language,junction-path"
            output = self.sshlib.execute_command(cmd)
            
            for result in vol_details.values():
                BuiltIn().should_contain(output, result)
                self.sshlib._log("Found : %s" % result)
            

    def verify_cluster_configuration(self,dict1):
        '''This method is used for verifying configuartion of the cluster
           It checks the configuration based on no. of nodes'''

        nodes_count = len(dict1.keys())
        if nodes_count == 2:
            output = self.sshlib.execute_command("cluster ha show")
            BuiltIn().should_contain(output, "High Availability Configured: true")
            self.sshlib._log("cluster in HA pair")
        else:
            epsilon_node = Readdata().get_values_from_node("epsilon_node")
            for k,v in dict1.items():
                cmd = "cluster show -node "+v
                self.sshlib.execute_command(cmd)
                BuiltIn().should_contain("Node: %s" % v)
                self.sshlib._log("Found node name : %s" % v)
                BuiltIn().should_contain("Eligibility: true")
                self.sshlib._log("Found node Eligibility: true")
                BuiltIn().should_contain("Health: true")
                self.sshlib._log("Found node Health: true")
                if v == epsilon_node:
                    BuiltIn().should_contain("Epsilon: true")
                    self.sshlib._log("Found node Epsilon: true for node %s" % v)


    def verify_nfs_configuration(self,svm,val):
        '''This method is used to verify svm's NFS configuration'''

        svm_details = Readdata().get_dict_from_node(svm)
        if svm_details["nfs_enabled"].lower() == "yes":
            self.sshlib._log("NFS status is enabled in yaml")

            cmd = "vserver nfs show -instance -vserver "+val
            output = self.sshlib.execute_command(cmd)
            BuiltIn().should_contain(output, "General NFS Access: true")
        else:
            self.sshlib._log("NFS status is NOT enabled in yaml")
   
    
    def verify_cifs_configuration(self,svm,val):
        '''This method is used to verify svm's CIFS configuration'''

        svm_details = Readdata().get_dict_from_node(svm)
        if svm_details["cifs_enabled"].lower() == "yes":
            self.sshlib._log("CIFS status is enabled in yaml")

            cmd = "vserver cifs show -instance -vserver "+val
            output = self.sshlib.execute_command(cmd)
            BuiltIn().should_contain(output, "CIFS Server Administrative Status: up")
        else:
            self.sshlib._log("CIFS status is NOT enabled in yaml")

    
    def verify_iscsi_configuration(self,svm,val):
        '''This method is used to verify svm's ISCSI configuration'''

        svm_details = Readdata().get_dict_from_node(svm)
        if svm_details["iscsi_enabled"].lower() == "yes":
            self.sshlib._log("ISCSI status is enabled in yaml")

            cmd = "vserver iscsi show -instance -vserver "+val
            output = self.sshlib.execute_command(cmd)
            BuiltIn().should_contain(output, "Administrative Status: up")
        else:
            self.sshlib._log("ISCSI status is NOT enabled in yaml")


    def verify_ndmp_configuration(self,svm,val):
        '''This method is used to verify svm's ndmp configuration'''

        svm_details = Readdata().get_dict_from_node(svm)
        if svm_details["ndmp_enabled"].lower() == "yes":
            self.sshlib._log("NDMP status is enabled in yaml")

            cmd = "vserver ndmp show -instance -vserver "+val
            output = self.sshlib.execute_command(cmd)
            BuiltIn().should_contain(output, "Enable NDMP on Vserver: true")
        else:
            self.sshlib._log("NDMP status is NOT enabled in yaml")
   

    def verify_hwassist_show(self,output):
        '''This method is used to verify the hwassist show output
           in order to check the partner nodes'''
        
        node_dict = Readdata().get_dict_from_node("Node")
        for node,detail in node_dict.items():
            val = Readdata().get_dict_from_node(node)
            self.sshlib._log("Checking node : '%s'" %node_dict[node])            
            if val["HA_pair"].lower() == "yes":
                self.sshlib._log("Node is in HA pair mentioned in yaml")
                BuiltIn().should_contain(output, "Partner : "+val["Partner_node"])
                self.sshlib._log("partner node found '%s'" %val["Partner_node"])
            else:
                self.sshlib._log("Node not in HA pair as mentioned in yaml")

    def verify_hwassist_test(self,node,val):
        '''This method is used to verify the hwassist on each node'''

        node_details = Readdata().get_dict_from_node(node)
        self.sshlib._log("Checking node : '%s'" %val)
        if node_details["HA_pair"].lower() == "yes":
            self.sshlib._log("Node is in HA pair mentioned in yaml")

            cmd = "hwassist test -node "+val
            output = self.sshlib.execute_command(cmd)
            BuiltIn().should_contain(output, "Operation successful")
        else:
            self.sshlib._log("Node not in HA pair as mentioned in yaml")

    def verify_takeover_option(self,node,val):
        '''This method is used to verify failover node details'''

        node_details = Readdata().get_dict_from_node(node)
        self.sshlib._log("Checking node : '%s'" %val)
        if node_details["HA_pair"].lower() == "yes":
            self.sshlib._log("Node is in HA pair mentioned in yaml")

            cmd = "storage failover show -node "+val
            output = self.sshlib.execute_command(cmd)
            BuiltIn().should_contain(output, "Node: "+val)
            BuiltIn().should_contain(output, "Partner Name: "+node_details["Partner_node"])
            BuiltIn().should_contain(output, "Takeover Enabled: true")
            BuiltIn().should_contain(output, "State Description: Connected to "+node_details["Partner_node"])
            self.sshlib._log("Found Partner node : '%s' with connected state" %node_details["Partner_node"])
        else:
            self.sshlib._log("Node not in HA pair as mentioned in yaml")
