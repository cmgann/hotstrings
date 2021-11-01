import os


def get_hotstrings():
	# clean list
	hotstrings = []

	# used to collect file names
	f = []
	path = f'{os.getcwd()}/hotstrings'
	print(path)
	for (dirpath, dirnames, filenames) in os.walk(path):
		f.extend(filenames)
		print(f'item = {f}')
		break

	# removes file extension from file name and adds it to the clean list
	for item in f:
		hotstrings.append(item[:-3])
	print(hotstrings)
	return hotstrings

# gets the text in the hotstring file
def get_hot_string_text(hotstring):
	with open(f'hotstrings/{hotstring}.hs', 'r') as file:
		text = file.read()
	return text

if __name__=="__main__":
	print(get_hotstrings())
else:
	pass