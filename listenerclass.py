import pyautogui
import strings as s

# pyautogui.write('Hello World!')

#import pynput
from pynput.mouse import Listener as MouseListener
from pynput.keyboard import Listener as KeyboardListener

class Keyboard_Listener:

    def __init__(self):
        self.typed = None

    # Keyboard functions
    def on_press(self, key):
        # if button press isn't special character
        try:
            #print('alphanumeric key {0} pressed'.format(
             #   key.char))
            # adds to self.typed string
            self.add_to_string(key.char)
            return

        except AttributeError:
            # Checks to see if special character is shift
            if str(key) == 'Key.shift':
                return

            # removes last character typed for backspace entered
            elif str(key) == 'Key.backspace':
                if self.typed == None:
                    return
                else:
                    self.typed = self.typed[:-1]
                    return
            else:
                #print(self.typed)
                #print('A special key {0} pressed'.format(key))
                s.write(self.typed)
                self.typed = None
                # to close lose return False
                # return False
                return


    # mouse functions
    def on_move(self, x, y):
        #print("Mouse moved to ({0}, {1})".format(x, y))
        pass

    def on_click(self, x, y, button, pressed):
        if pressed:
            #print('Mouse clicked at ({0}, {1}) with {2}'.format(x, y, button))
            pass
        else:
            #print('Mouse released at ({0}, {1}) with {2}'.format(x, y, button))
            pass

    def on_scroll(self, x, y, dx, dy):
        #print('Mouse scrolled at ({0}, {1})({2}, {3})'.format(x, y, dx, dy))
        pass


    # activate listeners
    def activate_listener(self):
        # Collect events until released
        keyboard_listener = KeyboardListener(on_press=self.on_press)
        mouse_listener = MouseListener(on_move=self.on_move, on_click=self.on_click, on_scroll=self.on_scroll)

        with keyboard_listener:

            try:
                # this is activated by the with statement
                # keyboard_listener.start()
                mouse_listener.start()
                keyboard_listener.join()
                mouse_listener.join()
            except RuntimeError:
                print('Listener Completed')


    def add_to_string(self, key):
        # Checks to see if typed is None
        if self.typed == None:
            self.typed = key

        # If not None then add key press to string
        else:
            self.typed = self.typed + key

if __name__=="__main__":
    Keyboard_Listener().activate_listener()
else:
    pass