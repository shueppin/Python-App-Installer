import PyInstaller.__main__

# Exe installer
PyInstaller.__main__.run([
    'test_pyinstaller.py',
    '--noconfirm',
    '--onefile',
    '--console',
    '--exclude-module=PyInstaller',
    '--distpath=exe_builder_directory',
    '--workpath=exe_builder_directory/build',
    '--specpath=exe_builder_directory/spec'
])

# Create the different installers based on some Base Values
