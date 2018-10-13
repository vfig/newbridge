# Package the mission! Run this from cmd.exe: 'python package.py <zipfile>'

# These files and directories will be included.
#
INCLUDE = [
    # Subdirs
    'books',
    'fam',
    'intrface',
    'mesh',
    'movies',
    'obj',
    'snd',
    'sq_scripts',
    'strings',
    'subtitles',

    # Files
    'fm.cfg',
    'newbridge.gam',
    'miss20.mis',
    'readme.txt',
    'readme_contest.txt',
    ]

# To exclude specific files from subdirs, put them here
#
EXCLUDE = [
    'sq_scripts\\testamb.nut',
    ]

def get_zipfile_name():
    import sys
    if len(sys.argv) < 2:
        raise ValueError("Missing zipfile argument!")
    name = sys.argv[1]
    if not name.lower().endswith('.zip'):
        name += '.zip'
    return name

def gather_files():
    from os import scandir
    from os.path import isdir
    def listdir_recursive(*paths):
        paths = set(paths)
        dirs = set(p for p in paths if isdir(p))
        files = paths - dirs
        while dirs:
            d = dirs.pop()
            for f in scandir(d):
                if f.is_dir():
                    dirs.add(f.path)
                else:
                    files.add(f.path)
        return files
    included_files = listdir_recursive(*INCLUDE)
    excluded_files = listdir_recursive(*EXCLUDE)
    return sorted(included_files - excluded_files)

def create_package(files, package_name):
    from os import replace
    from zipfile import ZipFile, ZIP_DEFLATED
    TEMP_PACKAGE = '.package.zip'
    with ZipFile(TEMP_PACKAGE, mode='w', compression=ZIP_DEFLATED) as zf:
        for f in files:
            print("> " + f)
            zf.write(f)
    replace(TEMP_PACKAGE, package_name)
    print(package_name + " created.")

if __name__ == '__main__':
    create_package(gather_files(), get_zipfile_name())
