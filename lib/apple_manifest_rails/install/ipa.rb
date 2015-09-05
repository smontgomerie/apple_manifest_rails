require 'cfpropertylist'

module AppleManifestRails
  module Install
    class IPA

      def template
        AppleManifestRails.template('manifest.plist')
      end
      
      def manifest_path
        Rails.root.join('tmp', 'manifest.plist').to_s
      end

      attr_accessor :base_url
      attr_accessor :app
      attr_accessor :identifier, :version, :display_name

      def initialize(request, app)
        self.app = app
        self.base_url = "#{request.scheme}://#{request.host_with_port}"
      end

      def title
        display_name + " " + version
      end

      def itms_uri
        "itms-services://?action=download-manifest&url=#{self.base_url}/apple_manifest/#{app.uuid}/manifest.plist"
      end

      def url
        "#{self.base_url}/install/#{app.uuid}/app.ipa"
      end

      def write_manifest
        extract_plist(app.file_path)

        File.open(manifest_path, "w") do |f|
          File.open(template, "r") do |tmpl|
            line = tmpl.read
            line.gsub!("[IPAURL]", self.url)
            line.gsub!("[BUNDLE_IDENTIFIER]", self.identifier)
            line.gsub!("[BUNDLE_VERSION]", self.version)
            line.gsub!("[BUNDLE_NAME]", self.title)

            f.write line
          end
        end
      end

      private
      def extract_plist ipa_path
        tempfile = File.join('tmp', 'Info.plist')
        FileUtils.rm tempfile if File.exists? tempfile
        Zip::ZipFile.open(ipa_path) do |zipfile|
          zipfile.each do |file|
            if file.to_s.include? 'Info.plist'
              file.extract tempfile
              break
            end
          end
        end

        plist = CFPropertyList::List.new(:file =>  tempfile)
        data = CFPropertyList.native_types(plist.value)
        self.identifier = data['CFBundleIdentifier']
        self.version = data['CFBundleShortVersionString']
        self.display_name = data['CFBundleDisplayName']

        FileUtils.rm tempfile
      end
    end
  end
end