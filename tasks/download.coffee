gulp = require 'gulp'
fs = require 'fs-extra-promise'
{platform} = require './utils'
electronDownloader = require 'gulp-electron-downloader'
manifest = require '../src/package.json'

# Flags to keep track of downloads
downloaded =
  darwin64: false
  linux32: false
  linux64: false
  win32: false

# Download the Electron binary for a platform
[
  ['darwin', 'x64', 'darwin64', './build/darwin64']
  ['linux', 'ia32', 'linux32', './build/linux32/opt/' + manifest.name]
  ['linux', 'x64', 'linux64', './build/linux64/opt/' + manifest.name]
  ['win32', 'ia32', 'win32', './build/win32']
].forEach (release) ->
  [platformName, arch, dist, outputDir] = release

  gulp.task 'download:' + dist, ['kill:' + dist], (done) ->
    # Skip if already downloaded to speed up auto-reload
    if downloaded[dist]
      return done()

    electronDownloader
      version: manifest.electronVersion
      cacheDir: './cache'
      outputDir: outputDir
      platform: platformName
      arch: arch
    , ->
      downloaded[dist] = true

      # Also rename the .app on darwin
      if dist is 'darwin64'
        fs.rename './build/darwin64/Electron.app', './build/darwin64/' + manifest.productName + '.app', done
      else
        done()

# Download for the current platform by default
gulp.task 'download', ['download:' + platform()]
