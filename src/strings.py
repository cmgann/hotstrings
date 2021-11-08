import pyautogui
import pyperclip
import os
from mytools import get_hotstrings, get_hot_string_text

def write(combo):
    # checks if the combination matches a hotstring
    if combo in get_hotstrings():
        #print(f'The {combo} is valid')
        text = get_hot_string_text(combo)

        # highlights and deletes string
        with pyautogui.hold(['alt']):
            with pyautogui.hold(['shift']):
                pyautogui.press(['left'])
        pyautogui.press('delete')#

        # stores desired output to clipboard
        pyperclip.copy(text)

        # determine operating system
        # paste desired output mac
        if os.name == 'posix':
            with pyautogui.hold('command'):
                pyautogui.press('v')
        # all others
        #else:
            with pyautogui.hold('control'):
                pyautogui.press('v')

    else:
        #print('combo not valid')
        pass


