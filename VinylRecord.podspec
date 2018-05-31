Pod::Spec.new do |s|
  s.name     = 'VinylRecord'
  s.version  = '1.0.10'
  s.license  = 'MIT'
  s.summary  = 'Pure SQLite ORM for iOS without CoreData.'
  s.homepage = 'https://github.com/valerius/VinylRecord.git'
  s.description = %{
    Pure SQLite ORM for iOS without CoreData.
    For more details check Wiki on Github.
  }
  s.author   = { 'James Whitfield' => 'jwhitfield@neilab.com' }
  s.source   = {  :git => 'https://github.com/valerius/VinylRecord.git',
                  :tag => s.version.to_s
                }

  s.platform = :ios ,"7.0"
  s.source_files = 'iActiveRecord/**/*.{c,h,m,mm}'
  s.public_header_files="iActiveRecord/**/*Protocol.h","iActiveRecord/**/*Helper.h",
      "iActiveRecord/**/*Error.h","iActiveRecord/**/*Exception.h","iActiveRecord/**/*ActiveRecord.h",
      "iActiveRecord/**/*VinylRecord.h","iActiveRecord/**/*Configuration.h","iActiveRecord/**/*State.h",
      "iActiveRecord/**/NSString*.h" if false

  s.module_map="iActiveRecord/VinylRecord.modulemap"
  s.private_header_files = "iActiveRecord/**/*Private.h"
  s.library = 'sqlite3'
  s.requires_arc = true

  s.xcconfig = {
    'OTHER_LDFLAGS' => '-lc++',
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) SQLITE_CORE SQLITE_ENABLE_UNICODE' 
  }
end
