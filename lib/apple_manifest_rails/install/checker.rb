require 'fileutils'
require 'zip/zipfilesystem'

module AppleManifestRails
  module Install
    class Checker
      attr_accessor :mobileprovision

      def initialize(app)
        ipa_path = app.file_path     # TODO this ties the app to paperclip
        extract_mobileprovision_from ipa_path
      end

      def installable? udid
        return true if self.mobileprovision.include?("ProvisionsAllDevices") # is it enterprise?

        self.mobileprovision.include?(udid) # Does it include the UDID ?
      end
      
      private
      def extract_mobileprovision_from ipa_path
        tempfile = File.join('tmp', 'embedded.mobileprovision')
        FileUtils.rm tempfile if File.exists? tempfile
        Zip::ZipFile.open(ipa_path) do |zipfile|
          zipfile.each do |file|
            if file.to_s.include? 'embedded.mobileprovision'
              file.extract tempfile
              break
            end
          end
        end
        File.open(tempfile) {|f| self.mobileprovision = f.read }
        FileUtils.rm tempfile
      end
    end
  end
end
