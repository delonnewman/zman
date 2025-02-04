require 'pathname'

root = Pathname(__dir__).join('..')
$LOAD_PATH << root.join('lib') << root.join('vendor/el/lib')

require 'zman'

Dir.chdir(root) if Zman.env == 'development' # load IRB from root
