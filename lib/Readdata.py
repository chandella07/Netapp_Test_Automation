import yaml,os

class Readdata(object):
    '''
    Readdata class is used to extend keywords suppport for reading config data 
    also, to fetch specific data format to get data.
    '''
   
    def __init__(self):
        ''' Initializing file variables '''

        self.yamlfilename = "/config_data/config.yaml"
        self.CURDIR = os.getcwd()
        self.finalfilepath=''.join([self.CURDIR,self.yamlfilename])

        with open(self.finalfilepath) as stream:
            try:
                self.var = yaml.load(stream)
            except yaml.YAMLError as exc:
                print exc    


    def get_dict_from_node(self,node):
        ''' This method is used to get dictionary from yaml based on node name '''

        return self.var[node]

    def get_keys_from_node(self,node):
        ''' This method is used to get keys from yaml based on node name'''
        
        return self.var[node].keys()

    def get_values_from_node(self,node):
        ''' This method is used to get values from yaml based on node name'''

        return self.var[node].values() 


