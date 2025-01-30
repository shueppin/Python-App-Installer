import PyInstaller.__main__


# Change the values in the python and CMD installer

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

# Generate the JSON based on the template
