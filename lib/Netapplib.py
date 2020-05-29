from robot.libraries.BuiltIn import BuiltIn
from collections import OrderedDict
from lib.Keywords import Keywords
import re,datetime

class Netapplib(Keywords):
    '''
        Netapplib: core library for netapp testing.
        Usage:
        Advance parsers and verification methods for Netapp automation.
        It provides parsers to parse output row wise or column wise.
        Also provide generic verfication methods.
    '''
    
    #sshlib = BuiltIn().get_library_instance('SSHLibrary')

    
    def get_dict_column_wise(self, output, col_num=0, start_line=0, end_line=-2):
        ''' This method is used to get dictionary column wise from command output
            input params::-
            output: output of the command
            col_num: column number to be fatched
            start_line: line number to start parsing table
            end_line: line number to stop parsing table
            output params::- dictionary with single key and list of values
        '''

        lines = output.splitlines()
        list1= []
        for line in lines[int(start_line):int(end_line)]:
             columns = line.split()
             if not columns[int(col_num)].startswith('--'):
                 list1.append(columns[int(col_num)])

        list2 = []
        list2.append(list1)
        dict1 = {i[0]:i[1:] for i in list2}
        self.sshlib._log("Column wise dictionary created: '%s'" % dict1)
        return dict1


    def get_dict_row_wise(self, output, start_line=0, end_line=-2):
        '''This method is used to get list of dictionaries row wise from command output
           input params::-
           output: output of the command
           start_line: line number to start parsing table
           end_line: line number to stop parsing table
           output params::- list with elements as dictionaries'''

        heading=[]
        content=[]
        list1=[]
        lines = output.splitlines()
        for index,line in enumerate(lines[int(start_line):int(end_line)]):
            column = line.split()
            if index == 0:
                heading.append(column)
            else:
                content.append(column)
              
        for keys,value in map(None,heading,content[1:]):
            if keys:
                key=keys
            dictionary = dict(zip(key, value))
            list1.append(dictionary)
        self.sshlib._log("Row wise List of dictionary elements created: '%s'" % list1)
        return list1


    def compare_dict_column_wise(self, expected_dict, actual_dict):
        '''This method is used to compare the expected dictionary with actual dictionary
           It will compare the dictionaries as columns
           Where dictionary key is heading and dictionary values are data
           if keys and values of expected dictionary is found in actual dictionary
           than it will return True else return False'''

        try:
            if actual_dict.has_key(expected_dict.keys()[0]):
                self.sshlib._log("key matched '%s'" % expected_dict.keys())
            else:
                self.sshlib._log("key not matched '%s'" % expected_dict.keys())
                return False 

            for val in expected_dict.values()[0]:
                if val in actual_dict.values()[0]:
                    self.sshlib._log("Value matched '%s'" % val)
                else:
                    self.sshlib._log("Value not matched '%s'" % val)
                    return False
        except (KeyError,ValueError):
            raise RuntimeError("Error in comparing dictionary column wise")
    
        return True


    def compare_dict_row_wise(self, expected_dict, actual_list_dict, row_num=None):
        '''This method is used to compare the expected dictionaries with actual dictionary
           If row_num param is passed it will compare specific row otherwise it will compare all the rows
           If keys and values of expected dictionary is matched to keys and values of actual dictionary
           Then it will return status True else return status false'''

        expected_dict = OrderedDict([(key, expected_dict[key]) for key in sorted(expected_dict.keys())])
        if row_num:
            item = actual_list_dict[int(row_num)]
            item = OrderedDict([(key, item[key]) for key in sorted(item.keys())])
            status = self.match_dict(item,expected_dict)
            return status
        else:
            for item in actual_list_dict:
                item = OrderedDict([(key, item[key]) for key in sorted(item.keys())])
                status = self.match_dict(item,expected_dict)
                return status


    def match_dict(self, dict1, dict2):
        '''This method will matched two dictionaries
           If dictionary keys and values matched return True else return False'''

        for x,y in zip(dict1.items(),dict2.items()):
            if x == y:
                self.sshlib._log("expected dict item '%s' matched to actual dict item '%s'" % (x,y))
            else:
                self.sshlib._log("expected dict item '%s' not matched to actual dict item '%s'" % (x,y))
                return False
        return True


    def get_row_index(self,list_of_dict,key,value):
        ''' This method is used to get row index in which expected dictionary key:value is found'''

        for index,i in enumerate(list_of_dict):
            d2 = OrderedDict([(k, i[k]) for k in sorted(i.keys())])
            try:
                if d2[key] == value:
                    self.sshlib._log("Dictionary key-value pair found in row - '%s'" % index)
                    return index
            except (KeyError,ValueError):
                raise RuntimeError("Dictionary error: issue in key-value pair")
        raise RuntimeError("Dictionary error: key-value pair not found in result")


    def get_column_value_by_index(self, dict1, heading=None, index=0):
        ''' This method is used to get value from specific column '''
        
        try:
            val = dict1[heading]
            return val[int(index)]
        except IndexError:
            raise RuntimeError('Index Error')

    def create_flat_list(self,list1):
        '''This method is used to create a flat single list from a list of lists'''

        flat_list = [item for sublist in list1 for item in sublist]
        return flat_list

    def get_num(self,value):
        ''' This method is used to remove extra special character from number
            e.g  input : 25GB  and  output : 25   '''
 
        pattern = re.compile(r'(^\d*)')
        reg = pattern.search(value)
        return reg.group(1)

    def match_list(self,val,list1):
        '''This method is used to check if expected element matches every element of list'''
        if len(list1) == 0:
            raise RuntimeError("List is empty")
        for element in list1:
            if val == element:
                self.sshlib._log("'%s' element found in list : %s" % (val,list1))
            else:
                raise RuntimeError("'%s' element not found in list : %s" % (val,list1))

    def check_multiple_should_contains(self,output,*args):
        '''This method is use to check multiple should contain statement
           if the output passed to this method contains one or more arg strings 
           then it will return True else return false'''
        
        status_dict = {}
        for arg in args:
            pattern = re.compile(arg)
            reg = pattern.search(output)
            if str(type(reg)) == "<type 'NoneType'>":
                status_dict.update({arg:'no'})
            else:
                status_dict.update({arg:'yes'})
        self.sshlib._log("Status dictionary is : %s" %status_dict)
        status_list = status_dict.values()
        if 'yes' in status_list:
            return True
        else:
            return False

    def compare_time(self,time1,time2):
        '''This method is used to compare two times and finds diff in minutes
           returns True if diff is less than 5 mins else return False'''

        time1 = datetime.datetime.strptime(time1, "%H:%M")
        time2 = datetime.datetime.strptime(time2, "%H:%M")
        newTime = time2 - time1
        diff=  newTime.seconds/60 
        self.sshlib._log("Time difference is : %s minutes" %diff)
        if diff <= 5:
            return True
        else:
            return False

 
    def get_date_from_timestamp(self,output):
        '''This method is used to get date from command output'''
        
        pattern = re.compile(r'(\w+)\s(\w+)\s+(\d+)\s(\d+):(\d+)')
        reg = pattern.search(output)
        if len(reg.group(3)) > 1:
            return reg.group(1)+" "+reg.group(2)+" "+reg.group(3)
        else:
            return reg.group(1)+" "+reg.group(2)+" "+"0"+reg.group(3)

    def get_time_from_timestamp(self,output):
        '''This method is used to get time from command output'''

        pattern = re.compile(r'(\w+)\s(\w+)\s+(\d+)\s(\d+):(\d+)')
        reg = pattern.search(output)
        return reg.group(4)+":"+reg.group(5)
     

        
