import listenerclass
import os

if __name__=="__main__":
    print(os.getcwd())
    listenerclass.Keyboard_Listener().activate_listener()
else:
    pass