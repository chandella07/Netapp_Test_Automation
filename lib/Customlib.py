from robot import *
from robot.libraries.BuiltIn import BuiltIn
from SSHLibrary.config import ConfigurationException

class Customlib(object):
    ''' Custom class to create Setup and Teradown methods '''
    #sshlib = BuiltIn().get_library_instance('SSHLibrary')

    def Open_Connection_And_Log_In(self, host, username, password):
        ''' Open a New SSH Connection to the host machine and login with 
        provided username and password '''
        self.sshlib.open_connection(host)
        self.sshlib.login(username, password)

    def Check_Version(self,version):
        '''Checks the Netapp version if found supported version PASS the test else FAIL the test'''
        ver= self.sshlib.execute_command("version")
        if version in ver:
            self.sshlib._log("Supported version found on Netapp")
        else:
            raise CustomFatalError("Supported version not found on Netapp")

    def set_terminal(self, cmd):
        ''' Sets the terminal output '''
        self.sshlib._log("Executing command -- '%s'" % cmd)        
        try:
            self.sshlib.set_client_configuration(prompt='::>')
            self.sshlib.write(cmd)
            status = self.sshlib.read_until_prompt()
            status = status.strip()
            if '::>' in status:
                 self.sshlib._log("Terminal is set to '%s'" % cmd)
            else:
                raise ConfigurationException("Terminal is not set")
        except ConfigurationException:
            raise RuntimeError("Terminal is not set to '%s'" % cmd)

    def set_diag_mode(self):
        '''This method will set the diag mode on Netapp'''
        self.sshlib._log("Executing command -- 'set diag'")
        try:
            self.sshlib.set_client_configuration(prompt=':')
            self.sshlib.write('set diag')
            status = self.sshlib.read_until_prompt()
            self.sshlib.set_client_configuration(prompt='::*>')
            self.sshlib.write('y')
            status = self.sshlib.read_until_prompt()
            status = status.strip()
            if '::*>' in status:
                 self.sshlib._log("Terminal is set to 'diag mode'")
            else:
                raise ConfigurationException("Terminal is not set to diag mode")
        except ConfigurationException:
            raise RuntimeError("Terminal is not set to 'diag mode'")

        
class CustomFatalError(RuntimeError):
    ''' Raises FATAL Error '''
    ROBOT_EXIT_ON_FAILURE = True
