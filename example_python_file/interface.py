import sys
import re
import webbrowser
import subprocess
import os
from PyQt6.QtWidgets import QApplication, QWidget, QVBoxLayout, QPushButton, QLabel


# Get the directory of the current Python file
CURRENT_DIRECTORY = os.path.dirname(os.path.abspath(__file__))

# Specify the file name
RESTART_FILE_NAME = 'Example Interface.lnk'

# Create the full path to the file
RESTART_FILE = os.path.join(CURRENT_DIRECTORY, RESTART_FILE_NAME)  # Use the lnk file (similar to the one in the programs folder) to prevent any errors because files are already used.


class ExampleApp(QWidget):
    def __init__(self):
        super().__init__()
        self.initUI()
        with open(os.path.join(CURRENT_DIRECTORY, 'Example Interface.cmd')) as file:
            for line in file:
                if 'set "source_code_url=' in line:
                    # Use a regular expression to find the value
                    match = re.search(r'set "source_code_url=(.*?)"', line)
                    if match:
                        self.source_code_url = match.group(1)
                        break  # Exit the loop once we find the first match

    def initUI(self):
        self.setWindowTitle('PyQt6 Example')
        self.setFixedSize(300, 200)  # Set fixed size for the window
        layout = QVBoxLayout()

        # Button to open source code URL
        btn_open_url = QPushButton('Open Source Code URL')
        btn_open_url.clicked.connect(self.open_source_code)
        layout.addWidget(btn_open_url)

        # Button to restart the program
        btn_restart = QPushButton('Restart Program')
        btn_restart.clicked.connect(self.restart_program)
        layout.addWidget(btn_restart)

        # Button to say something to the console
        btn_console_message = QPushButton('Say Something to Console')
        btn_console_message.clicked.connect(self.console_output)
        layout.addWidget(btn_console_message)

        self.setLayout(layout)
        self.show()

    def open_source_code(self):
        webbrowser.open(self.source_code_url)

    @staticmethod
    def restart_program():
        print("Restarting program...")
        subprocess.Popen([RESTART_FILE], shell=True)
        sys.exit()

    @staticmethod
    def console_output():
        print("Hello from the console!")


if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = ExampleApp()
    sys.exit(app.exec())
