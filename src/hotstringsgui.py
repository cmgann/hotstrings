from tkinter import Tk, Label, Button, Listbox, StringVar, Frame, Entry
from mytools import get_hotstrings


class App:
    def __init__(self, master):
        self.master = master
        # Titles Gui
        self.master.title("HotStrings")
        # sets window size
        self.master.geometry("330x230") # Width x Height
        # go to landing view
        self.view_landing()

    def view_landing(self):
        self.frame_landing= Frame(self.master)
        self.frame_landing.grid(column=0, row=0)
        # start landing frame

        frame_hotstring_list= Frame(self.frame_landing)
        frame_hotstring_list.grid(column=0, row=0)

            # start hotstring list frame
                # variables
        hotstrings = get_hotstrings()
        hotstringsvar = StringVar(value=hotstrings)

                # hotstring list box
                    # list box label
        lable_listbox = Label(frame_hotstring_list, text='Hotstring Command')
        list_hotstrings = Listbox(frame_hotstring_list, listvariable= hotstringsvar)
        hotstringsvar.set(hotstrings)
            #grid
        lable_listbox.grid(column=0, row=0)
        list_hotstrings.grid(column=0, row=1)
        lable_listbox.grid(column=0, row=0)
        list_hotstrings.grid(column=0, row=1)

            # button frame
        frame_buttons = Frame(self.frame_landing)
        frame_buttons.grid(column=1, row=0)

                # buttons
        add_button = Button(frame_buttons, text='Add', command = self.add_hotstring)
        edit_button = Button(frame_buttons, text='Edit')
        delete_button = Button(frame_buttons, text='Delete')
            #grid
        add_button.grid(column=0, row=0)
        edit_button.grid(column=0, row=1)
        delete_button.grid(column=0, row=2)

        # end landing frame

    def add_hotstring(self):

        # delete old landing frame
        self.frame_landing_delete()

        # create new landing frame
        self.frame_landing= Frame(self.master)
        self.frame_landing.grid(column=0, row=0)
        # start landing frame

        frame_hotstring_list= Frame(self.frame_landing)
        frame_hotstring_list.grid(column=0, row=0)

            # Command Frame
        frame_hotstring_command = Frame(self.frame_landing)
        frame_hotstring_command.grid(column=0, row=0)

                # Command Label
        label_command = Label(frame_hotstring_command, text = 'Hotstring Command')
        entry_command = Entry(frame_hotstring_command)
        button_command_add = Button(frame_hotstring_command, text='Add')

            # Command Frame grid
        label_command.grid(column=0, row=0)
        entry_command.grid(column=0, row=1)
        button_command_add.grid(column=1, row =1)


    def frame_landing_delete (self):
        self.frame_landing.destroy()


def main():
    root = Tk()
    gui = App(root)
    root.mainloop()

if __name__ == "__main__":
    main()