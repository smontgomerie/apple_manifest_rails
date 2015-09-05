AppleManifestRails::Engine.routes.draw do
  get "/enroll/:id" => "manifest#enroll"
  get "/enroll/:id/mobileconfig" => "manifest#mobileconfig"
  post "/enroll/:id/mobileconfig/extract_udid" => "manifest#extract_udid"
  get "/enroll/:id/mobileconfig/extract_udid/check_install" => "manifest#check_install"
  get "/enroll/:id/install" => "manifest#check_install"
  get "/install/:id" => "manifest#enroll"
  get "/apple_manifest/:id/manifest.plist" => "manifest#manifest"
  get "/install/:id/app.ipa" => "manifest#send_ipa"
end