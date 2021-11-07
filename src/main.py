import listenerclass
import os
import sys

if __name__=="__main__":
    args = sys.argv

    if len(args) > 1:
        if args[1].lower() == 'gui':
            os.system('python3 hotstringsgui.py')
        else:
            print('If you are trying to access the gui to add/edit/delete new hotstrings please use "gui"')
    else:
        listenerclass.Keyboard_Listener().activate_listener()
else:
    pass