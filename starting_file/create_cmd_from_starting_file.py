# These are the lines where individual groups should be created, so in the end there are multiple echo commands instead of one long one
GROUPED_LINES_NUMBER = (5, 14, 36, 49, 58)


def reformat_line_group(number_of_lines):  # This reformats each line of the multiple passed lines
    # Read the wanted number of lines from the file and go through each of them
    reformatted_lines = []
    for i in range(number_of_lines):
        line = original_file.readline()
        line = line.replace('%', '%%')  # Replace all variable names so they are echoed correctly
        line = line.strip('\n')

        if line.strip():  # If the line contains anything other than the spaces and tabs then add a space to the beginning of it, so that in the end it is "echo ___"
            line = ' ' + line
        else:  # Otherwise set it to a dot, so in the end it is "echo." for an empty line
            line = '.'

        reformatted_lines.append(line)

    output_line = ' %n%'.join(reformatted_lines)  # Add the echo command between the individual lines
    output_line = output_line.strip()

    # Replace all the needed variables here, because if they were replaced earlier, they would be called "%%var%%"
    output_line = output_line.replace('$show_console$', '%show_console%')
    output_line = output_line.replace('$start_file$', '%reformattedStartFile%')
    output_line = output_line.replace('$arguments$', '%arguments%')
    output_line = output_line.replace('$source_code_url$', '%reformattedUrl%')
    output_line = output_line.replace('$program_name$', '%program_name%')

    return output_line


print('\nThis script generates commands which can be executed in the installer script to create a starting script in a different file.')
print('\nTo use this you have to define the following two variables in the beginning of the script (not the %n% or the variables after).')
print('The script also needs the variables "program_name", "source_code_url", "installPath" and "initialFilePath" to already be set.')
print('\nCommands to copy and paste: \n\n')

print(":: - show_console: Whether the installed python script should show an output console or not (This can also be changed later)")
print(':: - arguments: The arguments with which the downloaded python file is started when running the program')
print('set "show_console=..."')
print('set "arguments=..."')
print()

# The following code sets variables in the installer script. Their contents are later written to the start file.
print('set "n=& echo"')
# The following code replaces the content of the variables from the installer script, so it can deal with filenames and URLs containing %
# This works by replacing every % in the variable with %%
print('set reformattedUrl=%source_code_url:%%=%%%%%')
print('set reformattedStartFile=%initialFilePath:%%=%%%%%')


# The following code generates individual lines to create the start file.
original_file = open('start.cmd')

last_line_number = 0
for line_number in GROUPED_LINES_NUMBER:
    reformatted_line = reformat_line_group(line_number - last_line_number)  # Read the unread lines until the wanted line number and reformat them
    last_line_number = line_number

    print(f'(echo {reformatted_line} ) >> %installPath%\\%program_name%.cmd')

print()
