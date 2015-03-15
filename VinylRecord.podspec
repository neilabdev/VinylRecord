Pod::Spec.new do |s|
  s.name     = 'VinylRecord'
  s.version  = '1.0.4'
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
  s.library = 'sqlite3'
  s.requires_arc = true

  s.xcconfig = {
    'OTHER_LDFLAGS' => '-lc++',
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) SQLITE_CORE SQLITE_ENABLE_UNICODE' 
  }
end
