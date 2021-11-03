from tkinter import Tk, Label, Button, Listbox, StringVar, Frame, Entry, Text
from mytools import get_hotstrings, add_hotstring_file, delete_hotstring_file


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
        self.hotstrings = get_hotstrings()
        hotstringsvar = StringVar(value=self.hotstrings)

                # hotstring list box
                    # list box label
        lable_listbox = Label(frame_hotstring_list, text='Hotstring Command')
        self.list_hotstrings = Listbox(frame_hotstring_list, listvariable= hotstringsvar)
        hotstringsvar.set(self.hotstrings)
            #grid
        lable_listbox.grid(column=0, row=0)
        self.list_hotstrings.grid(column=0, row=1)
        lable_listbox.grid(column=0, row=0)

            # button frame
        frame_buttons = Frame(self.frame_landing)
        frame_buttons.grid(column=1, row=0)

                # buttons
        add_button = Button(frame_buttons, text='Add', command = self.button_add_hotstring)
        edit_button = Button(frame_buttons, text='Edit')
        delete_button = Button(frame_buttons, text='Delete', command = self.delete_hotstring)
            #grid
        add_button.grid(column=0, row=0)
        edit_button.grid(column=0, row=1)
        delete_button.grid(column=0, row=2)

        # end landing frame

    def button_add_hotstring(self):

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
        self.entry_command = Entry(frame_hotstring_command)
        button_command_add = Button(frame_hotstring_command, text='Add', command=self.add_hotstring)
        self.text_command_output = Text(frame_hotstring_command, width=40, height=10)

            # Command Frame grid
        label_command.grid(column=0, row=0)
        self.entry_command.grid(column=0, row=1)
        button_command_add.grid(column=1, row=1)
        self.text_command_output.grid(column=0, row=2, columnspan=2)

    # deletes landing frame
    def frame_landing_delete(self):
        self.frame_landing.destroy()


    # adds new command file
    def add_hotstring(self):
        # get command input
        command = self.entry_command.get()
        # get text output
        output = self.text_command_output.get('1.0', 'end')
        # create file
        add_hotstring_file(command,output)
        # delete landing frame
        self.frame_landing_delete()
        # goes back to landing view
        self.view_landing()

    def delete_hotstring(self):
        selection = self.list_hotstrings.curselection()
        selection = self.hotstrings[selection[0]]

        # delete file
        delete_hotstring_file(selection)
        
        #refresh page
        self.frame_landing_delete()
        self.view_landing()



def main():
    root = Tk()
    gui = App(root)
    root.mainloop()

if __name__ == "__main__":
    main()